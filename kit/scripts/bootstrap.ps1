[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$RepoPath,
    [Parameter(Mandatory = $true)][string]$Model,
    [ValidateSet('none', 'minimal', 'low', 'medium', 'high', 'xhigh')][string]$Reasoning,
    [string]$CodexHome = (Join-Path $HOME '.codex'),
    [string]$ModelCatalogPath,
    [switch]$InstallPythonDotenv,
    [switch]$InstallSkills,
    [switch]$ForceConfig
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\Aitc.Common.ps1')
$repo = Assert-AitcOfficialRepo -RepoPath $RepoPath
$kitRoot = Split-Path $PSScriptRoot -Parent
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

if ($InstallPythonDotenv) {
    & python -m pip install python-dotenv
    if ($LASTEXITCODE -ne 0) { throw 'python-dotenv installation failed.' }
}

$envPath = Join-Path $repo '.env'
if (-not (Test-Path -LiteralPath $envPath)) {
    $example = Join-Path $repo '.env.example'
    if (-not (Test-Path -LiteralPath $example)) { throw 'Official clone is missing .env.example.' }
    Copy-Item -LiteralPath $example -Destination $envPath
}
$envText = [System.IO.File]::ReadAllText($envPath)
$append = @()
if ($envText -notmatch '(?m)^THUCCHIEN_API_KEY=') { $append += 'THUCCHIEN_API_KEY=' }
if ($envText -notmatch '(?m)^AITC_MODEL=') { $append += "AITC_MODEL=$Model" }
if ($append.Count -gt 0) {
    $newText = $envText.TrimEnd("`r", "`n") + [Environment]::NewLine + ($append -join [Environment]::NewLine) + [Environment]::NewLine
    [System.IO.File]::WriteAllText($envPath, $newText, $utf8NoBom)
}

Push-Location $repo
try {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $repo 'scripts\setup_hooks.ps1')
    if ($LASTEXITCODE -ne 0) { throw 'Organizer setup_hooks.ps1 failed.' }
} finally { Pop-Location }

$hookPath = Join-Path $repo '.git\hooks\pre-push'
if (-not (Test-Path -LiteralPath $hookPath)) { throw 'Pre-push hook was not created.' }
$hookText = [System.IO.File]::ReadAllText($hookPath)
[System.IO.File]::WriteAllText($hookPath, $hookText, $utf8NoBom)

New-Item -ItemType Directory -Path $CodexHome -Force | Out-Null
if ([string]::IsNullOrWhiteSpace($ModelCatalogPath)) { $ModelCatalogPath = Join-Path $CodexHome 'models-btc.json' }
if (-not (Test-Path -LiteralPath $ModelCatalogPath -PathType Leaf)) {
    Copy-Item -LiteralPath (Join-Path $kitRoot 'config\models-btc.snapshot.json') -Destination $ModelCatalogPath
    Write-Host '[INFO] Installed the dated BTC catalog snapshot; live canary and current BTC documentation remain authoritative.'
}
$resolvedCatalog = (Resolve-Path -LiteralPath $ModelCatalogPath -ErrorAction Stop).Path.Replace('\', '/')
$configPath = Join-Path $CodexHome 'config.toml'
if ($ForceConfig -or -not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
    $template = Get-Content -LiteralPath (Join-Path $kitRoot 'config\codex-config.template.toml') -Raw
    $reasoningLine = if ($Reasoning) { "model_reasoning_effort = `"$Reasoning`"" } else { '' }
    $config = $template.Replace('__MODEL__', $Model).Replace('__REASONING_LINE__', $reasoningLine).Replace('__MODEL_CATALOG_JSON__', $resolvedCatalog)
    [System.IO.File]::WriteAllText($configPath, $config, $utf8NoBom)
    Write-Host "[PASS] Wrote BTC Codex config: $configPath"
} else {
    Write-Host "[INFO] Preserved existing Codex config: $configPath"
}

$runtimeSource = Join-Path $PSScriptRoot 'codex-runtime-refresh.ps1'
$runtimeTarget = Join-Path $CodexHome 'codex-runtime-refresh.ps1'
Copy-Item -LiteralPath $runtimeSource -Destination $runtimeTarget -Force
$codexCommand = Get-AitcCodexCommand
$wrapperTemplate = Get-Content -LiteralPath (Join-Path $kitRoot 'templates\codex-orca.cmd') -Raw
$wrapper = $wrapperTemplate.Replace('__CODEX_HOME__', $CodexHome).Replace('__CODEX_CMD__', $codexCommand)
$wrapperPath = Join-Path $CodexHome 'codex-orca.cmd'
[System.IO.File]::WriteAllText($wrapperPath, $wrapper, $utf8NoBom)

if ($InstallSkills) {
    & (Join-Path $PSScriptRoot 'install-skills.ps1') -KitRoot $kitRoot -Scope User -CodexHome $CodexHome
    if ($LASTEXITCODE -ne 0) { throw 'Skill installation failed.' }
}

Write-Host '[PASS] Organizer pre-push hook installed and normalized to UTF-8 without BOM.'
Write-Host "[PASS] Runtime refresh and Orca wrapper installed to $CodexHome"
Write-Host '[INFO] AI Log hooks remain project-local in the official repository; existing user hooks are preserved.'
Write-Host '[USER ACTION REQUIRED] Populate THUCCHIEN_API_KEY and AI_LOG_API_KEY in the official clone''s ignored .env or current process.'
Write-Host '[USER ACTION REQUIRED] Run preflight and the logged canary before competition model work.'
