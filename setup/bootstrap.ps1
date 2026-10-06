[CmdletBinding()]
param(
    [ValidateSet('Normal','Aitc')][string]$Profile = 'Normal',
    [string]$CodexHome = (Join-Path $HOME '.codex'),
    [string]$Model = 'gpt-6-luna',
    [ValidateSet('none','minimal','low','medium','high','xhigh')][string]$Reasoning = 'medium',
    [switch]$Apply,
    [switch]$ReplaceConfig,
    [switch]$InstallTools,
    [switch]$SkipSkills
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\Portable.Common.ps1')
$repo = Get-PortableRepoRoot
$codex = [IO.Path]::GetFullPath($CodexHome)
$profiles = Join-Path $repo 'profiles\codex'
$kit = Join-Path $repo 'kit'
$timestamp = Get-PortableTimestamp
$backupRoot = Join-Path $codex "backups\navin-kit\$timestamp"
$stateEntries = New-Object System.Collections.Generic.List[object]

Write-PortableStatus INFO "Mode: $(if ($Apply) {'APPLY'} else {'PLAN ONLY'})"
Write-PortableStatus INFO "Profile: $Profile"
Write-PortableStatus INFO "Codex home: $codex"

if ($PSVersionTable.PSVersion -lt [version]'5.1') { throw 'PowerShell 5.1 or newer is required.' }
Write-PortableStatus PASS "PowerShell: $($PSVersionTable.PSVersion)"
foreach ($requirement in @(
    @{ Command='git'; Minimum='2.40' },
    @{ Command='node'; Minimum='20.0' },
    @{ Command='npm'; Minimum='10.0' },
    @{ Command='codex'; Minimum='0.160.0' }
)) {
    $version = Get-PortableCommandVersion $requirement.Command
    if ($null -eq $version) { Write-PortableStatus BLOCKED "Missing required command: $($requirement.Command)"; throw "Prerequisite missing: $($requirement.Command)" }
    if (-not (Test-PortableVersionAtLeast $version $requirement.Minimum)) { throw "$($requirement.Command) $($requirement.Minimum)+ required; found $version" }
    Write-PortableStatus PASS "$($requirement.Command): $version"
}

$renderRoot = Join-Path ([IO.Path]::GetTempPath()) ('navin-portable-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $renderRoot | Out-Null
try {
    $codexCommand = (Get-Command codex -ErrorAction Stop).Source
    $catalogDestination = Join-Path $codex 'models-btc.json'
    $catalogNormalized = $catalogDestination.Replace('\','/')

    $wrapper = [IO.File]::ReadAllText((Join-Path $profiles 'codex-orca.cmd'))
    $wrapper = $wrapper.Replace('__CODEX_HOME__', $codex).Replace('__CODEX_CMD__', $codexCommand)
    $renderedWrapper = Join-Path $renderRoot 'codex-orca.cmd'
    Write-Utf8NoBom -Path $renderedWrapper -Content $wrapper

    $configTemplate = if ($Profile -eq 'Aitc') { 'config.aitc.template.toml' } else { 'config.normal.template.toml' }
    $config = [IO.File]::ReadAllText((Join-Path $profiles $configTemplate))
    if ($Profile -eq 'Aitc') {
        $reasoningLine = if ($Reasoning) { "model_reasoning_effort = `"$Reasoning`"" } else { '' }
        $config = $config.Replace('__MODEL__',$Model).Replace('__REASONING_LINE__',$reasoningLine).Replace('__MODEL_CATALOG_JSON__',$catalogNormalized)
    }
    $renderedConfig = Join-Path $renderRoot 'config.toml'
    Write-Utf8NoBom -Path $renderedConfig -Content $config

    $mappings = @(
        @{ Source = (Join-Path $profiles 'AGENTS.md'); Destination = (Join-Path $codex 'AGENTS.md'); Label = 'global agent rules' },
        @{ Source = (Join-Path $profiles 'BUILD_PLAYBOOK.md'); Destination = (Join-Path $codex 'BUILD_PLAYBOOK.md'); Label = 'build playbook' },
        @{ Source = (Join-Path $profiles 'TASTE_UI.md'); Destination = (Join-Path $codex 'TASTE_UI.md'); Label = 'UI guidance' },
        @{ Source = (Join-Path $profiles 'codex-runtime-refresh.ps1'); Destination = (Join-Path $codex 'codex-runtime-refresh.ps1'); Label = 'runtime refresh' },
        @{ Source = $renderedWrapper; Destination = (Join-Path $codex 'codex-orca.cmd'); Label = 'Orca wrapper' }
    )
    if ($Profile -eq 'Aitc') {
        $mappings += @{ Source = (Join-Path $kit 'config\models-btc.snapshot.json'); Destination = $catalogDestination; Label = 'dated BTC catalog snapshot' }
    }
    $hooksDestination = Join-Path $codex 'hooks.json'
    if (-not (Test-Path -LiteralPath $hooksDestination -PathType Leaf)) {
        $mappings += @{ Source = (Join-Path $profiles 'hooks.safe.template.json'); Destination = $hooksDestination; Label = 'safe empty user hooks' }
    } else {
        Write-PortableStatus PRESERVED 'Existing hooks.json. Organizer project hooks remain project-local and browser SessionStart hooks are not installed.'
    }

    $configDestination = Join-Path $codex 'config.toml'
    if ($ReplaceConfig -or -not (Test-Path -LiteralPath $configDestination -PathType Leaf)) {
        $mappings += @{ Source = $renderedConfig; Destination = $configDestination; Label = "$Profile config" }
    } else {
        Write-PortableStatus PRESERVED "Existing config.toml; use -ReplaceConfig to back up and replace it."
    }

    foreach ($mapping in $mappings) {
        Assert-PortableSourceSafe $mapping.Source
        $exists = Test-Path -LiteralPath $mapping.Destination -PathType Leaf
        $action = if ($exists) { 'UPDATE' } else { 'CREATE' }
        Write-PortableStatus PLAN "$action $($mapping.Label): $($mapping.Destination)"
        if (-not $Apply) { continue }
        New-Item -ItemType Directory -Force -Path $codex | Out-Null
        $backup = Backup-PortableFile -Path $mapping.Destination -CodexHome $codex -BackupRoot $backupRoot
        Copy-PortableAtomic -Source $mapping.Source -Destination $mapping.Destination
        $stateEntries.Add([ordered]@{
            path = $mapping.Destination
            kind = 'file'
            existed_before = $exists
            backup = $backup
            installed_sha256 = Get-PortableHash $mapping.Destination
        })
        Write-PortableStatus PASS "$action $($mapping.Label)"
    }

    if (-not $SkipSkills) {
        $skillSource = Join-Path $kit 'skills'
        $skillDestination = Join-Path $codex 'skills'
        $skillManifest = Get-Content -LiteralPath (Join-Path $repo 'manifests\skills.json') -Raw | ConvertFrom-Json
        $allowlist = $skillManifest.profile_allowlists.$Profile
        $skills = Get-ChildItem -LiteralPath $skillSource -Directory | Sort-Object Name
        if ($allowlist -is [array]) {
            $skills = @($skills | Where-Object { $_.Name -in @($allowlist) })
            Write-PortableStatus INFO "Profile allowlist: $($Profile) -> $((@($allowlist) -join ', '))"
        } else {
            Write-PortableStatus INFO "Profile allowlist: $Profile -> all source skills"
        }
        foreach ($skill in $skills) {
            $destination = Join-Path $skillDestination $skill.Name
            $exists = Test-Path -LiteralPath $destination -PathType Container
            Write-PortableStatus PLAN "$(if($exists){'UPDATE'}else{'CREATE'}) skill $($skill.Name): $destination"
            if (-not $Apply) { continue }
            $backup = $null
            if ($exists) {
                $backup = Join-Path $backupRoot ("skills\" + $skill.Name)
                New-Item -ItemType Directory -Force -Path (Split-Path $backup -Parent) | Out-Null
                Copy-Item -LiteralPath $destination -Destination $backup -Recurse -Force
                Remove-Item -LiteralPath $destination -Recurse -Force
            }
            New-Item -ItemType Directory -Force -Path $skillDestination | Out-Null
            Copy-Item -LiteralPath $skill.FullName -Destination $destination -Recurse
            $stateEntries.Add([ordered]@{ path=$destination; kind='directory'; existed_before=$exists; backup=$backup; installed_sha256=$null })
            Write-PortableStatus PASS "Installed skill $($skill.Name)"
        }
    }

    if ($InstallTools) {
        $toolManifest = Get-Content -LiteralPath (Join-Path $repo 'manifests\tools.json') -Raw | ConvertFrom-Json
        foreach ($package in $toolManifest.npm_global_packages) {
            Write-PortableStatus PLAN "INSTALL npm global package $package"
            if ($Apply) {
                & npm install -g $package
                if ($LASTEXITCODE -ne 0) { throw "npm install failed: $package" }
                Write-PortableStatus PASS "Installed $package"
            }
        }
    }

    if (-not $Apply) {
        Write-PortableStatus 'USER ACTION REQUIRED' 'Review the plan, then rerun with -Apply. Use -ReplaceConfig only when the existing config should be backed up and replaced.'
        exit 0
    }

    $state = [ordered]@{
        schema_version = 1
        installed_at_utc = [DateTime]::UtcNow.ToString('o')
        source_repo = $repo
        source_commit = (& git -C $repo rev-parse HEAD 2>$null)
        profile = $Profile
        codex_home = $codex
        backup_root = $backupRoot
        entries = $stateEntries.ToArray()
    }
    $statePath = Get-PortableInstallStatePath $codex
    Write-Utf8NoBom -Path $statePath -Content (($state | ConvertTo-Json -Depth 8) + [Environment]::NewLine)
    Write-PortableStatus PASS "Install state: $statePath"
    Write-PortableStatus PASS "Backup root: $backupRoot"
    Write-PortableStatus 'USER ACTION REQUIRED' 'Enter credentials only in the official clone ignored .env or process environment. Do not put values in this kit.'
    Write-PortableStatus INFO 'Next: run setup\doctor.ps1, then clone/verify the official repository and run BTC preflight.'
} finally {
    Remove-Item -LiteralPath $renderRoot -Recurse -Force -ErrorAction SilentlyContinue
}
