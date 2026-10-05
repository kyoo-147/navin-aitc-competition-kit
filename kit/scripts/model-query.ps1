[CmdletBinding()]
param(
    [string]$Task,
    [string]$Model,
    [switch]$CodexOnly,
    [switch]$SearchRequired,
    [switch]$All
)

$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$registry = Get-Content -LiteralPath (Join-Path $root 'knowledge\model-registry.json') -Raw | ConvertFrom-Json
$policy = Get-Content -LiteralPath (Join-Path $root 'knowledge\routing-policy.json') -Raw | ConvertFrom-Json
$models = @($registry.text_models)

if ($Model) {
    $models = @($models | Where-Object { $_.id -eq $Model })
    if ($models.Count -eq 0) { throw "Unknown model in local snapshot: $Model" }
}

if ($Task) {
    $route = @($policy.task_routes | Where-Object { $_.task -eq $Task })
    if ($route.Count -eq 0) {
        $known = ($policy.task_routes.task -join ', ')
        throw "Unknown task '$Task'. Known tasks: $known"
    }
    $allowed = @($route[0].models)
    $models = @($models | Where-Object { $allowed -contains $_.id })
}

if ($CodexOnly) { $models = @($models | Where-Object { $_.codex_responses -eq $true }) }
if ($SearchRequired) {
    $models = @($models | Where-Object { $_.web_search_responses -eq $true -or $_.google_search_chat -eq $true })
}
if (-not $All -and -not $Task -and -not $Model) {
    $models = @($models | Where-Object { $_.tier -in @('T1', 'T1-chat') })
}

$result = foreach ($entry in $models) {
    [pscustomobject]@{
        model = $entry.id
        tier = $entry.tier
        provider = $entry.provider
        codex_responses = [bool]$entry.codex_responses
        web_search_responses = [bool]$entry.web_search_responses
        google_search_chat = [bool]$entry.google_search_chat
        input_per_1m = $entry.input_per_1m
        cached_input_per_1m = $entry.cached_input_per_1m
        output_per_1m = $entry.output_per_1m
        recommended_use = $entry.use
    }
}

$result | Sort-Object @{Expression='tier';Ascending=$true}, @{Expression='output_per_1m';Ascending=$true}, @{Expression='input_per_1m';Ascending=$true} | Format-Table -AutoSize
