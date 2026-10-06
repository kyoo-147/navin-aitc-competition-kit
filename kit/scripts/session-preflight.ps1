[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$RepoPath,
    [string]$CodexHome = (Join-Path $HOME '.codex'),
    [string]$SessionId,
    [switch]$RequireServerLog,
    [switch]$RequireCleanGit
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\Aitc.Common.ps1')
$repo = Assert-AitcOfficialRepo -RepoPath $RepoPath
$meta = Get-AitcLatestCodexSessionMeta -CodexHome $CodexHome -RepoPath $repo
if ($SessionId -and $meta.SessionId -ne $SessionId) { throw "Latest session '$($meta.SessionId)' does not match requested '$SessionId'." }
if ($meta.Provider -ne 'thucchien') { throw "Provider proof failed: session_meta.model_provider='$($meta.Provider)'." }
Write-Host "[PASS] Provider proof: thucchien session=$(Mask-AitcValue $meta.SessionId)"
Write-Host "[PASS] Rollout: $($meta.RolloutPath)"

$events = @(Get-AitcLocalLogEvents -RepoPath $repo -SessionId $meta.SessionId)
foreach ($required in @('UserPromptSubmit', 'Stop')) {
    if (-not ($events -contains $required)) { throw "Local AI Log lacks $required for session $(Mask-AitcValue $meta.SessionId)." }
}
Write-Host "[PASS] Local AI Log events: $((($events | Sort-Object -Unique) -join ','))"

if ($RequireCleanGit) {
    Push-Location $repo
    try { $status = (& git status --porcelain=v1 | Out-String).Trim() } finally { Pop-Location }
    if ($status) { throw 'Official repository is dirty.' }
    Write-Host '[PASS] Official repository is clean.'
}

if ($RequireServerLog) {
    $settings = Get-AitcLogSettings -RepoPath $repo
    $uri = $settings.Server + '/entries?tool=codex'
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers @{ Authorization = "Bearer $($settings.Key)"; Accept = 'application/json' } -TimeoutSec 30
    $entries = Get-AitcProperty -Object $response -Name 'entries'
    if ($null -eq $entries -and $response -is [System.Array]) { $entries = $response }
    $sessionEntries = @($entries | Where-Object { [string](Get-AitcProperty -Object $_ -Name 'session_id') -eq $meta.SessionId })
    if ($sessionEntries.Count -eq 0) { throw 'BTC readback contains no entries for the verified session.' }
    $serverEvents = @($sessionEntries | ForEach-Object { [string](Get-AitcProperty -Object $_ -Name 'event') })
    foreach ($required in @('UserPromptSubmit', 'Stop')) {
        if (-not ($serverEvents -contains $required)) { throw "BTC readback lacks $required for the verified session." }
    }
    Write-Host "[PASS] BTC readback events: $((($serverEvents | Sort-Object -Unique) -join ','))"
}

Write-Host 'SESSION PREFLIGHT VERIFIED' -ForegroundColor Green
