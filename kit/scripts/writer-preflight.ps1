[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$RepositoryRoot,
    [Parameter(Mandatory = $true)][string]$WorktreePath,
    [Parameter(Mandatory = $true)][string]$LockBaseSha
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path -LiteralPath $RepositoryRoot -ErrorAction Stop).Path
$worktree = (Resolve-Path -LiteralPath $WorktreePath -ErrorAction Stop).Path
$top = (& git -C $worktree rev-parse --show-toplevel 2>$null | Out-String).Trim()
if ([IO.Path]::GetFullPath($top).TrimEnd('\') -ne $worktree.TrimEnd('\')) { throw 'WRITER PREFLIGHT BLOCKED: worktree root is not Git top-level.' }
$head = (& git -C $worktree rev-parse HEAD 2>$null | Out-String).Trim()
if ($head -ne $LockBaseSha) { throw "WRITER PREFLIGHT BLOCKED: worktree HEAD '$head' must equal LOCK_BASE_SHA '$LockBaseSha'." }
$contract = Join-Path $worktree 'docs/PROJECT_CONTRACT.json'
$boundary = Join-Path $worktree 'contracts/app-contract.json'
foreach ($path in @($contract,$boundary)) { if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "WRITER PREFLIGHT BLOCKED: missing locked contract $path." } }
Write-Host "[PASS] Writer worktree is exactly LOCK_BASE_SHA=$LockBaseSha"
Write-Host '[PASS] Canonical and boundary contracts are present.'
Write-Host 'WRITER PREFLIGHT VERIFIED' -ForegroundColor Green
