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
    'docs/PROJECT.md',
    'docs/ARCHITECTURE.md',
    'docs/UX_FLOW.md',
    'docs/DECISIONS.md',
    'docs/TASKS.md',
    'artifacts/architecture.html',
    'artifacts/ux-flow.html'
)

$lockedFiles = foreach ($relative in $required) {
    $path = Join-Path $root ($relative.Replace('/', [IO.Path]::DirectorySeparatorChar))
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Cannot lock; missing $relative" }
    if ((Get-Item -LiteralPath $path).Length -eq 0) { throw "Cannot lock; empty $relative" }
    [ordered]@{
        path = $relative
        sha256 = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
    }
}

$now = [DateTime]::UtcNow.ToString('o')
$lock = [ordered]@{
    schema_version = 1
    session_mode = $SessionMode
    status = 'LOCKED'
    official_repository = $OfficialRepository
    brief = [ordered]@{ confirmed = $true; approved_by = $ApprovedBy; approved_at_utc = $now }
    architecture_lavish = [ordered]@{ status = 'LOCKED_BY_USER'; path = 'artifacts/architecture.html'; approved_by = $ApprovedBy; approved_at_utc = $now }
    ux_flow_lavish = [ordered]@{ status = 'LOCKED_BY_USER'; path = 'artifacts/ux-flow.html'; approved_by = $ApprovedBy; approved_at_utc = $now }
    contract = [ordered]@{ status = 'LOCKED'; approved_by = $ApprovedBy; approved_at_utc = $now }
    locked_files = @($lockedFiles)
}

$lockPath = Join-Path $root 'docs/PROJECT_LOCK.json'
$utf8 = New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllText($lockPath, (($lock | ConvertTo-Json -Depth 6) + [Environment]::NewLine), $utf8)
Write-Host "[PASS] Project contract locked at $lockPath"
Write-Host '[INFO] Run implementation-gate.ps1 before dispatching writers.'
