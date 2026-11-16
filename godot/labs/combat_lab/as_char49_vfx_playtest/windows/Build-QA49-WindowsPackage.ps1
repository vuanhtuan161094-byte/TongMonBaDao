[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$RepoRoot,
    [Parameter(Mandatory=$true)][string]$GodotExe,
    [Parameter(Mandatory=$true)][string]$OutputDirectory,
    [Parameter(Mandatory=$true)][string]$SourceCommit,
    [string]$GodotArchiveSha256 = "UNVERIFIED_LOCAL_QA_ONLY"
)

$ErrorActionPreference = "Stop"
Import-Module Microsoft.PowerShell.Utility -ErrorAction Stop
$ExpectedGodotVersion = "4.7.2.stable.official.ed1daf0bf"
$ExpectedGodotZipSha256 = "731980f9608d61333e5baf54a2ef17210acc7a538446c0cb9969f002aca1e953"
$ExpectedR1ManifestSha256 = "A766948A82171909DE4DF3B2DA5F30EB587DB71CB3444141D2DF53B0FB401B49"
$ExpectedV10SourceZipSha256 = "c8290077e0fc8ee9fd99f21b4e69038f2c3fecb9471bde253799bb4ef1fcd4fa"
$OfficialGodotUrl = "https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_win64.exe.zip"

$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
$GodotExe = (Resolve-Path -LiteralPath $GodotExe).Path
$OutputDirectory = [IO.Path]::GetFullPath($OutputDirectory)
if ($SourceCommit -notmatch "^[0-9a-fA-F]{40}$") { throw "SourceCommit must be an exact 40-character Git SHA." }
$versionText = (& $GodotExe --headless --version 2>&1 | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or $versionText -notmatch "4\.7\.2\.stable\.official\.ed1daf0bf") {
    throw "Expected official Godot 4.7.2 ed1daf0bf; got: $versionText"
}

$packageRoot = Join-Path $OutputDirectory "TMB_VFX_PLAYTEST_WINDOWS"
if (Test-Path -LiteralPath $packageRoot) { throw "Refusing to overwrite existing package: $packageRoot" }
New-Item -ItemType Directory -Path $packageRoot -Force | Out-Null
$projectRoot = Join-Path $packageRoot "project"
$engineRoot = Join-Path $packageRoot "engine"
New-Item -ItemType Directory -Path $projectRoot,$engineRoot -Force | Out-Null

