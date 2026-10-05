[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
if (-not (Get-Command orca -ErrorAction SilentlyContinue)) { throw "Orca CLI not found in PATH." }

Write-Host "=== Orca status ==="
& orca status --json
if ($LASTEXITCODE -ne 0) { throw "orca status failed" }

Write-Host "=== Orca current worktree ==="
& orca worktree current --json
if ($LASTEXITCODE -ne 0) { throw "orca worktree current failed" }

Write-Host "=== Orca terminals ==="
& orca terminal list --json
if ($LASTEXITCODE -ne 0) { throw "orca terminal list failed" }

Write-Host "ORCA PREFLIGHT: PASS"
