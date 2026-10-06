[CmdletBinding()]
param(
    [string]$CodexHome = (Join-Path $HOME '.codex'),
    [string]$OutputPath = (Join-Path $PWD 'codex-safe-export'),
    [switch]$Apply
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\Portable.Common.ps1')
$allowlist = @('AGENTS.md','BUILD_PLAYBOOK.md','TASTE_UI.md')
Write-PortableStatus INFO 'Only documentation allowlist files can be exported. Config, hooks, auth, sessions, history, logs and databases are excluded.'
foreach ($name in $allowlist) {
    $source = Join-Path $CodexHome $name
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { Write-PortableStatus INFO "Skip missing $name"; continue }
    Assert-PortableSourceSafe $source
    $destination = Join-Path $OutputPath $name
    Write-PortableStatus PLAN "EXPORT $source -> $destination"
    if ($Apply) { Copy-PortableAtomic -Source $source -Destination $destination; Write-PortableStatus PASS "Exported $name" }
}
if (-not $Apply) { Write-PortableStatus 'USER ACTION REQUIRED' 'Review the allowlist, then rerun with -Apply.' }
