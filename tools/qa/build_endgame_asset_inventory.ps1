$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$libraryRoot = 'E:\TongMonBaDaoWorkspace\03_AssetLibrary\SourceA'
$catalogPath = Join-Path $libraryRoot 'catalog.jsonl'
$outputRoot = Join-Path $repoRoot 'outputs\endgame_qa_20261025\assets'
$godotRoot = Join-Path $repoRoot 'godot'
$map25Manifest = Join-Path $godotRoot 'data\presentation\map25_source_a_verified.json'

if (-not (Test-Path -LiteralPath $catalogPath -PathType Leaf)) {
    throw "Source A library catalog is missing: $catalogPath"
}
New-Item -ItemType Directory -Force -Path $outputRoot | Out-Null

$records = [System.Collections.Generic.List[object]]::new()
$folderHashes = [System.Collections.Generic.List[object]]::new()
$recordsRaw = Get-Content -LiteralPath $catalogPath
$uniqueFingerprints = @{}
$statusCounts = @{}
$verifiedCount = 0
$mismatchCount = 0
$availableCount = 0

foreach ($line in $recordsRaw) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $row = $line | ConvertFrom-Json
    $id = [string]$row.asset_id
    $status = [string]$row.library_status
    if (-not $statusCounts.ContainsKey($status)) { $statusCounts[$status] = 0 }
    $statusCounts[$status]++
    if (-not [string]::IsNullOrWhiteSpace([string]$row.fingerprint)) {
        $uniqueFingerprints[[string]$row.fingerprint] = $true
    }

    $assetJsonPath = Join-Path (Join-Path $libraryRoot 'GodotAssets') (Join-Path $id 'asset.json')
    $assetJsonExists = Test-Path -LiteralPath $assetJsonPath -PathType Leaf
    $actualFiles = [System.Collections.Generic.List[string]]::new()
    $hashesMatch = $false
    $fileCount = 0
    $clipNames = @()
    $fps = $null
    $boneCount = $null
    $frameCount = $null
    $currentOutputManifestHash = ''
    if ($assetJsonExists) {
        $availableCount++
        $assetJson = Get-Content -Raw -LiteralPath $assetJsonPath | ConvertFrom-Json
        $fileCount = 0
        $hashesMatch = $true
        $expectedFiles = $assetJson.file_sha256
        foreach ($property in $expectedFiles.PSObject.Properties) {
            $filePath = Join-Path (Split-Path $assetJsonPath -Parent) $property.Name
            $fileCount++
            if (-not (Test-Path -LiteralPath $filePath -PathType Leaf)) {
                $hashesMatch = $false
                $folderHashes.Add([pscustomobject]@{
                    asset_id = $id; relative_file = $property.Name; expected_sha256 = [string]$property.Value
                    actual_sha256 = ''; status = 'MISSING'
                })
                continue
            }
            $actualHash = (Get-FileHash -LiteralPath $filePath -Algorithm SHA256).Hash.ToLowerInvariant()
            $actualFiles.Add($property.Name)
            $match = $actualHash -eq ([string]$property.Value).ToLowerInvariant()
            if (-not $match) { $hashesMatch = $false }
            $folderHashes.Add([pscustomobject]@{
                asset_id = $id; relative_file = $property.Name; expected_sha256 = [string]$property.Value
                actual_sha256 = $actualHash; status = $(if ($match) { 'MATCH' } else { 'MISMATCH' })
            })
        }
        if ($fileCount -gt 0 -and $hashesMatch) { $verifiedCount++ } else { $mismatchCount++ }
        $clipNames = @($assetJson.clips | ForEach-Object { [string]$_.name })
        $fps = $assetJson.fps
        $boneCount = $assetJson.bones
        $frameCount = $assetJson.stored_frames
        $currentOutputManifestHash = (Get-FileHash -LiteralPath $assetJsonPath -Algorithm SHA256).Hash.ToLowerInvariant()
    }

    $records.Add([pscustomobject]@{
        asset_id = $id
        library_status = $status
        qa_status = [string]$row.qa_status
        source_status = [string]$row.source_status
        role = [string]$row.role
        classification_confidence = [string]$row.classification_confidence
        source_category_candidate = [string]$row.source_category_candidate
        source_id = [string]$row.source_id
        duplicate_of = [string]$row.duplicate_of
        source_fingerprint = [string]$row.fingerprint
        source_sha256 = [string]$row.source_sha256
        converter_sha256 = [string]$row.converter_sha256
        indexed_output_sha256 = [string]$row.output_sha256
        current_asset_json_sha256 = $currentOutputManifestHash
        godot_files_available = $assetJsonExists
        godot_file_count = $fileCount
        current_file_hashes_match_asset_json = $hashesMatch
        clips = ($clipNames -join '|')
        fps = $fps
        bones = $boneCount
        stored_frames = $frameCount
        scene = [string]$row.godot_scene
        spriteframes = [string]$row.godot_spriteframes
        source_paths = (@($row.source_files | ForEach-Object { [string]$_.relative_path }) -join '|')
        atlas_outputs = (@($row.atlas_outputs) -join '|')
        texture_sha256 = (@($row.texture_sha256) -join '|')
    })
}

