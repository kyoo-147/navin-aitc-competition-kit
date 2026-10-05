[CmdletBinding()]
param(
    [string]$RepoPath = (Get-Location).Path,
    [string]$Model,
    [string]$CodexHome = (Join-Path $HOME '.codex'),
    [switch]$Offline,
    [switch]$RequireServerLog,
    [switch]$RequireOrca
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\Aitc.Common.ps1')
$failures = New-Object System.Collections.Generic.List[string]
function Check-Step {
    param([string]$Name, [scriptblock]$Action)
    try { & $Action; Write-Host "[PASS] $Name" }
    catch { $script:failures.Add("$Name - $($_.Exception.Message)"); Write-Host "[FAIL] $Name - $($_.Exception.Message)" -ForegroundColor Red }
}

$repo = $null
$logSettings = $null
Check-Step 'Official repository structure' { $script:repo = Assert-AitcOfficialRepo -RepoPath $RepoPath }
if ($null -eq $repo) { throw 'Cannot continue without a valid official repository.' }

Check-Step 'Required local commands' {
    foreach ($command in @('git', 'python', 'codex', 'bash')) {
        if (-not (Get-Command $command -ErrorAction SilentlyContinue)) { throw "$command is not available on PATH." }
    }
}
Check-Step 'Python 3.10 or newer' {
    $versionText = (& python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')").Trim()
    $parts = $versionText.Split('.')
    if ([int]$parts[0] -lt 3 -or ([int]$parts[0] -eq 3 -and [int]$parts[1] -lt 10)) { throw "Found Python $versionText." }
}
Check-Step 'Organizer scripts and project-local Codex hooks' {
    foreach ($relative in @('scripts\setup_hooks.ps1', 'scripts\submit_log.py', 'scripts\log_hook.py', '.codex\hooks.json')) {
        if (-not (Test-Path -LiteralPath (Join-Path $repo $relative) -PathType Leaf)) { throw "Missing $relative" }
    }
    $hooks = Get-Content -LiteralPath (Join-Path $repo '.codex\hooks.json') -Raw | ConvertFrom-Json
    foreach ($event in @('UserPromptSubmit', 'PostToolUse', 'Stop')) {
        if (-not $hooks.hooks.PSObject.Properties[$event]) { throw "Project hooks missing $event." }
    }
}
Check-Step 'BTC Codex config and active catalog' {
    $configPath = Join-Path $CodexHome 'config.toml'
    if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) { throw 'Missing config.toml. Run bootstrap.ps1.' }
    $configText = Get-Content -LiteralPath $configPath -Raw
    if ($configText -notmatch '(?m)^\s*model_provider\s*=\s*"thucchien"') { throw 'Codex provider is not fixed to thucchien.' }
    if ($configText -notmatch '(?m)^\s*model_catalog_json\s*=\s*"([^"]+)"') { throw 'model_catalog_json is missing.' }
    $catalogPath = $matches[1] -replace '/', '\'
    if (-not [System.IO.Path]::IsPathRooted($catalogPath)) { $catalogPath = Join-Path $CodexHome $catalogPath }
    if (-not (Test-Path -LiteralPath $catalogPath -PathType Leaf)) { throw "Model catalog is missing: $catalogPath" }
    if ($configText -notmatch '(?s)\[model_providers\.thucchien\].*?wire_api\s*=\s*"responses"') { throw 'Codex thucchien wire_api is not responses.' }
    if ($Model -and $configText -notmatch [regex]::Escape("model = `"$Model`"")) { throw "Configured model does not match $Model." }
}
Check-Step 'Codex wrapper and conditional runtime refresh' {
    foreach ($name in @('codex-orca.cmd', 'codex-runtime-refresh.ps1')) {
        if (-not (Test-Path -LiteralPath (Join-Path $CodexHome $name) -PathType Leaf)) { throw "Missing $name. Run bootstrap.ps1." }
    }
}
Check-Step 'Git pre-push hook is installed without BOM' {
    $hook = Join-Path $repo '.git\hooks\pre-push'
    if (-not (Test-Path -LiteralPath $hook)) { throw 'Run bootstrap.ps1 to install the local hook.' }
    $bytes = [System.IO.File]::ReadAllBytes($hook)
    if ($bytes.Length -lt 2 -or $bytes[0] -ne 35 -or $bytes[1] -ne 33) { throw 'Hook must start with #! and contain no UTF-8 BOM.' }
}
Check-Step 'Repository identity and final-round directory' {
    Push-Location $repo
    try {
        $origin = (& git remote get-url origin 2>$null).Trim()
        if (-not $origin) { throw 'origin remote is missing.' }
        if (-not (Test-Path -LiteralPath 'chung-khao\README.md')) { throw 'chung-khao/README.md is missing.' }
    } finally { Pop-Location }
}
if ($RequireOrca) {
    Check-Step 'Orca runtime' {
        if (-not (Get-Command orca -ErrorAction SilentlyContinue)) { throw 'orca is not available on PATH.' }
        & orca status --json | Out-Null
        if ($LASTEXITCODE -ne 0) { throw 'orca status failed.' }
    }
}

if (-not $Offline) {
    $key = $null
    $keyInfo = $null
    Check-Step 'Gateway credentials loaded without display' { $script:key = Get-AitcGatewayKey -RepoPath $repo }
    if ($null -ne $key) {
        Check-Step 'Gateway /key/info' {
            $script:keyInfo = Get-AitcKeyInfo -Key $key
            if ((Get-AitcProperty -Object $keyInfo -Name 'blocked') -eq $true) { throw 'Gateway key is blocked.' }
            $teamId = [string](Get-AitcProperty -Object $keyInfo -Name 'team_id')
            if ([string]::IsNullOrWhiteSpace($teamId)) { throw 'info.team_id is missing.' }
            Write-Host "  team=$(Mask-AitcValue $teamId)"
        }
        if ($null -ne $keyInfo) {
            Check-Step 'Gateway /team/info with team_id' {
                $teamId = [string](Get-AitcProperty -Object $keyInfo -Name 'team_id')
                $teamInfo = Get-AitcTeamInfo -Key $key -TeamId $teamId
                $spend = Get-AitcProperty -Object $teamInfo -Name 'spend'
                $budget = Get-AitcProperty -Object $teamInfo -Name 'max_budget'
                if ($null -eq $spend -or $null -eq $budget) { throw 'team_info spend/max_budget is missing.' }
                Write-Host "  spend=$spend budget=$budget"
            }
        }
    }

    Check-Step 'AI Log settings loaded without display' { $script:logSettings = Get-AitcLogSettings -RepoPath $repo }
    if ($RequireServerLog -and $null -ne $logSettings) {
        Check-Step 'BTC AI Log server readback contains Codex events' {
            $uri = $logSettings.Server + '/entries?tool=codex'
            $response = Invoke-RestMethod -Method Get -Uri $uri -Headers @{ Authorization = "Bearer $($logSettings.Key)"; Accept = 'application/json' } -TimeoutSec 30
            $entries = Get-AitcProperty -Object $response -Name 'entries'
            if ($null -eq $entries -and $response -is [System.Array]) { $entries = $response }
            if ($null -eq $entries -or @($entries).Count -eq 0) { throw 'No Codex entries returned.' }
            $events = @($entries | ForEach-Object { [string](Get-AitcProperty -Object $_ -Name 'event') })
            if (-not ($events -contains 'UserPromptSubmit') -or -not ($events -contains 'Stop')) { throw 'Server readback lacks UserPromptSubmit or Stop.' }
        }
    }
}

if ($failures.Count -gt 0) {
    Write-Host "PREFLIGHT BLOCKED: $($failures.Count) failure(s)." -ForegroundColor Red
    $failures | ForEach-Object { Write-Host "- $_" }
    exit 1
}
Write-Host 'PREFLIGHT VERIFIED' -ForegroundColor Green
