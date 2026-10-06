[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$RepoPath,
    [Parameter(Mandatory = $true)][string]$ProjectRoot,
    [string]$CodexHome = (Join-Path $HOME '.codex'),
    [string]$SessionId
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\Aitc.Common.ps1')
$repo = Assert-AitcOfficialRepo -RepoPath $RepoPath
$current = [IO.Path]::GetFullPath((Get-Location).Path).TrimEnd('\')
if ($current -ne $repo.TrimEnd('\')) { throw "FINAL GATE BLOCKED: run from official repository root '$repo'; current '$current'." }
$origin = (& git -C $repo remote get-url origin 2>$null | Out-String).Trim()
if (-not $origin) { throw 'FINAL GATE BLOCKED: origin remote is missing.' }
$upstream = (& git -C $repo rev-parse '@{u}' 2>$null | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or -not $upstream) { throw 'FINAL GATE BLOCKED: current branch has no upstream.' }
$head = (& git -C $repo rev-parse HEAD 2>$null | Out-String).Trim()
& git -C $repo merge-base --is-ancestor $head $upstream
if ($LASTEXITCODE -ne 0) { throw "FINAL GATE BLOCKED: HEAD $head is not present in upstream $upstream. Push first." }
Write-Host "[PASS] Push proof: HEAD is present in $upstream"
$canaryPath = Join-Path (Resolve-Path -LiteralPath $ProjectRoot).Path 'evidence\integration-canary.json'
if (-not (Test-Path -LiteralPath $canaryPath -PathType Leaf)) { throw 'FINAL GATE BLOCKED: integration canary evidence is missing.' }
$canary = Get-Content -LiteralPath $canaryPath -Raw | ConvertFrom-Json
if ([string]$canary.status -ne 'VERIFIED' -or [string]::IsNullOrWhiteSpace([string]$canary.git_head)) { throw 'FINAL GATE BLOCKED: integration canary evidence is invalid.' }
& git -C $repo merge-base --is-ancestor ([string]$canary.git_head) $head
if ($LASTEXITCODE -ne 0) { throw 'FINAL GATE BLOCKED: verified integration canary commit is not an ancestor of current HEAD.' }
Write-Host '[PASS] Early integration canary is in current history.'
$submitOutput = (& python scripts\submit_log.py 2>&1 | Out-String)
if ($LASTEXITCODE -ne 0 -or $submitOutput -notmatch 'Submitted\s+\d+\s+entries.*202') {
    throw "FINAL GATE BLOCKED: AI Log submission did not return confirmed 202. Push remains valid but AI LOG is not verified.`n$submitOutput"
}
Write-Host '[PASS] AI Log submit returned 202.'
$sessionArgs = @{
    RepoPath = $repo
    CodexHome = $CodexHome
    RequireServerLog = $true
    RequireCleanGit = $true
}
if ($SessionId) { $sessionArgs.SessionId = $SessionId }
& (Join-Path $PSScriptRoot 'session-preflight.ps1') @sessionArgs
if ($LASTEXITCODE -ne 0) { throw 'FINAL GATE BLOCKED: same-session provider/log readback failed.' }
Write-Host '[PASS] Same-session BTC readback verified after push.'
Write-Host 'FINAL SUBMISSION GATE VERIFIED' -ForegroundColor Green
