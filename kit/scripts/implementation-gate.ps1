[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ProjectRoot,
    [string]$RepositoryRoot,
    [string]$ExpectedOfficialRepository = 'ai-thuc-chien/aitc2026-team-918-navin-research'
)

$ErrorActionPreference = 'Stop'
$project = (Resolve-Path -LiteralPath $ProjectRoot -ErrorAction Stop).Path
. (Join-Path (Split-Path $PSScriptRoot -Parent) 'scripts\lib\Aitc.Common.ps1')
if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = (& git -C $project rev-parse --show-toplevel 2>$null)
}
$repo = (Resolve-Path -LiteralPath $RepositoryRoot -ErrorAction Stop).Path
$lockPath = Join-Path $project 'docs/PROJECT_LOCK.json'
if (-not (Test-Path -LiteralPath $lockPath -PathType Leaf)) { throw 'IMPLEMENTATION BLOCKED: docs/PROJECT_LOCK.json is missing.' }
$lock = Get-Content -LiteralPath $lockPath -Raw | ConvertFrom-Json

$checks = @(
    @{ Ok = [int]$lock.schema_version -ge 2; Message = 'lock schema is v2 or newer' },
    @{ Ok = $lock.status -eq 'LOCKED'; Message = 'project status is LOCKED' },
    @{ Ok = $lock.brief.confirmed -eq $true; Message = 'brief is CONFIRMED' },
    @{ Ok = $lock.architecture_lavish.status -eq 'LOCKED_BY_USER'; Message = 'Architecture Lavish is LOCKED_BY_USER' },
    @{ Ok = $lock.ux_flow_lavish.status -eq 'LOCKED_BY_USER'; Message = 'UX Flow Lavish is LOCKED_BY_USER' },
    @{ Ok = $lock.contract.status -eq 'LOCKED'; Message = 'project contract is LOCKED' },
    @{ Ok = $lock.canonical_contract.status -eq 'LOCKED'; Message = 'canonical JSON contract is LOCKED' },
    @{ Ok = $lock.boundary_contract.status -eq 'LOCKED'; Message = 'application boundary contract is LOCKED' },
    @{ Ok = ($lock.design.required -ne $true -or $lock.design.status -eq 'LOCKED'); Message = 'design contract is LOCKED when UI is required' }
)
foreach ($check in $checks) {
    if (-not $check.Ok) { throw "IMPLEMENTATION BLOCKED: $($check.Message) failed." }
    Write-Host "[PASS] $($check.Message)"
}

foreach ($approval in @($lock.brief, $lock.architecture_lavish, $lock.ux_flow_lavish, $lock.contract, $lock.canonical_contract, $lock.boundary_contract, $lock.design)) {
    if ([string]::IsNullOrWhiteSpace([string]$approval.approved_by) -or [string]::IsNullOrWhiteSpace([string]$approval.approved_at_utc)) {
        throw 'IMPLEMENTATION BLOCKED: approval identity or timestamp is missing.'
    }
}
Write-Host '[PASS] Human approval evidence is present'

if ($lock.session_mode -eq 'OFFICIAL') {
    $remote = (& git -C $repo remote get-url origin 2>$null)
    if ($LASTEXITCODE -ne 0 -or -not (Test-AitcOfficialOrigin -Origin $remote)) {
        throw "IMPLEMENTATION BLOCKED: OFFICIAL mode requires origin $ExpectedOfficialRepository; found '$remote'."
    }
    $officialBoundary = [IO.Path]::GetFullPath((Join-Path $repo 'chung-khao')).TrimEnd('\')
    $candidate = [IO.Path]::GetFullPath($project).TrimEnd('\')
    if ($candidate -ne $officialBoundary -and -not $candidate.StartsWith($officialBoundary + '\', [StringComparison]::OrdinalIgnoreCase)) {
        throw "IMPLEMENTATION BLOCKED: OFFICIAL project must be under '$officialBoundary'; found '$candidate'."
    }
    Write-Host '[PASS] Official repository and chung-khao boundary verified'
} elseif ($lock.session_mode -ne 'DRILL') {
    throw "IMPLEMENTATION BLOCKED: session_mode must be OFFICIAL or DRILL, found '$($lock.session_mode)'."
}

$requiredPaths = @(
    'docs/PROJECT_CONTRACT.json', 'contracts/app-contract.json',
    'docs/PROJECT.md', 'docs/ARCHITECTURE.md', 'docs/UX_FLOW.md', 'docs/DECISIONS.md', 'docs/TASKS.md',
    [string]$lock.architecture_lavish.path, [string]$lock.ux_flow_lavish.path
)
if ($lock.design.required -eq $true) {
    $requiredPaths += @('design/DESIGN_BRIEF.md','design/DESIGN_SYSTEM.md','design/SCREEN_CONTRACTS.md','design/COMPONENTS.md','design/TOKENS.css','design/DESIGN_LOCK.json')
}
$entries = @($lock.locked_files)
foreach ($relative in $requiredPaths | Select-Object -Unique) {
    $entry = $entries | Where-Object { $_.path -eq $relative } | Select-Object -First 1
    if ($null -eq $entry) { throw "IMPLEMENTATION BLOCKED: lock has no hash for $relative." }
    $path = Join-Path $project ($relative.Replace('/', [IO.Path]::DirectorySeparatorChar))
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "IMPLEMENTATION BLOCKED: missing locked file $relative." }
    $actual = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actual -ne [string]$entry.sha256) { throw "IMPLEMENTATION BLOCKED: locked file changed: $relative." }
    Write-Host "[PASS] Locked hash verified: $relative"
}

& (Join-Path $PSScriptRoot 'contract-validate.ps1') -ProjectRoot $project -RequireLocked
foreach ($relative in $requiredPaths | Select-Object -Unique) {
    $trackedPath = $relative.Replace('\','/')
    & git -C $repo ls-files --error-unmatch -- $trackedPath 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "IMPLEMENTATION BLOCKED: locked file is not tracked: $relative." }
    $status = (& git -C $repo status --porcelain=v1 -- $trackedPath | Out-String).Trim()
    if ($status) { throw "IMPLEMENTATION BLOCKED: locked file is uncommitted or modified: $relative." }
}
& (Join-Path $PSScriptRoot 'lavish-offline-check.ps1') -ProjectRoot $project
if ([string]::IsNullOrWhiteSpace([string]$lock.base_commit)) { throw 'IMPLEMENTATION BLOCKED: lock base_commit is missing.' }
& git -C $repo diff --quiet ([string]$lock.base_commit) -- $requiredPaths
if ($LASTEXITCODE -ne 0) { throw 'IMPLEMENTATION BLOCKED: locked files differ from LOCK_BASE_SHA.' }
& git -C $repo merge-base --is-ancestor ([string]$lock.base_commit) HEAD
if ($LASTEXITCODE -ne 0) { throw 'IMPLEMENTATION BLOCKED: LOCK_BASE_SHA is not an ancestor of current HEAD.' }
Write-Host "[PASS] LOCK_BASE_SHA=$($lock.base_commit)"
Write-Host 'IMPLEMENTATION ALLOWED' -ForegroundColor Green
Write-Host "LOCK_BASE_SHA=$($lock.base_commit)"
