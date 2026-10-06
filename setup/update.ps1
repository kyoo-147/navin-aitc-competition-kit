[CmdletBinding()]
param(
    [ValidateSet('Normal','Aitc')][string]$Profile = 'Normal',
    [string]$CodexHome = (Join-Path $HOME '.codex'),
    [switch]$Apply,
    [switch]$ReplaceConfig,
    [switch]$InstallTools
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\Portable.Common.ps1')
$repo = Get-PortableRepoRoot
$status = & git -C $repo status --porcelain
if ($LASTEXITCODE -ne 0) { throw 'Cannot inspect kit Git status.' }
if (@($status).Count -gt 0) { throw 'Kit checkout is dirty. Preserve or commit local work before update.' }

Write-PortableStatus PLAN 'git fetch origin and git pull --ff-only'
if ($Apply) {
    & git -C $repo fetch origin
    if ($LASTEXITCODE -ne 0) { throw 'git fetch failed.' }
    & git -C $repo pull --ff-only
    if ($LASTEXITCODE -ne 0) { throw 'git pull --ff-only failed.' }
}

$args = @{ Profile=$Profile; CodexHome=$CodexHome }
if ($Apply) { $args.Apply = $true }
if ($ReplaceConfig) { $args.ReplaceConfig = $true }
if ($InstallTools) { $args.InstallTools = $true }
& (Join-Path $PSScriptRoot 'bootstrap.ps1') @args
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
