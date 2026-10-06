[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ProjectRoot,
    [string]$ExpectedVersion = '0.1.63',
    [string[]]$Artifacts = @('artifacts/architecture.html','artifacts/ux-flow.html')
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $ProjectRoot -ErrorAction Stop).Path
$command = Get-Command lavish-axi -ErrorAction SilentlyContinue
if ($null -eq $command) { throw 'LAVISH OFFLINE BLOCKED: preinstalled lavish-axi is missing. Do not use npx during competition.' }
$version = (& lavish-axi --version 2>&1 | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or $version -ne $ExpectedVersion) {
    throw "LAVISH OFFLINE BLOCKED: expected lavish-axi $ExpectedVersion, found '$version'."
}
$forbidden = @(
    @{ Name='remote URL'; Pattern='(?i)https?://' },
    @{ Name='protocol-relative URL'; Pattern='(?i)(?:src|href)\s*=\s*["'']//' },
    @{ Name='remote script'; Pattern='(?i)<script[^>]+src\s*=' },
    @{ Name='remote stylesheet'; Pattern='(?i)<link[^>]+(?:stylesheet|href)' },
    @{ Name='CSS import'; Pattern='(?i)@import\s' },
    @{ Name='Tailwind CDN'; Pattern='(?i)tailwind(?:css)?\.com|cdn\.tailwindcss' },
    @{ Name='Google Fonts'; Pattern='(?i)fonts\.googleapis|fonts\.gstatic' },
    @{ Name='Lavish cloud share'; Pattern='(?i)lavish\s+share|ht-ml\.app' }
)
foreach ($relative in $Artifacts) {
    $path = Join-Path $root ($relative.Replace('/', '\'))
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "LAVISH OFFLINE BLOCKED: missing $relative" }
    $text = Get-Content -LiteralPath $path -Raw
    foreach ($rule in $forbidden) {
        if ($text -match $rule.Pattern) { throw "LAVISH OFFLINE BLOCKED: $relative contains $($rule.Name)." }
    }
    Write-Host "[PASS] Local-only artifact: $relative"
}
Write-Host "[PASS] Pinned preinstalled lavish-axi: $version"
Write-Host 'LAVISH OFFLINE VERIFIED' -ForegroundColor Green
