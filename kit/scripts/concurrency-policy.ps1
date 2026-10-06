[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][ValidateSet('DRILL','OFFICIAL')][string]$SessionMode,
    [Parameter(Mandatory = $true)][string]$RepoPath,
    [string]$KeyInfoPath,
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\Aitc.Common.ps1')
$repo = Assert-AitcOfficialRepo -RepoPath $RepoPath
if ($KeyInfoPath) {
    $info = Get-Content -LiteralPath $KeyInfoPath -Raw | ConvertFrom-Json
    if ($null -ne $info.info) { $info = $info.info }
} else {
    $key = Get-AitcGatewayKey -RepoPath $repo
    $info = Get-AitcKeyInfo -Key $key
}
$limit = $null
foreach ($name in @('max_concurrent_requests','max_concurrency','concurrency_limit','concurrent_requests')) {
    $value = Get-AitcProperty -Object $info -Name $name
    if ($null -ne $value -and [int]$value -gt 0) { $limit = [int]$value; break }
}
if ($null -eq $limit) {
    $rateLimits = Get-AitcProperty -Object $info -Name 'rate_limits'
    if ($null -ne $rateLimits) {
        foreach ($name in @('max_concurrent_requests','max_concurrency','concurrency')) {
            $value = Get-AitcProperty -Object $rateLimits -Name $name
            if ($null -ne $value -and [int]$value -gt 0) { $limit = [int]$value; break }
        }
    }
}
if ($null -eq $limit) { throw 'CONCURRENCY BLOCKED: live /key/info did not expose a recognized positive concurrency limit.' }
$default = if ($SessionMode -eq 'OFFICIAL') { 6 } else { 2 }
$headroom = [Math]::Max(1, [Math]::Ceiling($limit * 0.2))
$usable = [Math]::Max(1, $limit - $headroom)
$active = [Math]::Min($default, $usable)
$plan = [ordered]@{
    schema_version = 1
    status = 'VERIFIED'
    observed_at_utc = [DateTime]::UtcNow.ToString('o')
    session_mode = $SessionMode
    live_limit = $limit
    reserved_headroom = $headroom
    active_model_turns = $active
    max_concurrent_writers = 2
    max_read_only_reviewers = 1
}
if ($OutputPath) {
    $parent = Split-Path $OutputPath -Parent
    if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    [IO.File]::WriteAllText($OutputPath, (($plan | ConvertTo-Json -Depth 4) + [Environment]::NewLine), (New-Object Text.UTF8Encoding($false)))
}
Write-Host "[PASS] Live concurrency limit: $limit"
Write-Host "[PASS] Reserved headroom: $headroom"
Write-Host "[PASS] Active model turns for ${SessionMode}: $active"
Write-Host 'CONCURRENCY VERIFIED' -ForegroundColor Green
