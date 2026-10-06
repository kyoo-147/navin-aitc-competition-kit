[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Model,
    [Parameter(Mandatory = $true)][ValidateSet('responses','chat/completions')][string]$Endpoint,
    [Parameter(Mandatory = $true)][ValidateSet('codex','chat-worker')][string]$Harness,
    [string]$SmokeEvidencePath,
    [string]$RegistryPath
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($RegistryPath)) {
    $RegistryPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'knowledge\verified-routes.json'
}
$registry = Get-Content -LiteralPath $RegistryPath -Raw | ConvertFrom-Json
$rejected = @($registry.explicit_rejections | Where-Object { $_.model -eq $Model -and $_.endpoint -eq $Endpoint -and $_.harness -eq $Harness })
if ($rejected.Count -gt 0) { throw "ROUTE REJECTED: $($rejected[0].reason)" }
$route = @($registry.routes | Where-Object { $_.model -eq $Model -and $_.endpoint -eq $Endpoint -and $_.harness -eq $Harness })
if ($route.Count -ne 1 -or $route[0].documented_compatible -ne $true) {
    throw "ROUTE UNVERIFIED: no documented compatible tuple for $Model + $Endpoint + $Harness."
}
if ([string]::IsNullOrWhiteSpace($SmokeEvidencePath)) {
    throw "ROUTE UNVERIFIED: compatible tuple found, but current-session tool-call smoke evidence is required."
}
$evidence = Get-Content -LiteralPath $SmokeEvidencePath -Raw | ConvertFrom-Json
if ([string]$evidence.status -ne 'VERIFIED' -or [string]$evidence.model -ne $Model -or [string]$evidence.endpoint -ne $Endpoint -or [string]$evidence.harness -ne $Harness -or $evidence.tool_call_smoke -ne $true) {
    throw 'ROUTE UNVERIFIED: smoke evidence does not verify the requested model + endpoint + harness + tool call.'
}
if ([string]$evidence.provider -ne 'thucchien') { throw "ROUTE UNVERIFIED: provider proof is '$($evidence.provider)', not thucchien." }
if ([string]::IsNullOrWhiteSpace([string]$evidence.session_id)) { throw 'ROUTE UNVERIFIED: session_id is missing.' }
Write-Host "[PASS] Route tuple: $Model + $Endpoint + $Harness"
Write-Host '[PASS] Current-session tool-call smoke and provider proof are present.'
Write-Host 'ROUTE VERIFIED' -ForegroundColor Green
