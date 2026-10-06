[CmdletBinding()]
param(
    [string]$CodexHome = (Join-Path $HOME '.codex'),
    [string]$OfficialRepo,
    [ValidateSet('Normal','Aitc')][string]$Profile = 'Normal'
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\Portable.Common.ps1')
$repo = Get-PortableRepoRoot
$codex = [IO.Path]::GetFullPath($CodexHome)
$blocking = 0

if ($PSVersionTable.PSVersion -lt [version]'5.1') { Write-PortableStatus BLOCKED "PowerShell 5.1+ required; found $($PSVersionTable.PSVersion)"; $blocking++ }
else { Write-PortableStatus PASS "PowerShell: $($PSVersionTable.PSVersion)" }
foreach ($requirement in @(
    @{ Command='git'; Minimum='2.40' },
    @{ Command='node'; Minimum='20.0' },
    @{ Command='npm'; Minimum='10.0' },
    @{ Command='codex'; Minimum='0.160.0' }
)) {
    $version = Get-PortableCommandVersion $requirement.Command
    if ($null -eq $version) { Write-PortableStatus BLOCKED "Missing required command: $($requirement.Command)"; $blocking++ }
    elseif (-not (Test-PortableVersionAtLeast $version $requirement.Minimum)) { Write-PortableStatus BLOCKED "$($requirement.Command) $($requirement.Minimum)+ required; found $version"; $blocking++ }
    else { Write-PortableStatus PASS "$($requirement.Command): $version" }
}
foreach ($recommended in @('orca','lavish-axi','chrome-devtools-axi','chrome-devtools-mcp')) {
    $version = Get-PortableCommandVersion $recommended
    if ($null -eq $version) { Write-PortableStatus INFO "Optional command not found: $recommended" }
    else { Write-PortableStatus PASS "${recommended}: $version" }
}

$statePath = Get-PortableInstallStatePath $codex
if (-not (Test-Path -LiteralPath $statePath -PathType Leaf)) {
    Write-PortableStatus BLOCKED "Install state missing: $statePath"
    $blocking++
} else {
    try {
        $state = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
        foreach ($entry in @($state.entries)) {
            if (-not (Test-Path -LiteralPath $entry.path)) {
                Write-PortableStatus BLOCKED "Managed path missing: $($entry.path)"
                $blocking++
                continue
            }
            if ($entry.kind -eq 'file' -and -not [string]::IsNullOrWhiteSpace([string]$entry.installed_sha256)) {
                $actual = Get-PortableHash $entry.path
                if ($actual -eq [string]$entry.installed_sha256) { Write-PortableStatus PASS "Managed hash: $($entry.path)" }
                else { Write-PortableStatus BLOCKED "Managed file drift: $($entry.path)"; $blocking++ }
            }
        }
    } catch { Write-PortableStatus BLOCKED "Invalid install state: $($_.Exception.Message)"; $blocking++ }
}

$autoConnectUser = [Environment]::GetEnvironmentVariable('CHROME_DEVTOOLS_AXI_AUTO_CONNECT','User')
$browserUrlUser = [Environment]::GetEnvironmentVariable('CHROME_DEVTOOLS_AXI_BROWSER_URL','User')
if ([string]::IsNullOrWhiteSpace($autoConnectUser) -and [string]::IsNullOrWhiteSpace($browserUrlUser)) {
    Write-PortableStatus PASS 'Browser auto-attach environment is disabled'
} else { Write-PortableStatus BLOCKED 'Browser auto-attach environment is enabled'; $blocking++ }

$hookFiles = @((Join-Path $codex 'hooks.json'), (Join-Path $HOME '.claude\settings.json'))
if (Test-AxiHookDisabled $hookFiles) { Write-PortableStatus PASS 'Chrome DevTools AXI SessionStart hooks are absent' }
else { Write-PortableStatus BLOCKED 'Chrome DevTools AXI appears in an agent hook'; $blocking++ }

$trackedSafeRoots = @((Join-Path $repo 'profiles'), (Join-Path $repo 'manifests'), (Join-Path $repo 'setup'))
foreach ($root in $trackedSafeRoots) {
    Get-ChildItem -LiteralPath $root -File -Recurse | ForEach-Object {
        $text = [IO.File]::ReadAllText($_.FullName)
        if (Test-PortableSecretText $text) { Write-PortableStatus BLOCKED "Secret-like value in portable source: $($_.FullName)"; $blocking++ }
    }
}
if ($blocking -eq 0) { Write-PortableStatus PASS 'Portable source secret scan passed' }

$portableManifestPath = Join-Path $repo 'manifests\portable-files.json'
if (-not (Test-Path -LiteralPath $portableManifestPath -PathType Leaf)) {
    Write-PortableStatus BLOCKED 'Portable checksum manifest is missing'
    $blocking++
} else {
    try {
        $portableManifest = Get-Content -LiteralPath $portableManifestPath -Raw | ConvertFrom-Json
        foreach ($entry in @($portableManifest.files)) {
            $path = Join-Path $repo ([string]$entry.path).Replace('/', '\')
            if (-not (Test-Path -LiteralPath $path -PathType Leaf) -or (Get-PortableCanonicalTextHash $path) -ne [string]$entry.sha256) {
                Write-PortableStatus BLOCKED "Portable checksum mismatch: $($entry.path)"
                $blocking++
            }
        }
        if (-not ($blocking)) { Write-PortableStatus PASS 'Portable checksums match' }
    } catch { Write-PortableStatus BLOCKED "Portable manifest invalid: $($_.Exception.Message)"; $blocking++ }
}

if ($Profile -eq 'Aitc') {
    foreach ($name in @('THUCCHIEN_API_KEY','AI_LOG_API_KEY')) {
        if ([string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($name,'Process'))) {
            Write-PortableStatus 'USER ACTION REQUIRED' "$name is not set in this process"
        } else { Write-PortableStatus PASS "$name is set (value not displayed)" }
    }
}

if (-not [string]::IsNullOrWhiteSpace($OfficialRepo)) {
    try {
        $official = (Resolve-Path -LiteralPath $OfficialRepo -ErrorAction Stop).Path
        $remote = (& git -C $official remote get-url origin 2>$null)
        if ($LASTEXITCODE -ne 0 -or $remote -notmatch 'ai-thuc-chien/aitc2026-team-918-navin-research') { throw "Wrong origin: $remote" }
        if (-not (Test-Path -LiteralPath (Join-Path $official 'chung-khao') -PathType Container)) { throw 'Missing chung-khao directory' }
        if (-not (Test-Path -LiteralPath (Join-Path $official '.codex\hooks.json') -PathType Leaf)) { throw 'Missing organizer .codex/hooks.json' }
        Write-PortableStatus PASS "Official repository boundary verified: $official"
    } catch { Write-PortableStatus BLOCKED "Official repository check failed: $($_.Exception.Message)"; $blocking++ }
}

if ($blocking -gt 0) {
    Write-Host "DOCTOR BLOCKED: $blocking issue(s)" -ForegroundColor Red
    exit 1
}
Write-Host 'DOCTOR READY' -ForegroundColor Green
