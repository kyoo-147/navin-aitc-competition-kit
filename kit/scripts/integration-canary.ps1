[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ProjectRoot,
    [string]$RepositoryRoot,
    [Parameter(Mandatory = $true)][string]$FrontendProof,
    [Parameter(Mandatory = $true)][string]$BackendEndpoint,
    [Parameter(Mandatory = $true)][string]$Command,
    [string]$AiOrApiProof = 'not_required',
    [string]$EvidencePath
)

$ErrorActionPreference = 'Stop'
$project = (Resolve-Path -LiteralPath $ProjectRoot -ErrorAction Stop).Path
if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) { $RepositoryRoot = (& git -C $project rev-parse --show-toplevel 2>$null).Trim() }
$repo = (Resolve-Path -LiteralPath $RepositoryRoot -ErrorAction Stop).Path
$current = [IO.Path]::GetFullPath((Get-Location).Path).TrimEnd('\')
if ($current -ne $repo.TrimEnd('\')) { throw "INTEGRATION CANARY BLOCKED: run from repository root '$repo'; current '$current'." }
& (Join-Path $PSScriptRoot 'contract-validate.ps1') -ProjectRoot $project -RequireLocked
& (Join-Path $PSScriptRoot 'implementation-gate.ps1') -ProjectRoot $project -RepositoryRoot $repo
$started = [DateTime]::UtcNow
$commandOutput = (& cmd.exe /d /s /c $Command 2>&1 | Out-String)
$exitCode = $LASTEXITCODE
if ($exitCode -ne 0) { throw "INTEGRATION CANARY FAILED: command exit $exitCode.`n$commandOutput" }
$head = (& git -C $repo rev-parse HEAD 2>$null).Trim()
if ([string]::IsNullOrWhiteSpace($EvidencePath)) { $EvidencePath = Join-Path $project 'evidence\integration-canary.json' }
$sha = New-Object Security.Cryptography.SHA256Managed
$outputHash = (($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($commandOutput)) | ForEach-Object { $_.ToString('x2') }) -join '')
$sha.Dispose()
$evidence = [ordered]@{
    schema_version = 1
    status = 'VERIFIED'
    verified_at_utc = [DateTime]::UtcNow.ToString('o')
    duration_seconds = [Math]::Round(([DateTime]::UtcNow - $started).TotalSeconds, 3)
    repository_root = $repo
    project_root = $project
    git_head = $head
    frontend_proof = $FrontendProof
    backend_endpoint = $BackendEndpoint
    ai_or_api_proof = $AiOrApiProof
    command = $Command
    exit_code = $exitCode
    output_sha256 = $outputHash
}
$parent = Split-Path $EvidencePath -Parent
if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
[IO.File]::WriteAllText($EvidencePath, (($evidence | ConvertTo-Json -Depth 5) + [Environment]::NewLine), (New-Object Text.UTF8Encoding($false)))
Write-Host '[PASS] Real vertical-slice command completed.'
Write-Host "[PASS] Frontend proof: $FrontendProof"
Write-Host "[PASS] Backend endpoint: $BackendEndpoint"
Write-Host "[PASS] Evidence: $EvidencePath"
Write-Host 'INTEGRATION CANARY VERIFIED' -ForegroundColor Green
