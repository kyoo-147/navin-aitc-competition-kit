[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$RepoPath,
    [Parameter(Mandatory = $true)][string]$Model,
    [string]$CodexHome = (Join-Path $env:LOCALAPPDATA 'NAVIN-AITC\codex-home')
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\Aitc.Common.ps1')
$repo = Assert-AitcOfficialRepo -RepoPath $RepoPath
$key = Get-AitcGatewayKey -RepoPath $repo
$logSettings = Get-AitcLogSettings -RepoPath $repo
if (-not (Get-Command codex -ErrorAction SilentlyContinue)) { throw 'codex is not available on PATH.' }
if (-not (Test-Path -LiteralPath (Join-Path $CodexHome 'config.toml'))) { throw 'Missing private Codex config. Run bootstrap.ps1.' }
if (-not (Test-Path -LiteralPath (Join-Path $CodexHome 'hooks.json'))) { throw 'Missing private Codex hooks. Run bootstrap.ps1.' }

$nonce = [Guid]::NewGuid().ToString('N').Substring(0, 12)
$marker = "AITC_CANARY_OK_$nonce"
$prompt = "Reply with exactly $marker. Do not read files and do not call tools."
$oldHome = $env:CODEX_HOME
$oldGateway = $env:THUCCHIEN_API_KEY
$env:CODEX_HOME = $CodexHome
$env:THUCCHIEN_API_KEY = $key

Push-Location $repo
try {
    $codexOutput = (& codex exec --dangerously-bypass-hook-trust -m $Model $prompt 2>&1 | Out-String)
    if ($LASTEXITCODE -ne 0) { throw "Codex canary failed with exit code $LASTEXITCODE." }
    if ($codexOutput -notmatch [regex]::Escape($marker)) { throw 'Codex canary response did not contain the expected marker.' }

    $submitOutput = (& python scripts\submit_log.py 2>&1 | Out-String)
    if ($submitOutput -notmatch 'Submitted\s+\d+\s+entries.*202') {
        throw 'AI Log submission was not confirmed with status 202. Pending logs were preserved by the organizer script.'
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
$promptEntry = @($entries | Where-Object { ([string](Get-AitcProperty -Object $_ -Name 'prompt')).Contains($marker) } | Select-Object -First 1)
if ($promptEntry.Count -eq 0) { throw 'Canary UserPromptSubmit event was not found on the BTC server.' }
$sessionId = [string](Get-AitcProperty -Object $promptEntry[0] -Name 'session_id')
if ([string]::IsNullOrWhiteSpace($sessionId)) { throw 'Canary server entry is missing session_id.' }
$sessionEvents = @($entries | Where-Object { [string](Get-AitcProperty -Object $_ -Name 'session_id') -eq $sessionId } | ForEach-Object { [string](Get-AitcProperty -Object $_ -Name 'event') })
if (-not ($sessionEvents -contains 'UserPromptSubmit')) { throw 'Canary session is missing UserPromptSubmit.' }
if (-not ($sessionEvents -contains 'Stop')) { throw 'Canary session is missing Stop.' }

Write-Host "[PASS] Codex Gateway canary returned the expected marker using model '$Model'."
Write-Host '[PASS] AI Log submission returned 202.'
Write-Host "[PASS] BTC server readback contains UserPromptSubmit and Stop for session $(Mask-AitcValue $sessionId)."
Write-Host 'CODEX CANARY VERIFIED' -ForegroundColor Green