function Copy-RequiredSource([string]$RelativeSource, [string]$ProjectRelativeTarget) {
    $sourcePath = Join-Path $RepoRoot ($RelativeSource -replace "/", "\")
    if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) { throw "Required source missing: $RelativeSource" }
    $targetPath = Join-Path $projectRoot ($ProjectRelativeTarget -replace "/", "\")
    $targetParent = Split-Path -Parent $targetPath
    if (-not (Test-Path -LiteralPath $targetParent)) { New-Item -ItemType Directory -Path $targetParent -Force | Out-Null }
    Copy-Item -LiteralPath $sourcePath -Destination $targetPath
    $sidecar = $sourcePath + ".import"
    if (Test-Path -LiteralPath $sidecar -PathType Leaf) { Copy-Item -LiteralPath $sidecar -Destination ($targetPath + ".import") }
}

$lab = "godot/labs/combat_lab/as_char49_vfx_playtest"
$copyList = @(
    @("$lab/playtest.gd", "labs/combat_lab/as_char49_vfx_playtest/playtest.gd"),
    @("$lab/fx_layer.gd", "labs/combat_lab/as_char49_vfx_playtest/fx_layer.gd"),
    @("$lab/playtest.tscn", "labs/combat_lab/as_char49_vfx_playtest/playtest.tscn"),
    @("$lab/qa_capture.gd", "labs/combat_lab/as_char49_vfx_playtest/qa_capture.gd"),
    @("$lab/qa_capture.tscn", "labs/combat_lab/as_char49_vfx_playtest/qa_capture.tscn"),
    @("godot/assets/actors/v5_sa_monster_1113031_1/animations.tres", "assets/actors/v5_sa_monster_1113031_1/animations.tres"),
    @("godot/assets/actors/v5_sa_monster_1113031_1/atlas_000.webp", "assets/actors/v5_sa_monster_1113031_1/atlas_000.webp"),
    @("godot/assets/actors/v5_sa_monster_1113031_1/atlas_001.webp", "assets/actors/v5_sa_monster_1113031_1/atlas_001.webp"),
    @("godot/assets/actors/v5_sa_monster_1113031_1/atlas_002.webp", "assets/actors/v5_sa_monster_1113031_1/atlas_002.webp"),
    @("godot/labs/combat_lab/poison02/assets/serpent-flight-atlas.webp", "labs/combat_lab/poison02/assets/serpent-flight-atlas.webp"),
    @("godot/labs/combat_lab/poison02/assets/serpent-bind-back-4pose.webp", "labs/combat_lab/poison02/assets/serpent-bind-back-4pose.webp"),
    @("godot/labs/combat_lab/poison02/assets/serpent-bind-front-4pose.webp", "labs/combat_lab/poison02/assets/serpent-bind-front-4pose.webp"),
    @("godot/labs/combat_lab/poison03/assets/fu_cot_gu_master.svg", "labs/combat_lab/poison03/assets/fu_cot_gu_master.svg"),
    @("godot/labs/combat_lab/poison03/assets/fu_cot_bone_seal.svg", "labs/combat_lab/poison03/assets/fu_cot_bone_seal.svg"),
    @("godot/labs/combat_lab/poison04/assets/co_vu_painted_cloud.svg", "labs/combat_lab/poison04/assets/co_vu_painted_cloud.svg"),
    @("godot/labs/combat_lab/poison04/assets/co_vu_smoke_tendril.svg", "labs/combat_lab/poison04/assets/co_vu_smoke_tendril.svg"),
    @("godot/labs/combat_lab/poison04/assets/co_vu_gu_moth.svg", "labs/combat_lab/poison04/assets/co_vu_gu_moth.svg"),
    @("godot/labs/combat_lab/talisman02/assets/tal02_thunder_flipbook.webp", "labs/combat_lab/talisman02/assets/tal02_thunder_flipbook.webp"),
    @("godot/labs/combat_lab/talisman02/assets/tal02_fracture_impact.webp", "labs/combat_lab/talisman02/assets/tal02_fracture_impact.webp"),
    @("godot/labs/combat_lab/talisman03/assets/tal03_mark_flipbook.webp", "labs/combat_lab/talisman03/assets/tal03_mark_flipbook.webp")
)
foreach ($item in $copyList) { Copy-RequiredSource $item[0] $item[1] }

$configPath = Join-Path $projectRoot "project.godot"
$configText = @"
config_version=5

[application]
config/name="QA49 V10 Moving VFX Lab"
run/main_scene="res://labs/combat_lab/as_char49_vfx_playtest/playtest.tscn"
config/features=PackedStringArray("4.7", "GL Compatibility")

[display]
window/size/viewport_width=1280
window/size/viewport_height=720
window/size/window_width_override=1280
window/size/window_height_override=720
window/stretch/mode="canvas_items"

[rendering]
renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
"@
[IO.File]::WriteAllText($configPath, $configText, (New-Object System.Text.UTF8Encoding($false)))

$windowsSource = Join-Path $RepoRoot "godot\labs\combat_lab\as_char49_vfx_playtest\windows"
foreach ($name in @("START_TEST.cmd","Start-Test.ps1","README_START_HERE.txt")) {
    $from = Join-Path $windowsSource $name
    if (-not (Test-Path -LiteralPath $from -PathType Leaf)) { throw "Package entry file missing: $from" }
    Copy-Item -LiteralPath $from -Destination (Join-Path $packageRoot $name)
}
$engineTarget = Join-Path $engineRoot "Godot_v4.7.2-stable_win64.exe"
Copy-Item -LiteralPath $GodotExe -Destination $engineTarget

$engineHash = (Get-FileHash -LiteralPath $engineTarget -Algorithm SHA256).Hash.ToLowerInvariant()
$godotVerified = ($GodotArchiveSha256.ToLowerInvariant() -eq $ExpectedGodotZipSha256)
$files = [ordered]@{}
Get-ChildItem -LiteralPath $packageRoot -Recurse -File | Where-Object { $_.Name -ne "package_manifest.json" } | Sort-Object FullName | ForEach-Object {
    $relative = $_.FullName.Substring($packageRoot.Length).TrimStart("\").Replace("\","/")
    $files[$relative] = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
}
$manifest = [ordered]@{
    package_id = "QA49_" + $SourceCommit.Substring(0,12)
    source_branch = "integration/pve-p0-playable-ui-20261103"
    source_commit = $SourceCommit.ToLowerInvariant()
    package_mode = "isolated_visual_only_lab"
    default_scene = "res://labs/combat_lab/as_char49_vfx_playtest/playtest.tscn"
    viewport = "1280x720"
    gameplay_damage_or_status = $false
    godot_version = $ExpectedGodotVersion
    godot_release_url = $OfficialGodotUrl
    godot_official_zip_sha256 = $ExpectedGodotZipSha256
    godot_official_zip_verified = $godotVerified
    godot_exe_sha256 = $engineHash
    r1_folder_required_once = $true
    r1_folder_manifest_sha256 = $ExpectedR1ManifestSha256
    v10_source_zip_sha256 = $ExpectedV10SourceZipSha256
    v10_frames_expected = 240
    v10_candidate_clips = "23/24; Death_Left absent; no mirrored substitute"
    vfx_contracts = @("POI02","POI03","POI04","TAL02","TAL03","HF02-R6","HF03-R2")
    files = $files
}
$manifestPath = Join-Path $packageRoot "package_manifest.json"
$manifestJson = $manifest | ConvertTo-Json -Depth 8
[IO.File]::WriteAllText($manifestPath, $manifestJson, (New-Object System.Text.UTF8Encoding($false)))

$zipPath = Join-Path $OutputDirectory "TMB_VFX_PLAYTEST_WINDOWS.zip"
if (Test-Path -LiteralPath $zipPath) { throw "Refusing to overwrite existing ZIP: $zipPath" }
Compress-Archive -LiteralPath $packageRoot -DestinationPath $zipPath -CompressionLevel Optimal
$zipHash = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Output "QA49_PACKAGE_CREATED"
Write-Output "SOURCE_SHA=$($SourceCommit.ToLowerInvariant())"
Write-Output "GODOT_VERSION=$versionText"
Write-Output "GODOT_OFFICIAL_ARCHIVE_VERIFIED=$godotVerified"
Write-Output "GODOT_EXE_SHA256=$engineHash"
Write-Output "R1_TRANSFER_ASSETS=required_once; manifest_sha256=$ExpectedR1ManifestSha256"
Write-Output "PACKAGE_DIR=$packageRoot"
Write-Output "PACKAGE_ZIP=$zipPath"
Write-Output "PACKAGE_ZIP_SHA256=$zipHash"

