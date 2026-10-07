[CmdletBinding()]
param(
    [ValidateSet('Normal','Aitc')][string]$Profile = 'Aitc',
    [string]$CodexHome = (Join-Path $HOME '.codex'),
    [string]$Model = 'gpt-6-luna',
    [ValidateSet('none','minimal','low','medium','high','xhigh')][string]$Reasoning = 'medium',
    [switch]$Apply,
    [switch]$ReplaceConfig,
    [switch]$InstallTools,
    [switch]$RestoreUserSkills
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\Portable.Common.ps1')
$repo = Get-PortableRepoRoot
$codex = [IO.Path]::GetFullPath($CodexHome)
$timestamp = Get-PortableTimestamp
$backupRoot = Join-Path $codex "backups\machine-replication\$timestamp"

Write-PortableStatus INFO "Mode: $(if ($Apply) {'APPLY'} else {'PLAN ONLY'})"
Write-PortableStatus INFO "Profile: $Profile"
Write-PortableStatus INFO "Codex home: $codex"
Write-PortableStatus INFO 'Auth, API keys, sessions, logs, caches, databases, browser state, and Codex-managed .system skills are never restored.'

$bootstrapScript = Join-Path $PSScriptRoot 'bootstrap.ps1'
$bootstrapArgs = @('-NoProfile','-ExecutionPolicy','Bypass','-File',$bootstrapScript,'-Profile',$Profile,'-CodexHome',$codex,'-Model',$Model,'-Reasoning',$Reasoning)
if ($Apply) { $bootstrapArgs += '-Apply' }
if ($ReplaceConfig) { $bootstrapArgs += '-ReplaceConfig' }
if ($InstallTools) { $bootstrapArgs += '-InstallTools' }
& powershell.exe @bootstrapArgs
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

if ($RestoreUserSkills) {
    $snapshot = Join-Path $repo 'profiles\codex\skills'
    $destinationRoot = Join-Path $codex 'skills'
    $skills = @(Get-ChildItem -LiteralPath $snapshot -Directory | Sort-Object Name)
    foreach ($skill in $skills) {
        $destination = Join-Path $destinationRoot $skill.Name
        Write-PortableStatus PLAN "RESTORE USER SKILL $($skill.Name): $destination"
        if (-not $Apply) { continue }
        if (Test-Path -LiteralPath $destination -PathType Container) {
            $backup = Join-Path $backupRoot ("skills\" + $skill.Name)
            New-Item -ItemType Directory -Force -Path (Split-Path $backup -Parent) | Out-Null
            Copy-Item -LiteralPath $destination -Destination $backup -Recurse -Force
            Remove-Item -LiteralPath $destination -Recurse -Force
        }
        New-Item -ItemType Directory -Force -Path $destinationRoot | Out-Null
        Copy-Item -LiteralPath $skill.FullName -Destination $destination -Recurse
        Write-PortableStatus PASS "Restored user skill $($skill.Name)"
    }
    Write-PortableStatus PASS "Restored $($skills.Count) user-installed skills; Codex-managed .system remains owned by Codex."
} else {
    Write-PortableStatus PRESERVED 'User skill snapshot not restored. Use -RestoreUserSkills to reproduce the global user skill set.'
}

if (-not $Apply) {
    Write-PortableStatus 'USER ACTION REQUIRED' 'Review the plan, install prerequisites, then rerun with -Apply. On a fresh machine, use -ReplaceConfig only after reviewing the generated profile.'
    exit 0
}

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'doctor.ps1') -CodexHome $codex -Profile $Profile
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-PortableStatus PASS 'Machine profile restoration completed.'
Write-PortableStatus 'USER ACTION REQUIRED' 'Log in to providers and enter competition keys locally. Never copy auth/session state from another machine.'
