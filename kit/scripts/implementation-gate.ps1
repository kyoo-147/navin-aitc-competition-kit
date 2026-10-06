[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ProjectRoot,
    [string]$RepositoryRoot,
    [string]$ExpectedOfficialRepository = 'ai-thuc-chien/aitc2026-team-918-navin-research'
)

$ErrorActionPreference = 'Stop'
$project = (Resolve-Path -LiteralPath $ProjectRoot -ErrorAction Stop).Path
if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = (& git -C $project rev-parse --show-toplevel 2>$null)
}
$repo = (Resolve-Path -LiteralPath $RepositoryRoot -ErrorAction Stop).Path
$lockPath = Join-Path $project 'docs/PROJECT_LOCK.json'
if (-not (Test-Path -LiteralPath $lockPath -PathType Leaf)) { throw 'IMPLEMENTATION BLOCKED: docs/PROJECT_LOCK.json is missing.' }
$lock = Get-Content -LiteralPath $lockPath -Raw | ConvertFrom-Json

$checks = @(
    @{ Ok = $lock.status -eq 'LOCKED'; Message = 'project status is LOCKED' },
    @{ Ok = $lock.brief.confirmed -eq $true; Message = 'brief is CONFIRMED' },
    @{ Ok = $lock.architecture_lavish.status -eq 'LOCKED_BY_USER'; Message = 'Architecture Lavish is LOCKED_BY_USER' },
    @{ Ok = $lock.ux_flow_lavish.status -eq 'LOCKED_BY_USER'; Message = 'UX Flow Lavish is LOCKED_BY_USER' },
    @{ Ok = $lock.contract.status -eq 'LOCKED'; Message = 'project contract is LOCKED' }
)
foreach ($check in $checks) {
    if (-not $check.Ok) { throw "IMPLEMENTATION BLOCKED: $($check.Message) failed." }
    Write-Host "[PASS] $($check.Message)"
}

foreach ($approval in @($lock.brief, $lock.architecture_lavish, $lock.ux_flow_lavish, $lock.contract)) {
    if ([string]::IsNullOrWhiteSpace([string]$approval.approved_by) -or [string]::IsNullOrWhiteSpace([string]$approval.approved_at_utc)) {
        throw 'IMPLEMENTATION BLOCKED: approval identity or timestamp is missing.'
    }
}
Write-Host '[PASS] Human approval evidence is present'

if ($lock.session_mode -eq 'OFFICIAL') {
    $remote = (& git -C $repo remote get-url origin 2>$null)
    if ($LASTEXITCODE -ne 0 -or $remote -notmatch [regex]::Escape($ExpectedOfficialRepository)) {
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
    'docs/PROJECT.md', 'docs/ARCHITECTURE.md', 'docs/UX_FLOW.md', 'docs/DECISIONS.md', 'docs/TASKS.md',
    [string]$lock.architecture_lavish.path, [string]$lock.ux_flow_lavish.path
)
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

Write-Host 'IMPLEMENTATION ALLOWED' -ForegroundColor Green