$records | Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $outputRoot 'sourcea_library_asset_inventory.csv')
$folderHashes | Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $outputRoot 'sourcea_library_current_sha256.csv')

$map25Rows = [System.Collections.Generic.List[object]]::new()
if (Test-Path -LiteralPath $map25Manifest -PathType Leaf) {
    $manifestData = Get-Content -Raw -LiteralPath $map25Manifest | ConvertFrom-Json
    foreach ($assetProperty in $manifestData.files.PSObject.Properties) {
        $entry = $assetProperty.Value
        $relative = [string]$entry.path
        if ([string]::IsNullOrWhiteSpace($relative)) { $relative = [string]$assetProperty.Name }
        $localRelative = $relative -replace '^res://',''
        $path = Join-Path $godotRoot $localRelative.Replace('/', '\')
        $exists = Test-Path -LiteralPath $path -PathType Leaf
        $actual = if ($exists) { (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant() } else { '' }
        $expected = [string]$entry.sha256
        $map25Rows.Add([pscustomobject]@{
            path = $relative; expected_sha256 = $expected; actual_sha256 = $actual
            status = $(if (-not $exists) { 'MISSING' } elseif ($actual -eq $expected.ToLowerInvariant()) { 'MATCH' } else { 'MISMATCH' })
            semantic_role = [string]$entry.role
        })
    }
}
$map25Rows | Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $outputRoot 'map25_verified_sourcea_current_sha256.csv')

$catalogHash = (Get-FileHash -LiteralPath $catalogPath -Algorithm SHA256).Hash.ToLowerInvariant()
$summary = [ordered]@{
    catalog_path = $catalogPath
    catalog_sha256 = $catalogHash
    catalog_rows = $records.Count
    unique_source_fingerprints = $uniqueFingerprints.Count
    indexed_status_counts = $statusCounts
    current_godot_asset_folders = $availableCount
    current_godot_asset_folders_all_files_match = $verifiedCount
    current_godot_asset_folders_missing_or_mismatch = $mismatchCount
    sourcea_asset_folder_hash_rows = $folderHashes.Count
    map25_manifest_path = $map25Manifest
    map25_manifest_rows = $map25Rows.Count
    map25_current_hash_matches = @($map25Rows | Where-Object status -eq 'MATCH').Count
    map25_missing_or_mismatch = @($map25Rows | Where-Object status -ne 'MATCH').Count
    source_roles_unmapped = @($records | Where-Object { $_.role -eq 'UNKNOWN' }).Count
    duplicate_entries = @($records | Where-Object { -not [string]::IsNullOrWhiteSpace($_.duplicate_of) }).Count
    note = 'Read-only inventory of the existing Source A library and repo SHA-gated MAP25 files. No conversions or source/master changes were run.'
}
$summary | ConvertTo-Json -Depth 6 | Set-Content -Encoding UTF8 (Join-Path $outputRoot 'asset_inventory_summary.json')
Write-Output ($summary | ConvertTo-Json -Depth 6)
