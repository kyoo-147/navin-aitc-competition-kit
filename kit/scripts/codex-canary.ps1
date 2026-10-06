[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$RepoPath,
    [Parameter(Mandatory = $true)][string]$Model,
    [string]$CodexHome = (Join-Path $HOME '.codex')
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\Aitc.Common.ps1')
$repo = Assert-AitcOfficialRepo -RepoPath $RepoPath
$key = Get-AitcGatewayKey -RepoPath $repo
$logSettings = Get-AitcLogSettings -RepoPath $repo
$codex = Get-AitcCodexCommand
if (-not (Test-Path -LiteralPath (Join-Path $CodexHome 'config.toml'))) { throw 'Missing Codex config. Run bootstrap.ps1.' }
if (-not (Test-Path -LiteralPath (Join-Path $CodexHome 'config.toml'))) { throw 'Missing Codex config. Run bootstrap.ps1.' }
$configText = Get-Content -LiteralPath (Join-Path $CodexHome 'config.toml') -Raw
if ($configText -notmatch '(?m)^\s*model_provider\s*=\s*"thucchien"') { throw 'Refusing canary: Codex provider is not thucchien.' }
if ($configText -notmatch '(?m)^\s*model_catalog_json\s*=\s*"([^"]+)"') { throw 'Refusing canary: model_catalog_json is missing.' }

$nonce = [Guid]::NewGuid().ToString('N').Substring(0, 12)
$marker = "AITC_CANARY_OK_$nonce"
$prompt = "Reply with exactly $marker. Do not read files and do not call tools."
$oldHome = $env:CODEX_HOME
$oldGateway = $env:THUCCHIEN_API_KEY
$env:CODEX_HOME = $CodexHome
$env:THUCCHIEN_API_KEY = $key
$startedUtc = [DateTime]::UtcNow.AddSeconds(-2)

Push-Location $repo
try {
    Invoke-AitcCodexRuntimeRefresh -CodexHome $CodexHome -RuntimeScript (Join-Path $PSScriptRoot 'codex-runtime-refresh.ps1') | Out-Null
    $codexOutput = (& $codex --dangerously-bypass-approvals-and-sandbox --dangerously-bypass-hook-trust exec -m $Model $prompt 2>&1 | Out-String)
    if ($LASTEXITCODE -ne 0) { throw "Codex canary failed with exit code $LASTEXITCODE." }
    if ($codexOutput -notmatch [regex]::Escape($marker)) { throw 'Codex canary response lacks the expected marker.' }

    $meta = Get-AitcLatestCodexSessionMeta -CodexHome $CodexHome -RepoPath $repo -NotBeforeUtc $startedUtc
    if ($meta.Provider -ne 'thucchien') { throw "Canary used provider '$($meta.Provider)', not thucchien." }
    $localEvents = @(Get-AitcLocalLogEvents -RepoPath $repo -SessionId $meta.SessionId)
    foreach ($required in @('UserPromptSubmit', 'Stop')) {
        if (-not ($localEvents -contains $required)) { throw "Local AI Log lacks $required for canary session." }
    }

    $submitOutput = (& python scripts\submit_log.py 2>&1 | Out-String)
    if ($submitOutput -notmatch 'Submitted\s+\d+\s+entries.*202') {
        throw 'AI Log submission was not confirmed with status 202. Pending logs were preserved.'
    }
} finally {
    Pop-Location
    $env:CODEX_HOME = $oldHome
    $env:THUCCHIEN_API_KEY = $oldGateway
}

$uri = $logSettings.Server + '/entries?tool=codex'
$response = Invoke-RestMethod -Method Get -Uri $uri -Headers @{ Authorization = "Bearer $($logSettings.Key)"; Accept = 'application/json' } -TimeoutSec 30
$entries = Get-AitcProperty -Object $response -Name 'entries'
if ($null -eq $entries -and $response -is [System.Array]) { $entries = $response }
if ($null -eq $entries) { throw 'AI Log readback response does not contain entries.' }
$sessionEntries = @($entries | Where-Object { [string](Get-AitcProperty -Object $_ -Name 'session_id') -eq $meta.SessionId })
if ($sessionEntries.Count -eq 0) { throw 'Canary session was not found on the BTC server.' }
$sessionEvents = @($sessionEntries | ForEach-Object { [string](Get-AitcProperty -Object $_ -Name 'event') })
foreach ($required in @('UserPromptSubmit', 'Stop')) {
    if (-not ($sessionEvents -contains $required)) { throw "Canary server session lacks $required." }
}

Write-Host "[PASS] Codex Gateway canary returned the expected marker using model '$Model'."
Write-Host "[PASS] Rollout provider is thucchien for session $(Mask-AitcValue $meta.SessionId)."
Write-Host '[PASS] Local AI Log contains UserPromptSubmit and Stop.'
Write-Host '[PASS] AI Log submission returned 202.'
Write-Host '[PASS] BTC server readback contains the same session events.'
Write-Host 'CODEX CANARY VERIFIED' -ForegroundColor Green
