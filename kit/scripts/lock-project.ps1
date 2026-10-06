[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ProjectRoot,
    [Parameter(Mandatory = $true)][ValidateSet('OFFICIAL', 'DRILL')][string]$SessionMode,
    [Parameter(Mandatory = $true)][string]$ApprovedBy,
    [string]$OfficialRepository = 'https://github.com/ai-thuc-chien/aitc2026-team-918-navin-research'
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $ProjectRoot -ErrorAction Stop).Path
$required = @(
    'docs/PROJECT_CONTRACT.json', 'contracts/app-contract.json',
    'docs/PROJECT.md', 'docs/ARCHITECTURE.md', 'docs/UX_FLOW.md',
    'docs/DECISIONS.md', 'docs/TASKS.md',
    'artifacts/architecture.html', 'artifacts/ux-flow.html'
)
& (Join-Path $PSScriptRoot 'contract-validate.ps1') -ProjectRoot $root
& (Join-Path $PSScriptRoot 'lavish-offline-check.ps1') -ProjectRoot $root
$projectContract = Get-Content -LiteralPath (Join-Path $root 'docs\PROJECT_CONTRACT.json') -Raw | ConvertFrom-Json
$appContract = Get-Content -LiteralPath (Join-Path $root 'contracts\app-contract.json') -Raw | ConvertFrom-Json
if ($projectContract.screens.design_lock_required -eq $true) {
    $required += @('design/DESIGN_BRIEF.md','design/DESIGN_SYSTEM.md','design/SCREEN_CONTRACTS.md','design/COMPONENTS.md','design/TOKENS.css','design/DESIGN_LOCK.json')
}
if ([string]$projectContract.status -notin @('DRAFT','LOCKED')) { throw 'Cannot lock; invalid PROJECT_CONTRACT status.' }
if ([string]$appContract.status -notin @('DRAFT','LOCKED')) { throw 'Cannot lock; invalid app-contract status.' }
$gitHead = (& git -C $root rev-parse HEAD 2>$null | Out-String).Trim()
if ([string]::IsNullOrWhiteSpace($gitHead)) { throw 'Cannot lock; project is not at a valid Git commit.' }
foreach ($relative in $required) {
    & git -C $root ls-files --error-unmatch -- $relative 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Cannot lock; locked file is not tracked: $relative. Commit Human Lock files first." }
    $status = (& git -C $root status --porcelain=v1 -- $relative | Out-String).Trim()
    if ($status) { throw "Cannot lock; locked file is uncommitted or modified: $relative. Commit Human Lock before creating LOCK_BASE_SHA." }
}
Write-Host "[PASS] Human Lock files are tracked and clean at $gitHead"
$lockedFiles = foreach ($relative in $required) {
    $path = Join-Path $root ($relative.Replace('/', [IO.Path]::DirectorySeparatorChar))
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Cannot lock; missing $relative" }
    if ((Get-Item -LiteralPath $path).Length -eq 0) { throw "Cannot lock; empty $relative" }
    [ordered]@{ path = $relative; sha256 = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant() }
}
$now = [DateTime]::UtcNow.ToString('o')
$lock = [ordered]@{
    schema_version = 2
    session_mode = $SessionMode
    status = 'LOCKED'
    official_repository = $OfficialRepository
    brief = [ordered]@{ confirmed = $true; approved_by = $ApprovedBy; approved_at_utc = $now }
    architecture_lavish = [ordered]@{ status = 'LOCKED_BY_USER'; path = 'artifacts/architecture.html'; approved_by = $ApprovedBy; approved_at_utc = $now }
    ux_flow_lavish = [ordered]@{ status = 'LOCKED_BY_USER'; path = 'artifacts/ux-flow.html'; approved_by = $ApprovedBy; approved_at_utc = $now }
    contract = [ordered]@{ status = 'LOCKED'; approved_by = $ApprovedBy; approved_at_utc = $now }
    canonical_contract = [ordered]@{ status = 'LOCKED'; path = 'docs/PROJECT_CONTRACT.json'; approved_by = $ApprovedBy; approved_at_utc = $now }
    boundary_contract = [ordered]@{ status = 'LOCKED'; path = 'contracts/app-contract.json'; approved_by = $ApprovedBy; approved_at_utc = $now }
    boundary_contract = [ordered]@{ status = 'LOCKED'; path = 'contracts/app-contract.json'; approved_by = $ApprovedBy; approved_at_utc = $now }
    design = [ordered]@{ status = if ($projectContract.screens.design_lock_required -eq $true) { 'LOCKED' } else { 'SKIPPED' }; required = ($projectContract.screens.design_lock_required -eq $true); path = 'design/DESIGN_LOCK.json'; approved_by = $ApprovedBy; approved_at_utc = $now }
    base_commit = $gitHead
    locked_files = @($lockedFiles)
}
$lockPath = Join-Path $root 'docs/PROJECT_LOCK.json'
$utf8 = New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllText($lockPath, (($lock | ConvertTo-Json -Depth 8) + [Environment]::NewLine), $utf8)
Write-Host "[PASS] Project contract locked at $lockPath"
Write-Host "LOCK_BASE_SHA=$gitHead"
