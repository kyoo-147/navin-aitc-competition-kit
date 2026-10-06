[CmdletBinding()]
param(
    [string]$CodexHome = (Join-Path $HOME '.codex'),
    [switch]$Force,
    [switch]$SkipOrcaHomes
)

$ErrorActionPreference = 'Stop'
$homePath = (Resolve-Path -LiteralPath $CodexHome -ErrorAction Stop).Path
$configPath = Join-Path $homePath 'config.toml'
if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) { throw "Missing Codex config: $configPath" }

$config = Get-Content -LiteralPath $configPath -Raw
function Read-TopLevelString([string]$Name, [switch]$Required) {
    $match = [regex]::Match($config, "(?m)^\s*$([regex]::Escape($Name))\s*=\s*`"([^`"]+)`"")
    if ($match.Success) { return $match.Groups[1].Value }
    if ($Required) { throw "Active config has no $Name." }
    return ''
}

$model = Read-TopLevelString 'model' -Required
$provider = Read-TopLevelString 'model_provider' -Required
$catalogValue = Read-TopLevelString 'model_catalog_json' -Required
$loginMethod = Read-TopLevelString 'forced_login_method'
$catalogPath = $catalogValue -replace '/', '\'
if (-not [System.IO.Path]::IsPathRooted($catalogPath)) { $catalogPath = Join-Path $homePath $catalogPath }
$catalogPath = (Resolve-Path -LiteralPath $catalogPath -ErrorAction Stop).Path
$catalog = Get-Content -LiteralPath $catalogPath -Raw | ConvertFrom-Json
if ($null -eq $catalog.models -or @($catalog.models).Count -eq 0) { throw "Catalog has no models: $catalogPath" }

$catalogHash = (Get-FileHash -LiteralPath $catalogPath -Algorithm SHA256).Hash.ToLowerInvariant()
$fingerprintText = "$model`n$provider`n$catalogPath`n$catalogHash`n$loginMethod`n"
$fingerprintBytes = [System.Text.Encoding]::UTF8.GetBytes($fingerprintText)
$sha = [System.Security.Cryptography.SHA256]::Create()
try { $fingerprint = ([System.BitConverter]::ToString($sha.ComputeHash($fingerprintBytes))).Replace('-', '').ToLowerInvariant() }
finally { $sha.Dispose() }
$statePath = Join-Path $homePath 'aitc-runtime-state.json'
$previous = $null
if (Test-Path -LiteralPath $statePath -PathType Leaf) {
    try { $previous = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json } catch { $previous = $null }
}
$changed = $Force -or $null -eq $previous -or [string]$previous.fingerprint -ne $fingerprint

if ($changed) {
    $cache = [ordered]@{
        fetched_at = [DateTime]::UtcNow.ToString('o')
        client_version = '0.160.0'
        source = 'active-model-catalog'
        provider = $provider
        catalog_path = $catalogPath
        models = @($catalog.models)
    }
    $cachePayload = $cache | ConvertTo-Json -Depth 100
    $homes = New-Object System.Collections.Generic.List[string]
    $homes.Add($homePath)
    if (-not $SkipOrcaHomes) {
        $runtimeHome = Join-Path $env:APPDATA 'orca\codex-runtime-home\home'
        if (Test-Path -LiteralPath $runtimeHome -PathType Container) { $homes.Add($runtimeHome) }
        $accountsRoot = Join-Path $env:APPDATA 'orca\codex-accounts'
        if (Test-Path -LiteralPath $accountsRoot -PathType Container) {
            Get-ChildItem -LiteralPath $accountsRoot -Directory | ForEach-Object {
                $accountHome = Join-Path $_.FullName 'home'
                if (Test-Path -LiteralPath $accountHome -PathType Container) { $homes.Add($accountHome) }
            }
        }
    }
    foreach ($targetHome in @($homes | Sort-Object -Unique)) {
        $cachePath = Join-Path $targetHome 'models_cache.json'
        [System.IO.File]::WriteAllText($cachePath, $cachePayload, [System.Text.UTF8Encoding]::new($false))
    }

    $state = [ordered]@{
        schema_version = 1
        fingerprint = $fingerprint
        provider = $provider
        model = $model
        catalog_path = $catalogPath
        catalog_sha256 = $catalogHash
        refreshed_at_utc = [DateTime]::UtcNow.ToString('o')
    }
    [System.IO.File]::WriteAllText($statePath, (($state | ConvertTo-Json -Depth 4) + [Environment]::NewLine), [System.Text.UTF8Encoding]::new($false))
    Write-Host "MODEL_CATALOG_CHANGED provider=$provider model=$model models=$(@($catalog.models).Count)"
    exit 10
}

Write-Host "MODEL_CATALOG_CURRENT provider=$provider model=$model models=$(@($catalog.models).Count)"
exit 0
