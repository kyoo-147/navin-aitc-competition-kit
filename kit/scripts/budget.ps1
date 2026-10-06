[CmdletBinding()]
param(
    [string]$RepoPath = (Get-Location).Path,
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\Aitc.Common.ps1')

$repo = Assert-AitcOfficialRepo -RepoPath $RepoPath
$key = Get-AitcGatewayKey -RepoPath $repo
$keyInfo = Get-AitcKeyInfo -Key $key
$teamId = [string](Get-AitcProperty -Object $keyInfo -Name 'team_id')
if ([string]::IsNullOrWhiteSpace($teamId)) { throw 'Gateway /key/info did not return info.team_id.' }
$teamInfo = Get-AitcTeamInfo -Key $key -TeamId $teamId

$spendValue = Get-AitcProperty -Object $teamInfo -Name 'spend'
$budgetValue = Get-AitcProperty -Object $teamInfo -Name 'max_budget'
if ($null -eq $spendValue -or $null -eq $budgetValue) { throw 'team_info must include spend and max_budget.' }
$spend = [double]$spendValue
$budget = [double]$budgetValue
$remaining = [Math]::Max(0, $budget - $spend)
$policyPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'config\budget.json'
$state = Get-AitcBudgetState -Spend $spend -Budget $budget -PolicyPath $policyPath

$result = [ordered]@{
    checked_at_utc = [DateTime]::UtcNow.ToString('o')
    team_id = Mask-AitcValue -Value $teamId
    spend_usd = [Math]::Round($spend, 4)
    max_budget_usd = [Math]::Round($budget, 4)
    remaining_usd = [Math]::Round($remaining, 4)
    rpm_limit = Get-AitcProperty -Object $teamInfo -Name 'rpm_limit'
    tpm_limit = Get-AitcProperty -Object $teamInfo -Name 'tpm_limit'
    policy_state = $state
}
$json = $result | ConvertTo-Json -Depth 5
$json

if ($OutputPath) {
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($OutputPath, $json + [Environment]::NewLine, $utf8)
}

if ($state -eq 'CAP_REACHED') { exit 4 }
if ($state -eq 'BLOCK_NONESSENTIAL') { exit 3 }
if ($state -eq 'ECONOMY_MODE') { exit 2 }
if ($state -eq 'LEADER_REVIEW') { exit 1 }
exit 0
