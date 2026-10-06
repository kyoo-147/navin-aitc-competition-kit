[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$OfficialRepo,
    [Parameter(Mandatory = $true)][ValidateSet('OFFICIAL','DRILL')][string]$SessionMode,
    [string]$DestinationName = 'navin-competition-kit',
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
if ($SessionMode -eq 'OFFICIAL') { throw 'SYNC VARIANT BLOCKED: vendored competition kit, third-party skills, and templates are forbidden in the official submission repository.' }
. (Join-Path $PSScriptRoot 'lib\Aitc.Common.ps1')
$repo = Assert-AitcOfficialRepo -RepoPath $OfficialRepo
$source = Split-Path $PSScriptRoot -Parent
$destination = Join-Path (Join-Path $repo 'chung-khao') $DestinationName

if (Test-Path -LiteralPath $destination) {
    if (-not $Force) { throw "Destination exists. Review it or rerun with explicit -Force: $destination" }
    Remove-Item -LiteralPath $destination -Recurse -Force
}

$staging = $destination + '.staging'
if (Test-Path -LiteralPath $staging) { Remove-Item -LiteralPath $staging -Recurse -Force }
New-Item -ItemType Directory -Path $staging | Out-Null

$files = @('README.md', 'AGENTS.md', 'RULES.md', 'MODEL_ROUTING.md', 'ORCA.md', 'THIRD_PARTY_NOTES.md')
$directories = @('config', 'docs', 'licenses', 'runbook', 'scripts', 'skills', 'templates')
foreach ($file in $files) { Copy-Item -LiteralPath (Join-Path $source $file) -Destination $staging }
foreach ($directory in $directories) { Copy-Item -LiteralPath (Join-Path $source $directory) -Destination $staging -Recurse }

$marker = [ordered]@{
    installed_at_utc = [DateTime]::UtcNow.ToString('o')
    source = 'NAVIN AITC Competition Kit'
    source_manifest_sha256 = (Get-FileHash -LiteralPath (Join-Path $source 'MANIFEST.json') -Algorithm SHA256).Hash.ToLowerInvariant()
    excluded = @('references', 'tests')
} | ConvertTo-Json -Depth 4
$utf8 = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText((Join-Path $staging '.navin-kit-managed.json'), $marker + [Environment]::NewLine, $utf8)
Move-Item -LiteralPath $staging -Destination $destination
Write-Host "[PASS] Variant copied to $destination"
Write-Host '[USER ACTION REQUIRED] Review git status and diff before committing to the official repository.'
