[CmdletBinding()]
param(
    [string]$CodexHome = (Join-Path $HOME '.codex'),
    [switch]$Apply
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\Portable.Common.ps1')
$codex = [IO.Path]::GetFullPath($CodexHome)
$statePath = Get-PortableInstallStatePath $codex
if (-not (Test-Path -LiteralPath $statePath -PathType Leaf)) { throw "Install state missing: $statePath" }
$state = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
$currentBackup = Join-Path $codex ("backups\navin-kit\rollback-current-" + (Get-PortableTimestamp))

foreach ($entry in @($state.entries) | Sort-Object { ([string]$_.path).Length } -Descending) {
    $action = if ($entry.existed_before) { 'RESTORE' } else { 'REMOVE_CREATED' }
    Write-PortableStatus PLAN "$action $($entry.path)"
    if (-not $Apply) { continue }

    if (Test-Path -LiteralPath $entry.path) {
        $relative = ([string]$entry.path).Substring($codex.TrimEnd('\').Length).TrimStart('\')
        $safety = Join-Path $currentBackup $relative
        New-Item -ItemType Directory -Force -Path (Split-Path $safety -Parent) | Out-Null
        Copy-Item -LiteralPath $entry.path -Destination $safety -Recurse -Force
        Remove-Item -LiteralPath $entry.path -Recurse -Force
    }
    if ($entry.existed_before) {
        if ([string]::IsNullOrWhiteSpace([string]$entry.backup) -or -not (Test-Path -LiteralPath $entry.backup)) {
            throw "Cannot restore missing backup for $($entry.path)"
        }
        New-Item -ItemType Directory -Force -Path (Split-Path ([string]$entry.path) -Parent) | Out-Null
        Copy-Item -LiteralPath $entry.backup -Destination $entry.path -Recurse -Force
    }
    Write-PortableStatus PASS "$action $($entry.path)"
}

if (-not $Apply) {
    Write-PortableStatus 'USER ACTION REQUIRED' 'Review the rollback plan, then rerun with -Apply.'
    exit 0
}
Move-Item -LiteralPath $statePath -Destination ($statePath + '.rolled-back-' + (Get-PortableTimestamp)) -Force
Write-PortableStatus PASS "Rollback complete. Pre-rollback files were preserved at $currentBackup"
