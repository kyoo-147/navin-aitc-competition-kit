[CmdletBinding()]
param([string]$RepoRoot)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($RepoRoot)) { $RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path }
$root = (Resolve-Path -LiteralPath $RepoRoot).Path
$output = Join-Path $root 'manifests\portable-files.json'
$includeRoots = @('profiles','setup')
$items = foreach ($relativeRoot in $includeRoots) {
    Get-ChildItem -LiteralPath (Join-Path $root $relativeRoot) -File -Recurse
}
$items += Get-Item -LiteralPath (Join-Path $root 'manifests\tools.json'), (Join-Path $root 'manifests\skills.json')
$files = foreach ($item in $items | Sort-Object FullName -Unique) {
    [ordered]@{
        path = $item.FullName.Substring($root.Length + 1).Replace('\','/')
        bytes = $item.Length
        sha256 = (Get-FileHash -LiteralPath $item.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    }
}
$manifest = [ordered]@{ schema_version=1; generated_at_utc=[DateTime]::UtcNow.ToString('o'); file_count=@($files).Count; files=@($files) }
$utf8 = New-Object System.Text.UTF8Encoding($false)
New-Item -ItemType Directory -Force -Path (Split-Path $output -Parent) | Out-Null
[IO.File]::WriteAllText($output, (($manifest | ConvertTo-Json -Depth 6) + [Environment]::NewLine), $utf8)
Write-Host "[PASS] Portable manifest updated: $(@($files).Count) files"
