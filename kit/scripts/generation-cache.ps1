[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ProjectRoot,
    [Parameter(Mandatory = $true)][ValidateSet('CHECK','RECORD')][string]$Operation,
    [Parameter(Mandatory = $true)][string]$Prompt,
    [string]$AssetId,
    [ValidateSet('text','image','video','audio')][string]$Type = 'text',
    [string]$Purpose,
    [string]$OutputPath,
    [string]$Model,
    [ValidateSet('STARTED','SUCCESS','FAILED')][string]$Status = 'STARTED',
    [string]$ResultStatus,
    [Nullable[int]]$LatencyMs,
    [string]$RequestMetadataJson = '{}'
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $ProjectRoot -ErrorAction Stop).Path
$dataRoot = Join-Path $root 'data'
$manifestPath = Join-Path $dataRoot 'generation-manifest.json'
$ledgerPath = Join-Path $dataRoot 'request-ledger.json'
foreach ($path in @($manifestPath,$ledgerPath)) { if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "GENERATION BLOCKED: missing $path" } }
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$ledger = Get-Content -LiteralPath $ledgerPath -Raw | ConvertFrom-Json
$normalized = ([regex]::Replace($Prompt.Trim().Replace("`r`n","`n"), '\s+', ' '))
$sha = [Security.Cryptography.SHA256]::Create()
try { $promptHash = ([BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($normalized)))).Replace('-','').ToLowerInvariant() } finally { $sha.Dispose() }
$existingSuccess = @($manifest.assets | Where-Object { $_.prompt_hash -eq $promptHash -and $_.status -eq 'SUCCESS' }) | Select-Object -First 1
$existingActive = @($manifest.assets | Where-Object { $_.prompt_hash -eq $promptHash -and $_.status -eq 'STARTED' }) | Select-Object -First 1
if ($Operation -eq 'CHECK') {
    if ($null -ne $existingSuccess) {
        $candidate = Join-Path $root ([string]$existingSuccess.output_path).Replace('/', [IO.Path]::DirectorySeparatorChar)
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            Write-Host "GENERATION REUSE prompt_hash=$promptHash output=$($existingSuccess.output_path)"
            exit 0
        }
    }
    if ($null -ne $existingActive) { Write-Error "GENERATION DUPLICATE BLOCKED prompt_hash=$promptHash"; exit 2 }
    Write-Host "GENERATION MISS prompt_hash=$promptHash"
    exit 3
}
if ([string]::IsNullOrWhiteSpace($AssetId) -or [string]::IsNullOrWhiteSpace($Purpose)) { throw 'GENERATION BLOCKED: RECORD requires AssetId and Purpose.' }
if ($RequestMetadataJson -match '(?i)(api[_-]?key|authorization|secret|token)') { throw 'GENERATION BLOCKED: request metadata contains a forbidden secret field name.' }
try { $metadata = $RequestMetadataJson | ConvertFrom-Json } catch { throw 'GENERATION BLOCKED: RequestMetadataJson is invalid JSON.' }
if ($Status -eq 'STARTED' -and ($null -ne $existingSuccess -or $null -ne $existingActive)) { throw "GENERATION DUPLICATE BLOCKED prompt_hash=$promptHash" }
$startedEntries = @($ledger.requests | Where-Object { $_.prompt_hash -eq $promptHash -and $_.status -eq 'STARTED' })
$attempt = if ($Status -eq 'STARTED') { 1 + $startedEntries.Count } elseif ($startedEntries.Count -gt 0) { [int]$startedEntries[-1].attempt } else { 1 }
if ($Status -eq 'STARTED' -and $attempt -gt 2) { throw "GENERATION BLOCKED: retry limit exceeded for prompt_hash=$promptHash" }
$prior4xx = @($ledger.requests | Where-Object { $_.prompt_hash -eq $promptHash -and ([string]$_.result_status) -match '^4\d\d$' }).Count -gt 0
$priorExhaustion = @($ledger.requests | Where-Object { $_.prompt_hash -eq $promptHash -and ([string]$_.result_status) -match '(?i)(quota|budget.*exhausted|cap_reached)' }).Count -gt 0
if ($Status -eq 'STARTED' -and $prior4xx) { throw 'GENERATION BLOCKED: prior 4xx requires a corrected request and therefore a new prompt hash.' }
if ($Status -eq 'STARTED' -and $priorExhaustion) { throw 'GENERATION BLOCKED: quota or budget exhausted.' }
$timestamp = [DateTime]::UtcNow.ToString('o')
$asset = [ordered]@{ asset_id=$AssetId; type=$Type; status=$Status; prompt_hash=$promptHash; output_path=$OutputPath; model=$Model; generation_timestamp=$timestamp }
$remaining = @($manifest.assets | Where-Object { $_.asset_id -ne $AssetId })
$manifest.assets = @($remaining) + @($asset)
$entry = [ordered]@{ type=$Type; purpose=$Purpose; prompt_hash=$promptHash; attempt=$attempt; status=$Status; result_status=$ResultStatus; latency_ms=$LatencyMs; request_metadata=$metadata; timestamp=$timestamp }
$ledger.requests = @($ledger.requests) + @($entry)
$utf8 = New-Object Text.UTF8Encoding($false)
[IO.File]::WriteAllText($manifestPath, (($manifest | ConvertTo-Json -Depth 12) + [Environment]::NewLine), $utf8)
[IO.File]::WriteAllText($ledgerPath, (($ledger | ConvertTo-Json -Depth 12) + [Environment]::NewLine), $utf8)
Write-Host "GENERATION RECORDED status=$Status attempt=$attempt prompt_hash=$promptHash"
if ($ResultStatus -match '(?i)(quota|budget.*exhausted|cap_reached)') { Write-Error 'GENERATION BLOCKED: quota or budget exhausted.'; exit 4 }
