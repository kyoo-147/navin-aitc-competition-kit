[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$RepoPath,
    [Parameter(Mandatory = $true)][string]$Model,
    [string]$CodexHome = (Join-Path $env:LOCALAPPDATA 'NAVIN-AITC\codex-home'),
    [Parameter(ValueFromRemainingArguments = $true)][string[]]$CodexArgs
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\Aitc.Common.ps1')
$repo = Assert-AitcOfficialRepo -RepoPath $RepoPath
$key = Get-AitcGatewayKey -RepoPath $repo
$configPath = Join-Path $CodexHome 'config.toml'
if (-not (Test-Path -LiteralPath $configPath)) { throw "Missing Codex config. Run bootstrap.ps1 first: $configPath" }
if (-not (Get-Command codex -ErrorAction SilentlyContinue)) { throw 'codex is not available on PATH.' }

$oldHome = $env:CODEX_HOME
$oldKey = $env:THUCCHIEN_API_KEY
$env:CODEX_HOME = $CodexHome
$env:THUCCHIEN_API_KEY = $key

Push-Location $repo
try {
    Write-Host "[PASS] Starting Codex at official repository root with model '$Model'."
    Write-Host '[INFO] Provider is fixed to thucchien in the private Codex config.'
    & codex -m $Model --dangerously-bypass-hook-trust @CodexArgs
    $exitCode = $LASTEXITCODE
} finally {
    Pop-Location
    $env:CODEX_HOME = $oldHome
    $env:THUCCHIEN_API_KEY = $oldKey
}
exit $exitCode
