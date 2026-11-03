param(
    [Parameter(Mandatory=$true)][string] $RepositoryRoot,
    [int] $QaExitCode = -1,
    [int] $BakeExitCode = -1
)
$ErrorActionPreference = 'Stop'
# Safely package only AN-03 generated QA evidence; never include game SaveService data.
$repo = (Resolve-Path -LiteralPath $RepositoryRoot).Path
$qa = Join-Path $repo 'godot\outputs\an03_lab'
if (-not (Test-Path -LiteralPath $qa)) {
    throw "AN03 evidence directory missing: $qa"
}
$stage = Join-Path $qa ('bundle_' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $stage -Force | Out-Null
try {
    $head = (& git -C $repo rev-parse HEAD | Select-Object -First 1)
    $head = [string]$head
    $results = [ordered]@{
        pipeline = 'AN03_MODULAR_RIG_GUIDE_ONLY'
        source_sha = $head.Trim()
        qa_exit_code = $QaExitCode
        bake_exit_code = $BakeExitCode
        owner_shadow_glb_present = $false
        engine_qa_proven = ($QaExitCode -eq 0)
        gpu_bake_proven = ($BakeExitCode -eq 0)
        records = @('qa_logs','captures','bake')
        generated_local = (Get-Date).ToString('o')
    }
    $results | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $stage 'AN03_RESULT.json') -Encoding utf8
    foreach ($name in @('qa_logs','captures','bake')) {
        $folder = Join-Path $qa $name
        if (Test-Path -LiteralPath $folder) {
            Copy-Item -LiteralPath $folder -Destination (Join-Path $stage $name) -Recurse
        }
    }
    foreach ($file in Get-ChildItem -LiteralPath $qa -Filter 'bake_*.log' -File -ErrorAction SilentlyContinue) {
        Copy-Item -LiteralPath $file.FullName -Destination $stage
    }
    foreach ($file in Get-ChildItem -LiteralPath $qa -Filter 'bake_engine_*.log' -File -ErrorAction SilentlyContinue) {
        Copy-Item -LiteralPath $file.FullName -Destination $stage
    }
    $zip = Join-Path $qa 'AN03_EVIDENCE.zip'
    if (Test-Path -LiteralPath $zip) { Remove-Item -LiteralPath $zip -Force }
    Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $zip -CompressionLevel Optimal -Force
    $bytes = (Get-Item -LiteralPath $zip).Length
    Write-Host "[AN03] EVIDENCE ZIP: $zip"
    Write-Host "[AN03] EVIDENCE SIZE: $bytes bytes"
    Write-Host "[AN03] SOURCE SHA: $($results.source_sha)"
    Write-Host "[AN03] QA exit=$QaExitCode; BAKE exit=$BakeExitCode"
} finally {
    Remove-Item -LiteralPath $stage -Force -Recurse -ErrorAction SilentlyContinue
}
