[CmdletBinding()]
param([string]$KitRoot)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($KitRoot)) { $KitRoot = Split-Path $PSScriptRoot -Parent }
$root = (Resolve-Path -LiteralPath $KitRoot).Path
$manifestPath = Join-Path $root 'MANIFEST.json'
$items = Get-ChildItem -LiteralPath $root -File -Recurse | Where-Object { $_.FullName -ne $manifestPath } | Sort-Object FullName
$files = foreach ($item in $items) {
    $relative = $item.FullName.Substring($root.Length + 1).Replace('\', '/')
    [ordered]@{
        path = $relative
        bytes = $item.Length
        sha256 = (Get-FileHash -LiteralPath $item.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    }
}
$manifest = [ordered]@{
    schema_version = 2
    generated_at_utc = [DateTime]::UtcNow.ToString('o')
    file_count = @($files).Count
    files = @($files)
}
$json = $manifest | ConvertTo-Json -Depth 6
$utf8 = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($manifestPath, $json + [Environment]::NewLine, $utf8)
Write-Host "[PASS] Manifest updated: $(@($files).Count) files"
