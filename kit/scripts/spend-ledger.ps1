[CmdletBinding()]
param(
    [ValidateSet('Init','Add','Status')][string]$Action = 'Status',
    [Parameter(Mandatory = $true)][string]$LedgerPath,
    [double]$BudgetUsd = 50,
    [string]$RunId,
    [string]$TaskId,
    [string]$Lane,
    [string]$Transport,
    [string]$Model,
    [ValidateSet('BTC_LIVE','SIMULATED_ROUTING_NON_BTC_TRANSPORT','NO_MODEL_T0')][string]$RoutingStatus = 'SIMULATED_ROUTING_NON_BTC_TRANSPORT',
    [datetime]$StartedAtUtc,
    [datetime]$EndedAtUtc,
    [long]$InputTokens = 0,
    [long]$CachedInputTokens = 0,
    [long]$OutputTokens = 0,
    [long]$ReasoningTokens = 0,
    [int]$SearchCalls = 0,
    [Nullable[double]]$ReportedCostUsd,
    [ValidateSet('SUCCEEDED','FAILED','BLOCKED','UNKNOWN')][string]$Outcome = 'UNKNOWN',
    [string]$Verification = ''
)

$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$registry = Get-Content -LiteralPath (Join-Path $root 'knowledge\model-registry.json') -Raw | ConvertFrom-Json
$policy = Get-Content -LiteralPath (Join-Path $root 'knowledge\routing-policy.json') -Raw | ConvertFrom-Json
$fullPath = [System.IO.Path]::GetFullPath($LedgerPath)
$parent = Split-Path $fullPath -Parent
if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
$utf8 = New-Object System.Text.UTF8Encoding($false)

if ($Action -eq 'Init') {
    [System.IO.File]::WriteAllText($fullPath, '', $utf8)
    [pscustomobject]@{ ledger = $fullPath; budget_usd = $BudgetUsd; spend_usd = 0; remaining_usd = $BudgetUsd; state = 'NORMAL' } | ConvertTo-Json
    exit 0
}

function Read-Ledger {
    if (-not (Test-Path -LiteralPath $fullPath)) { return @() }
    $rows = New-Object System.Collections.Generic.List[object]
    foreach ($line in [System.IO.File]::ReadAllLines($fullPath)) {
        if (-not [string]::IsNullOrWhiteSpace($line)) { $rows.Add(($line | ConvertFrom-Json)) }
    }
    return $rows.ToArray()
}

if ($Action -eq 'Add') {
    foreach ($required in @('RunId','TaskId','Lane','Transport','Model')) {
        if ([string]::IsNullOrWhiteSpace((Get-Variable -Name $required -ValueOnly))) { throw "$required is required for Add." }
    }
    if ($StartedAtUtc -eq [datetime]::MinValue -or $EndedAtUtc -eq [datetime]::MinValue) { throw 'StartedAtUtc and EndedAtUtc are required for Add.' }
    if ($EndedAtUtc -lt $StartedAtUtc) { throw 'EndedAtUtc must not precede StartedAtUtc.' }

    $modelInfo = @($registry.text_models | Where-Object { $_.id -eq $Model })
    if ($RoutingStatus -ne 'NO_MODEL_T0' -and $modelInfo.Count -eq 0) { throw "Unknown model in registry: $Model" }
    $estimated = 0.0
    if ($modelInfo.Count -gt 0) {
        $m = $modelInfo[0]
        # InputTokens is total input; cached tokens are billed at the cached rate
        # INSTEAD of the full input rate, so only the uncached remainder uses input_per_1m.
        $uncachedInput = [Math]::Max([long]0, [long]($InputTokens - $CachedInputTokens))
        $estimated += $uncachedInput / 1000000.0 * [double]$m.input_per_1m
        $estimated += $CachedInputTokens / 1000000.0 * [double]$m.cached_input_per_1m
        $estimated += ($OutputTokens + $ReasoningTokens) / 1000000.0 * [double]$m.output_per_1m
        if ($SearchCalls -gt 0 -and $null -ne $m.search_cost) { $estimated += $SearchCalls * [double]$m.search_cost }
    }
    $record = [ordered]@{
        run_id = $RunId
        task_id = $TaskId
        lane = $Lane
        transport = $Transport
        model = $Model
        routing_status = $RoutingStatus
        started_at_utc = $StartedAtUtc.ToUniversalTime().ToString('o')
        ended_at_utc = $EndedAtUtc.ToUniversalTime().ToString('o')
        duration_ms = [long]($EndedAtUtc.ToUniversalTime() - $StartedAtUtc.ToUniversalTime()).TotalMilliseconds
        input_tokens = $InputTokens
        cached_input_tokens = $CachedInputTokens
        output_tokens = $OutputTokens
        reasoning_tokens = $ReasoningTokens
        search_calls = $SearchCalls
        reported_cost_usd = if ($null -eq $ReportedCostUsd) { $null } else { [Math]::Round([double]$ReportedCostUsd, 8) }
        estimated_cost_usd = [Math]::Round($estimated, 8)
        verification = $Verification
        outcome = $Outcome
    }
    [System.IO.File]::AppendAllText($fullPath, (($record | ConvertTo-Json -Compress) + [Environment]::NewLine), $utf8)
    $record | ConvertTo-Json
    exit 0
}

$rows = @(Read-Ledger)
$spend = 0.0
foreach ($row in $rows) {
    if ($null -ne $row.reported_cost_usd) { $spend += [double]$row.reported_cost_usd }
    else { $spend += [double]$row.estimated_cost_usd }
}
$state = 'NORMAL'
foreach ($gate in @($policy.budget_gates | Sort-Object spend_gte)) {
    if ($spend -ge [double]$gate.spend_gte) { $state = [string]$gate.state }
}
[pscustomobject]@{
    ledger = $fullPath
    records = $rows.Count
    budget_usd = [Math]::Round($BudgetUsd, 4)
    spend_usd = [Math]::Round($spend, 8)
    remaining_usd = [Math]::Round([Math]::Max([double]0, [double]($BudgetUsd - $spend)), 8)
    state = $state
} | ConvertTo-Json
