Set-StrictMode -Version Latest

function Import-AitcEnvFile {
    param([Parameter(Mandatory = $true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return }

    foreach ($line in [System.IO.File]::ReadAllLines((Resolve-Path -LiteralPath $Path))) {
        $trimmed = $line.Trim()
        if (-not $trimmed -or $trimmed.StartsWith('#')) { continue }
        if ($trimmed -notmatch '^([A-Za-z_][A-Za-z0-9_]*)=(.*)$') { continue }
        $name = $matches[1]
        $value = $matches[2].Trim()
        if (($value.StartsWith('"') -and $value.EndsWith('"')) -or ($value.StartsWith("'") -and $value.EndsWith("'"))) {
            $value = $value.Substring(1, $value.Length - 2)
        }
        if ([string]::IsNullOrEmpty([Environment]::GetEnvironmentVariable($name, 'Process'))) {
            [Environment]::SetEnvironmentVariable($name, $value, 'Process')
        }
    }
}

function Get-AitcProperty {
    param($Object, [Parameter(Mandatory = $true)][string]$Name)
    if ($null -eq $Object) { return $null }
    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property) { return $null }
    return $property.Value
}

function Mask-AitcValue {
    param([AllowNull()][string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return '<missing>' }
    if ($Value.Length -le 8) { return ('*' * $Value.Length) }
    return $Value.Substring(0, 4) + '...' + $Value.Substring($Value.Length - 4)
}

function Assert-AitcOfficialRepo {
    param([Parameter(Mandatory = $true)][string]$RepoPath)
    $resolved = (Resolve-Path -LiteralPath $RepoPath -ErrorAction Stop).Path
    if (-not (Test-Path -LiteralPath (Join-Path $resolved '.git'))) { throw "Not a Git clone: $resolved" }
    if (-not (Test-Path -LiteralPath (Join-Path $resolved 'chung-khao') -PathType Container)) { throw "Missing required chung-khao directory: $resolved" }
    if (-not (Test-Path -LiteralPath (Join-Path $resolved 'scripts\submit_log.py') -PathType Leaf)) { throw 'Missing organizer AI Log script scripts/submit_log.py.' }
    return $resolved
}

function Get-AitcGatewayKey {
    param([Parameter(Mandatory = $true)][string]$RepoPath)
    Import-AitcEnvFile -Path (Join-Path $RepoPath '.env')
    $key = [Environment]::GetEnvironmentVariable('THUCCHIEN_API_KEY', 'Process')
    if ([string]::IsNullOrWhiteSpace($key)) { throw 'THUCCHIEN_API_KEY is missing. Set it in the process or the official clone''s ignored .env.' }
    return $key
}

function Get-AitcLogSettings {
    param([Parameter(Mandatory = $true)][string]$RepoPath)
    Import-AitcEnvFile -Path (Join-Path $RepoPath '.env')
    $server = [Environment]::GetEnvironmentVariable('AI_LOG_SERVER', 'Process')
    $key = [Environment]::GetEnvironmentVariable('AI_LOG_API_KEY', 'Process')
    if ([string]::IsNullOrWhiteSpace($server)) { $server = 'https://live.thucchien.ai/api/ingest' }
    if ([string]::IsNullOrWhiteSpace($key)) { throw 'AI_LOG_API_KEY is missing. Set it in the process or the official clone''s ignored .env.' }
    return [pscustomobject]@{ Server = $server.TrimEnd('/'); Key = $key }
}

function Invoke-AitcGatewayGet {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Key
    )
    $uri = 'https://api.thucchien.ai' + $Path
    return Invoke-RestMethod -Method Get -Uri $uri -Headers @{ Authorization = "Bearer $Key"; Accept = 'application/json' } -TimeoutSec 30
}

function Get-AitcKeyInfo {
    param([Parameter(Mandatory = $true)][string]$Key)
    $response = Invoke-AitcGatewayGet -Path '/key/info' -Key $Key
    $info = Get-AitcProperty -Object $response -Name 'info'
    if ($null -eq $info) { throw 'Gateway /key/info response is missing info.' }
    return $info
}

function Get-AitcTeamInfo {
    param(
        [Parameter(Mandatory = $true)][string]$Key,
        [Parameter(Mandatory = $true)][string]$TeamId
    )
    $encoded = [uri]::EscapeDataString($TeamId)
    $response = Invoke-AitcGatewayGet -Path "/team/info?team_id=$encoded" -Key $Key
    $teamInfo = Get-AitcProperty -Object $response -Name 'team_info'
    if ($null -eq $teamInfo) { throw 'Gateway /team/info response is missing team_info.' }
    return $teamInfo
}

function Get-AitcBudgetState {
    param([double]$Spend, [double]$Budget, [string]$PolicyPath)
    $policy = Get-Content -LiteralPath $PolicyPath -Raw | ConvertFrom-Json
    $review = [double]$policy.gates.leader_review
    $economy = [double]$policy.gates.economy_mode
    $block = [double]$policy.gates.block_nonessential
    if ($Spend -ge $Budget) { return 'CAP_REACHED' }
    if ($Spend -ge $block) { return 'BLOCK_NONESSENTIAL' }
    if ($Spend -ge $economy) { return 'ECONOMY_MODE' }
    if ($Spend -ge $review) { return 'LEADER_REVIEW' }
    return 'NORMAL'
}
