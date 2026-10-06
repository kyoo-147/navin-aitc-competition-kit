[CmdletBinding()]
param([string]$RepoRoot)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\Portable.Common.ps1')
if ([string]::IsNullOrWhiteSpace($RepoRoot)) { $RepoRoot = Get-PortableRepoRoot }
$repo = (Resolve-Path -LiteralPath $RepoRoot).Path
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('navin-portable-verify-' + [guid]::NewGuid().ToString('N'))
$planHome = $fixture + '-plan'

function Invoke-PortableChild {
    param([string]$Script, [string[]]$Arguments)
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $Script @Arguments
    if ($LASTEXITCODE -ne 0) { throw "Child command failed ($LASTEXITCODE): $Script $($Arguments -join ' ')" }
}

try {
    Invoke-PortableChild (Join-Path $repo 'setup\bootstrap.ps1') @('-CodexHome',$planHome,'-Profile','Normal')
    if (Test-Path -LiteralPath $planHome) { throw 'Plan-only bootstrap mutated the target home.' }
    Write-PortableStatus PASS 'Plan-only bootstrap made no target-home changes'

    New-Item -ItemType Directory -Force -Path $fixture | Out-Null
    Write-Utf8NoBom -Path (Join-Path $fixture 'AGENTS.md') -Content "ORIGINAL_SENTINEL`n"
    Write-Utf8NoBom -Path (Join-Path $fixture 'config.toml') -Content "CONFIG_SENTINEL`n"
    Invoke-PortableChild (Join-Path $repo 'setup\bootstrap.ps1') @('-CodexHome',$fixture,'-Profile','Normal','-Apply')
    if ([IO.File]::ReadAllText((Join-Path $fixture 'config.toml')).Trim() -ne 'CONFIG_SENTINEL') { throw 'Existing config.toml was not preserved.' }
    Write-PortableStatus PASS 'Existing config.toml was preserved by default'

    Invoke-PortableChild (Join-Path $repo 'setup\doctor.ps1') @('-CodexHome',$fixture,'-Profile','Normal')
    Invoke-PortableChild (Join-Path $repo 'setup\rollback.ps1') @('-CodexHome',$fixture,'-Apply')
    if ([IO.File]::ReadAllText((Join-Path $fixture 'AGENTS.md')).Trim() -ne 'ORIGINAL_SENTINEL') { throw 'Rollback did not restore AGENTS.md.' }
    if ([IO.File]::ReadAllText((Join-Path $fixture 'config.toml')).Trim() -ne 'CONFIG_SENTINEL') { throw 'Rollback changed preserved config.toml.' }
    Write-PortableStatus PASS 'Rollback restored prior state and retained preserved config'

    foreach ($root in @('profiles','setup','manifests')) {
        Get-ChildItem -LiteralPath (Join-Path $repo $root) -File -Recurse | ForEach-Object {
            if ($_.Name -eq 'portable-files.json') { return }
            if (Test-PortableSecretText ([IO.File]::ReadAllText($_.FullName))) { throw "Secret-like content: $($_.FullName)" }
        }
    }
    Write-PortableStatus PASS 'Portable source secret scan passed'
    Write-Host 'PORTABLE KIT VERIFICATION PASSED' -ForegroundColor Green
} finally {
    Remove-Item -LiteralPath $fixture, $planHome -Recurse -Force -ErrorAction SilentlyContinue
}
