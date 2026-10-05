[CmdletBinding()]
param(
    [string]$KitRoot,
    [string]$CodexHome = (Join-Path $env:LOCALAPPDATA 'NAVIN-AITC\codex-home')
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($KitRoot)) { $KitRoot = Split-Path $PSScriptRoot -Parent }
$source = Join-Path $KitRoot 'skills'
$target = Join-Path $CodexHome 'skills'
if (-not (Test-Path -LiteralPath $source -PathType Container)) { throw "Skills source not found: $source" }
New-Item -ItemType Directory -Force -Path $target | Out-Null

Get-ChildItem -LiteralPath $source -Directory | ForEach-Object {
    $destination = Join-Path $target $_.Name
    if (Test-Path -LiteralPath $destination) { Remove-Item -LiteralPath $destination -Recurse -Force }
    Copy-Item -LiteralPath $_.FullName -Destination $destination -Recurse
    Write-Host "[PASS] Installed skill: $($_.Name)"
}
Write-Host "[PASS] Skills installed to $target"
Write-Host '[INFO] Restart Codex sessions to load changed skills.'
