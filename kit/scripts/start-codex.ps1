[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$RepoPath,
    [Parameter(Mandatory = $true)][string]$Model,
    [string]$CodexHome = (Join-Path $HOME '.codex'),
    [string]$RouteEvidencePath,
    [Parameter(ValueFromRemainingArguments = $true)][string[]]$CodexArgs
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\Aitc.Common.ps1')
$repo = Assert-AitcOfficialRepo -RepoPath $RepoPath
$key = Get-AitcGatewayKey -RepoPath $repo
$configPath = Join-Path $CodexHome 'config.toml'
if (-not (Test-Path -LiteralPath $configPath)) { throw "Missing Codex config. Run bootstrap.ps1 first: $configPath" }
$codex = Get-AitcCodexCommand
$runtimeScript = Join-Path $PSScriptRoot 'codex-runtime-refresh.ps1'
if ([string]::IsNullOrWhiteSpace($RouteEvidencePath)) {
    $safeModel = $Model -replace '[^A-Za-z0-9._-]', '_'
    $RouteEvidencePath = Join-Path $repo "chung-khao\evidence\routes\$safeModel-responses-codex.json"
}
& (Join-Path $PSScriptRoot 'route-compatibility.ps1') -Model $Model -Endpoint responses -Harness codex -SmokeEvidencePath $RouteEvidencePath

$oldHome = $env:CODEX_HOME
$oldKey = $env:THUCCHIEN_API_KEY
$env:CODEX_HOME = $CodexHome
$env:THUCCHIEN_API_KEY = $key

Push-Location $repo
try {
    Invoke-AitcCodexRuntimeRefresh -CodexHome $CodexHome -RuntimeScript $runtimeScript | Out-Null
    Write-Host "[PASS] Starting Codex at official repository root with model '$Model'."
    Write-Host '[INFO] Provider proof comes from the resulting rollout session_meta, not the picker label.'
    & $codex --dangerously-bypass-approvals-and-sandbox --dangerously-bypass-hook-trust -m $Model @CodexArgs
    $exitCode = $LASTEXITCODE
} finally {
    Pop-Location
    $env:CODEX_HOME = $oldHome
    $env:THUCCHIEN_API_KEY = $oldKey
}
exit $exitCode
