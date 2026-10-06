Set-StrictMode -Version Latest

function Get-PortableRepoRoot {
    return (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
}

function Write-PortableStatus {
    param([ValidateSet('PASS','INFO','PLAN','PRESERVED','BLOCKED','USER ACTION REQUIRED')][string]$Status, [string]$Message)
    $color = switch ($Status) {
        'PASS' { 'Green' }
        'BLOCKED' { 'Red' }
        'USER ACTION REQUIRED' { 'Yellow' }
        'PRESERVED' { 'Cyan' }
        'PLAN' { 'Magenta' }
        default { 'Gray' }
    }
    Write-Host "[$Status] $Message" -ForegroundColor $color
}

function Get-PortableTimestamp { return [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss') }

function Get-PortableHash {
    param([Parameter(Mandatory = $true)][string]$Path)
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Get-PortableCanonicalTextHash {
    param([Parameter(Mandatory = $true)][string]$Path)
    $text = [IO.File]::ReadAllText($Path).Replace("`r`n", "`n").Replace("`r", "`n")
    $bytes = (New-Object System.Text.UTF8Encoding($false)).GetBytes($text)
    $sha = [Security.Cryptography.SHA256]::Create()
    try { return (($sha.ComputeHash($bytes) | ForEach-Object { $_.ToString('x2') }) -join '') }
    finally { $sha.Dispose() }
}

function Write-Utf8NoBom {
    param([Parameter(Mandatory = $true)][string]$Path, [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Content)
    $parent = Split-Path $Path -Parent
    if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($Path, $Content, $utf8)
}

function Test-PortableSecretText {
    param([Parameter(Mandatory = $true)][string]$Text)
    $patterns = @(
        '(?im)^\s*(THUCCHIEN_API_KEY|AI_LOG_API_KEY|ANTHROPIC_AUTH_TOKEN|OPENAI_API_KEY)\s*=\s*[^\s#][^\r\n]*$',
        '(?i)\bsk-[A-Za-z0-9_-]{12,}\b',
        '-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----'
    )
    foreach ($pattern in $patterns) { if ($Text -match $pattern) { return $true } }
    return $false
}

function Assert-PortableSourceSafe {
    param([Parameter(Mandatory = $true)][string]$Path)
    $text = [IO.File]::ReadAllText($Path)
    if (Test-PortableSecretText -Text $text) { throw "Secret-like value detected in portable source: $Path" }
}

function Copy-PortableAtomic {
    param([Parameter(Mandatory = $true)][string]$Source, [Parameter(Mandatory = $true)][string]$Destination)
    Assert-PortableSourceSafe -Path $Source
    $parent = Split-Path $Destination -Parent
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
    $temp = Join-Path $parent ('.navin-stage-' + [guid]::NewGuid().ToString('N'))
    Copy-Item -LiteralPath $Source -Destination $temp -Force
    if ((Get-PortableHash $Source) -ne (Get-PortableHash $temp)) { Remove-Item $temp -Force; throw "Staging hash mismatch: $Destination" }
    Move-Item -LiteralPath $temp -Destination $Destination -Force
}

function Backup-PortableFile {
    param([string]$Path, [string]$CodexHome, [string]$BackupRoot)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
    $relative = $Path.Substring($CodexHome.TrimEnd('\').Length).TrimStart('\')
    $target = Join-Path $BackupRoot $relative
    New-Item -ItemType Directory -Force -Path (Split-Path $target -Parent) | Out-Null
    Copy-Item -LiteralPath $Path -Destination $target -Force
    return $target
}

function Get-PortableCommandVersion {
    param([string]$Command)
    $resolved = Get-Command $Command -ErrorAction SilentlyContinue
    if ($null -eq $resolved) { return $null }
    try {
        $output = & $Command --version 2>$null | Select-Object -First 1
        if ([string]::IsNullOrWhiteSpace([string]$output)) { return '<available>' }
        return ([string]$output).Trim()
    } catch { return '<available>' }
}

function Get-PortableInstallStatePath {
    param([string]$CodexHome)
    return Join-Path $CodexHome 'navin-kit-install.json'
}

function Test-AxiHookDisabled {
    param([string[]]$HookFiles)
    foreach ($file in $HookFiles) {
        if (Test-Path -LiteralPath $file -PathType Leaf) {
            $text = [IO.File]::ReadAllText($file)
            if ($text -match 'chrome-devtools-axi') { return $false }
        }
    }
    return $true
}

function Test-PortableVersionAtLeast {
    param([Parameter(Mandatory = $true)][string]$Observed, [Parameter(Mandatory = $true)][string]$Minimum)
    if ($Observed -notmatch '(\d+\.\d+(?:\.\d+)?)') { return $false }
    try { return ([version]$matches[1] -ge [version]$Minimum) } catch { return $false }
}
