[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$RepoPath,
    [Parameter(Mandatory = $true)][string]$Model,
    [ValidateSet('low', 'medium', 'high', 'xhigh')][string]$Reasoning,
    [string]$CodexHome = (Join-Path $env:LOCALAPPDATA 'NAVIN-AITC\codex-home'),
    [switch]$InstallPythonDotenv,
    [switch]$InstallSkills
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\Aitc.Common.ps1')
$repo = Assert-AitcOfficialRepo -RepoPath $RepoPath
$kitRoot = Split-Path $PSScriptRoot -Parent

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
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    $newText = $envText.TrimEnd("`r", "`n") + [Environment]::NewLine + ($append -join [Environment]::NewLine) + [Environment]::NewLine
    [System.IO.File]::WriteAllText($envPath, $newText, $utf8)
}

Push-Location $repo
try {
    & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $repo 'scripts\setup_hooks.ps1')
    if ($LASTEXITCODE -ne 0) { throw 'Organizer setup_hooks.ps1 failed.' }
} finally {
    Pop-Location
}

$hookPath = Join-Path $repo '.git\hooks\pre-push'
if (-not (Test-Path -LiteralPath $hookPath)) { throw 'Pre-push hook was not created.' }
$hookText = [System.IO.File]::ReadAllText($hookPath)
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($hookPath, $hookText, $utf8NoBom)

New-Item -ItemType Directory -Path $CodexHome -Force | Out-Null
$template = Get-Content -LiteralPath (Join-Path $kitRoot 'config\codex-config.template.toml') -Raw
$reasoningLine = if ($Reasoning) { "model_reasoning_effort = `"$Reasoning`"" } else { '' }
$config = $template.Replace('__MODEL__', $Model).Replace('__REASONING_LINE__', $reasoningLine)
[System.IO.File]::WriteAllText((Join-Path $CodexHome 'config.toml'), $config, $utf8NoBom)

$wrapperPath = Join-Path $CodexHome 'aitc-codex-hook-silent.sh'
$hookErrorPath = (Join-Path $CodexHome 'hook-errors.log').Replace('\', '/')
$wrapper = @"
#!/usr/bin/env bash
set -u
bash scripts/_pyrun.sh scripts/log_hook.py --tool=codex >/dev/null 2>>'$hookErrorPath'
"@
[System.IO.File]::WriteAllText($wrapperPath, $wrapper, $utf8NoBom)
$wrapperForCommand = $wrapperPath.Replace('\', '/')
$hookCommand = "bash '$wrapperForCommand'"
$eventHooks = @{}
foreach ($event in @('UserPromptSubmit', 'PostToolUse', 'Stop')) {
    $eventHooks[$event] = @(@{ hooks = @(@{ name = "aitc-log-$($event.ToLowerInvariant())"; type = 'command'; command = $hookCommand; timeout = 10 }) })
}
$hooksJson = @{ hooks = $eventHooks } | ConvertTo-Json -Depth 8
[System.IO.File]::WriteAllText((Join-Path $CodexHome 'hooks.json'), $hooksJson + [Environment]::NewLine, $utf8NoBom)

if ($InstallSkills) {
    & (Join-Path $PSScriptRoot 'install-skills.ps1') -KitRoot $kitRoot -CodexHome $CodexHome
    if ($LASTEXITCODE -ne 0) { throw 'Skill installation failed.' }
}

Write-Host '[PASS] Organizer pre-push hook installed and normalized to UTF-8 without BOM.'
Write-Host "[PASS] Private Codex config and version-compatible hooks written to $CodexHome"
Write-Host '[USER ACTION REQUIRED] Populate THUCCHIEN_API_KEY and AI_LOG_API_KEY in the official clone''s ignored .env or current process.'
Write-Host '[USER ACTION REQUIRED] Run live preflight before any competition model work.'
