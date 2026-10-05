[CmdletBinding()]
param([string]$KitRoot)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($KitRoot)) { $KitRoot = Split-Path $PSScriptRoot -Parent }
$root = (Resolve-Path -LiteralPath $KitRoot).Path
$failures = New-Object System.Collections.Generic.List[string]
function Fail([string]$Message) { $script:failures.Add($Message); Write-Host "[FAIL] $Message" -ForegroundColor Red }
function Pass([string]$Message) { Write-Host "[PASS] $Message" }

$required = @(
    'README.md', 'AGENTS.md', 'RULES.md', 'MODEL_ROUTING.md', 'ORCA.md', 'CODEX-PROMPT-FLOW.md',
    'config\routing.json', 'config\budget.json', 'config\codex-config.template.toml', 'config\models-btc.snapshot.json',
    'knowledge\README.md', 'knowledge\model-registry.json', 'knowledge\routing-policy.json', 'knowledge\tracking-schema.json',
    'docs\OFFICIAL-REPO-BOUNDARY.md', 'docs\ENGINEERING.md', 'docs\ORCA-CODEX-FINDINGS.md', 'docs\CODEX-SCOPES-AND-PI-MIGRATION.md',
    'scripts\bootstrap.ps1', 'scripts\preflight.ps1', 'scripts\session-preflight.ps1', 'scripts\codex-runtime-refresh.ps1', 'scripts\codex-canary.ps1', 'scripts\budget.ps1',
    'scripts\model-query.ps1', 'scripts\spend-ledger.ps1',
    'scripts\start-codex.ps1', 'scripts\sync-variant.ps1',
    'templates\IMPLEMENTATION_CONTRACT.md', 'templates\codex-orca.cmd', 'MANIFEST.json'
)
foreach ($relative in $required) {
    if (-not (Test-Path -LiteralPath (Join-Path $root $relative) -PathType Leaf)) { Fail "Missing $relative" }
}
if ($failures.Count -eq 0) { Pass 'Required kit files exist' }

foreach ($relative in @('config\routing.json', 'config\budget.json', 'config\models-btc.snapshot.json', 'knowledge\model-registry.json', 'knowledge\routing-policy.json', 'knowledge\tracking-schema.json', 'MANIFEST.json')) {
    try { Get-Content -LiteralPath (Join-Path $root $relative) -Raw | ConvertFrom-Json | Out-Null; Pass "Valid JSON: $relative" }
    catch { Fail "Invalid JSON: $relative - $($_.Exception.Message)" }
}

$forbiddenNames = @(
    ('AITC_' + 'AGENT_KEY'),
    ('AITC_' + 'PRODUCT_KEY'),
    ('AITC_' + 'LOG_KEY')
)
$textFiles = Get-ChildItem -LiteralPath $root -File -Recurse | Where-Object { $_.Extension -in @('.md', '.ps1', '.toml', '.json', '.yaml', '.yml', '.txt') -and $_.FullName -notlike '*\references\source-material\*' }
foreach ($file in $textFiles) {
    $text = Get-Content -LiteralPath $file.FullName -Raw
    foreach ($name in $forbiddenNames) {
        if ($text.Contains($name)) { Fail "Deprecated credential name $name in $($file.FullName.Substring($root.Length + 1))" }
    }
    if ($text -match '(?im)^(THUCCHIEN_API_KEY|AI_LOG_API_KEY)\s*=\s*[^\s#][^\r\n]+$') {
        $line = ($matches[0] -split '=', 2)[1].Trim()
        if ($line) { Fail "Possible populated secret assignment in $($file.FullName.Substring($root.Length + 1))" }
    }
}
if (-not ($failures | Where-Object { $_ -like 'Deprecated credential*' -or $_ -like 'Possible populated secret*' })) { Pass 'Credential names and empty examples are safe' }

try {
    $manifest = Get-Content -LiteralPath (Join-Path $root 'MANIFEST.json') -Raw | ConvertFrom-Json
    $actualFiles = Get-ChildItem -LiteralPath $root -File -Recurse | Where-Object { $_.Name -ne 'MANIFEST.json' }
    if ([int]$manifest.file_count -ne @($actualFiles).Count) { Fail "Manifest count $($manifest.file_count) does not match $(@($actualFiles).Count) files" }
    $manifestMap = @{}
    foreach ($entry in $manifest.files) { $manifestMap[[string]$entry.path] = [string]$entry.sha256 }
    foreach ($file in $actualFiles) {
        $relative = $file.FullName.Substring($root.Length + 1).Replace('\', '/')
        $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
        if (-not $manifestMap.ContainsKey($relative)) { Fail "Manifest missing $relative" }
        elseif ($manifestMap[$relative] -ne $hash) { Fail "Manifest hash mismatch: $relative" }
    }
    if (-not ($failures | Where-Object { $_ -like 'Manifest*' })) { Pass 'Manifest count and hashes match' }
} catch { Fail "Manifest verification failed: $($_.Exception.Message)" }

if ($failures.Count -gt 0) {
    Write-Host "KIT VERIFICATION FAILED: $($failures.Count) issue(s)." -ForegroundColor Red
    exit 1
}
Write-Host 'KIT VERIFICATION PASSED' -ForegroundColor Green
