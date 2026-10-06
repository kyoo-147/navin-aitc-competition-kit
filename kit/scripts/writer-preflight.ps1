[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$RepositoryRoot,
    [Parameter(Mandatory = $true)][string]$WorktreePath,
    [Parameter(Mandatory = $true)][string]$LockBaseSha,
    [Parameter(Mandatory = $true)][ValidateSet('OFFICIAL','DRILL')][string]$SessionMode,
    [string]$ProjectRelativeRoot
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\Aitc.Common.ps1')
$repo = (Resolve-Path -LiteralPath $RepositoryRoot -ErrorAction Stop).Path
$worktree = (Resolve-Path -LiteralPath $WorktreePath -ErrorAction Stop).Path
$top = (& git -C $worktree rev-parse --show-toplevel 2>$null | Out-String).Trim()
if ([IO.Path]::GetFullPath($top).TrimEnd('\') -ne $worktree.TrimEnd('\')) { throw 'WRITER PREFLIGHT BLOCKED: worktree root is not Git top-level.' }
$head = (& git -C $worktree rev-parse HEAD 2>$null | Out-String).Trim()
if ($head -ne $LockBaseSha) { throw "WRITER PREFLIGHT BLOCKED: worktree HEAD '$head' must equal LOCK_BASE_SHA '$LockBaseSha'." }
if ([string]::IsNullOrWhiteSpace($ProjectRelativeRoot)) { $ProjectRelativeRoot = if ($SessionMode -eq 'OFFICIAL') { 'chung-khao' } else { '.' } }
$project = if ($ProjectRelativeRoot -eq '.') { $worktree } else { Join-Path $worktree $ProjectRelativeRoot }
$actualRelativeRoot = Get-AitcProjectRelativeRoot -RepositoryRoot $worktree -ProjectRoot $project -SessionMode $SessionMode
if ($actualRelativeRoot -ne $ProjectRelativeRoot) { throw "WRITER PREFLIGHT BLOCKED: ProjectRelativeRoot '$ProjectRelativeRoot' is invalid." }
$contract = Join-Path $project 'docs/PROJECT_CONTRACT.json'
$boundary = Join-Path $project 'contracts/app-contract.json'
foreach ($path in @($contract,$boundary)) { if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "WRITER PREFLIGHT BLOCKED: missing locked contract $path." } }
Write-Host "[PASS] Writer worktree is exactly LOCK_BASE_SHA=$LockBaseSha"
Write-Host "[PASS] PROJECT_RELATIVE_ROOT=$ProjectRelativeRoot"
Write-Host '[PASS] Canonical and boundary contracts are present.'
Write-Host 'WRITER PREFLIGHT VERIFIED' -ForegroundColor Green
