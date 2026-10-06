[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ProjectRoot,
    [switch]$RequireLocked
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $ProjectRoot -ErrorAction Stop).Path
$projectPath = Join-Path $root 'docs\PROJECT_CONTRACT.json'
$appPath = Join-Path $root 'contracts\app-contract.json'
foreach ($path in @($projectPath, $appPath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "CONTRACT INVALID: missing $path" }
}
try { $project = Get-Content -LiteralPath $projectPath -Raw | ConvertFrom-Json }
catch { throw "CONTRACT INVALID: PROJECT_CONTRACT.json is not valid JSON: $($_.Exception.Message)" }
try { $app = Get-Content -LiteralPath $appPath -Raw | ConvertFrom-Json }
catch { throw "CONTRACT INVALID: app-contract.json is not valid JSON: $($_.Exception.Message)" }

if ([int]$project.schema_version -lt 2) { throw 'CONTRACT INVALID: PROJECT_CONTRACT schema_version must be 2 or newer.' }
foreach ($name in @('challenge','requirements','scope','architecture','interfaces','screens','decisions','acceptance','tasks')) {
    if ($null -eq $project.PSObject.Properties[$name] -or $null -eq $project.$name) { throw "CONTRACT INVALID: PROJECT_CONTRACT missing $name." }
}
if ([string]$project.interfaces.boundary_contract -ne 'contracts/app-contract.json') { throw 'CONTRACT INVALID: interfaces.boundary_contract must be contracts/app-contract.json.' }
if ([string]$project.interfaces.boundary_contract -ne 'contracts/app-contract.json') { throw 'CONTRACT INVALID: interfaces.boundary_contract must be contracts/app-contract.json.' }
if ($project.screens.design_lock_required -eq $true) {
    foreach ($name in @('brief','system','screens','components','tokens','lock')) {
        if ([string]::IsNullOrWhiteSpace([string]$project.screens.design_contract.$name)) { throw "CONTRACT INVALID: design_contract.$name is required when design_lock_required is true." }
    }
}
if ([int]$app.schema_version -lt 1) { throw 'CONTRACT INVALID: app-contract schema_version must be 1 or newer.' }
foreach ($name in @('routes','requests','responses','states','errors')) {
    if ($null -eq $app.PSObject.Properties[$name] -or $null -eq $app.$name) { throw "CONTRACT INVALID: app-contract missing $name." }
}
if ($null -eq $app.errors.shape -or $null -eq $app.errors.shape.code -or $null -eq $app.errors.shape.message) {
    throw 'CONTRACT INVALID: app-contract errors.shape must define code and message.'
}
if ($RequireLocked) {
    if ([string]$project.status -ne 'LOCKED') { throw 'CONTRACT INVALID: PROJECT_CONTRACT status is not LOCKED.' }
    if ([string]$app.status -ne 'LOCKED') { throw 'CONTRACT INVALID: app-contract status is not LOCKED.' }
}
Write-Host '[PASS] Canonical PROJECT_CONTRACT.json is valid.'
Write-Host '[PASS] Boundary contracts/app-contract.json is valid.'
Write-Host 'CONTRACT VALIDATED' -ForegroundColor Green
