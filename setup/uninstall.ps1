[CmdletBinding()]
param(
    [string]$CodexHome = (Join-Path $HOME '.codex'),
    [switch]$Apply
)

$ErrorActionPreference = 'Stop'
$rollback = Join-Path $PSScriptRoot 'rollback.ps1'
if ($Apply) { & $rollback -CodexHome $CodexHome -Apply }
else { & $rollback -CodexHome $CodexHome }
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host '[INFO] CLI packages are intentionally preserved. Remove them explicitly only when no other project uses them.'
