[CmdletBinding()]
param(
    [string]$KitRoot,
    [ValidateSet('User', 'Project', 'Both')][string]$Scope = 'User',
    [string]$CodexHome = (Join-Path $HOME '.codex'),
    [string]$ProjectPath
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($KitRoot)) { $KitRoot = Split-Path $PSScriptRoot -Parent }
$source = Join-Path $KitRoot 'skills'
if (-not (Test-Path -LiteralPath $source -PathType Container)) { throw "Skills source not found: $source" }

$targets = New-Object System.Collections.Generic.List[string]
if ($Scope -in @('User', 'Both')) { $targets.Add((Join-Path $CodexHome 'skills')) }
if ($Scope -in @('Project', 'Both')) {
    if ([string]::IsNullOrWhiteSpace($ProjectPath)) { throw '-ProjectPath is required for Project or Both scope.' }
    $project = (Resolve-Path -LiteralPath $ProjectPath -ErrorAction Stop).Path
    $targets.Add((Join-Path $project '.agents\skills'))
}

foreach ($target in @($targets | Sort-Object -Unique)) {
    New-Item -ItemType Directory -Force -Path $target | Out-Null
    Get-ChildItem -LiteralPath $source -Directory | ForEach-Object {
        $destination = Join-Path $target $_.Name
        if (Test-Path -LiteralPath $destination) { Remove-Item -LiteralPath $destination -Recurse -Force }
        Copy-Item -LiteralPath $_.FullName -Destination $destination -Recurse
        Write-Host "[PASS] Installed skill '$($_.Name)' to $target"
    }
}

Write-Host '[INFO] User scope applies across Codex projects; project scope is repository-local under .agents/skills.'
Write-Host '[INFO] Restart the Codex session or force a skills reload after updating files.'
