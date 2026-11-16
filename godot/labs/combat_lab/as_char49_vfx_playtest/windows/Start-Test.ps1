[CmdletBinding()]
param(
    [string]$PackageRoot = $PSScriptRoot,
    [string]$R1SourceForTest = "",
    [string]$LocalDataRootForTest = "",
    [string]$SceneOverride = "",
    [switch]$PackageSmoke
)

$ErrorActionPreference = "Stop"
Import-Module Microsoft.PowerShell.Utility -ErrorAction Stop
$ExpectedR1ManifestSha256 = "A766948A82171909DE4DF3B2DA5F30EB587DB71CB3444141D2DF53B0FB401B49"
$ExpectedV10SourceZipSha256 = "c8290077e0fc8ee9fd99f21b4e69038f2c3fecb9471bde253799bb4ef1fcd4fa"
$R1LabRelative = "godot\labs\combat_lab\as_char49_vfx_playtest"
$LabRuntimeRelative = "labs\combat_lab\as_char49_vfx_playtest"
$DefaultScene = "res://labs/combat_lab/as_char49_vfx_playtest/playtest.tscn"

function Write-Failure([string]$Message) {
    [Console]::Error.WriteLine("QA49_ERROR: " + $Message)
    exit 20
}

try {
    $PackageRoot = (Resolve-Path -LiteralPath $PackageRoot).Path
    $manifestPath = Join-Path $PackageRoot "package_manifest.json"
    if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) { Write-Failure "Package manifest is missing. Re-extract the complete Windows playtest ZIP." }
    $packageManifest = Get-Content -Raw -LiteralPath $manifestPath | ConvertFrom-Json
    if ($packageManifest.package_mode -ne "isolated_visual_only_lab") { Write-Failure "This is not the isolated QA49 playtest package." }
    if ($packageManifest.gameplay_damage_or_status -ne $false) { Write-Failure "Package safety flag is invalid; refusing to launch." }
    if ($packageManifest.godot_version -ne "4.7.2.stable.official.ed1daf0bf") { Write-Failure "Package does not contain pinned official Godot 4.7.2." }
    $sourceCommit = [string]$packageManifest.source_commit
    if ($sourceCommit -notmatch "^[0-9a-f]{40}$") { Write-Failure "Source SHA is malformed." }

    $engine = Join-Path $PackageRoot "engine\Godot_v4.7.2-stable_win64.exe"
    $projectTemplate = Join-Path $PackageRoot "project"
    if (-not (Test-Path -LiteralPath $engine -PathType Leaf)) { Write-Failure "The portable Godot 4.7.2 executable is missing from this ZIP." }
    if (-not (Test-Path -LiteralPath (Join-Path $projectTemplate "project.godot") -PathType Leaf)) { Write-Failure "The isolated playtest project is incomplete." }

    foreach ($entry in $packageManifest.files.PSObject.Properties) {
        $relative = [string]$entry.Name
        if ([IO.Path]::IsPathRooted($relative) -or $relative -match '(^|[\\/])\.\.([\\/]|$)') { Write-Failure "Unsafe package manifest path." }
        $actualPath = Join-Path $PackageRoot ($relative -replace "/", "\")
        if (-not (Test-Path -LiteralPath $actualPath -PathType Leaf)) { Write-Failure "A packaged file is missing: $relative" }
        $actualHash = (Get-FileHash -LiteralPath $actualPath -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($actualHash -ne ([string]$entry.Value).ToLowerInvariant()) { Write-Failure "Package checksum mismatch: $relative" }
    }
    if ($PackageSmoke) {
        Write-Output "QA49_WINDOWS_PACKAGE_SMOKE_PASS"
        Write-Output "SOURCE_SHA=$sourceCommit"
        Write-Output "PACKAGE_FILE_COUNT=$(@($packageManifest.files.PSObject.Properties).Count)"
        Write-Output "R1_TRANSFER_ASSET_REQUIRED=YES"
        exit 0
    }

    if (-not [string]::IsNullOrWhiteSpace($LocalDataRootForTest)) {
        $localAppData = [IO.Path]::GetFullPath($LocalDataRootForTest)
    } else {
        $localAppData = [Environment]::GetFolderPath([Environment+SpecialFolder]::LocalApplicationData)
    }
    if ([string]::IsNullOrWhiteSpace($localAppData)) { Write-Failure "Windows LocalAppData is unavailable." }
    $runtimeRoot = Join-Path $localAppData ("TMB\QA49\" + [string]$packageManifest.package_id)
    $runtimeProject = Join-Path $runtimeRoot "project"
    $marker = Join-Path $runtimeRoot "r1_transfer_manifest.sha256"
    $alreadyInstalled = ((Test-Path -LiteralPath $marker -PathType Leaf) -and
        ((Get-Content -Raw -LiteralPath $marker).Trim().ToUpperInvariant() -eq $ExpectedR1ManifestSha256))

    if (-not $alreadyInstalled) {
        $r1Root = $R1SourceForTest
        if ([string]::IsNullOrWhiteSpace($r1Root)) {
            $nearby = @(
                $PackageRoot,
                (Split-Path -Parent $PackageRoot),
                (Join-Path (Split-Path -Parent $PackageRoot) "AS_CHAR49_V10_POISON_TALISMAN_MOVING_LAB_R1_20261116")
            )
            foreach ($candidate in $nearby) {
                if (-not [string]::IsNullOrWhiteSpace($candidate) -and (Test-Path -LiteralPath (Join-Path $candidate "ASSET_MANIFEST_SHA256.json") -PathType Leaf)) {
                    $r1Root = $candidate
                    break
                }
            }
        }
        if ([string]::IsNullOrWhiteSpace($r1Root)) {
            Add-Type -AssemblyName System.Windows.Forms
            $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
            $dialog.Description = "Select the extracted AS-CHAR-49 V10 R1 asset folder once. Do not select Godot or the TMB project."
            $dialog.ShowNewFolderButton = $false
            $dialog.SelectedPath = $PackageRoot
            if ($dialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) { Write-Failure "R1 art selection was cancelled. No game data was changed." }
            $r1Root = $dialog.SelectedPath
        }
        $r1Root = (Resolve-Path -LiteralPath $r1Root).Path
        $r1ManifestPath = Join-Path $r1Root "ASSET_MANIFEST_SHA256.json"
        if (-not (Test-Path -LiteralPath $r1ManifestPath -PathType Leaf)) { Write-Failure "Selected folder is not the extracted R1 transfer folder." }
        $manifestHash = (Get-FileHash -LiteralPath $r1ManifestPath -Algorithm SHA256).Hash.ToUpperInvariant()
        if ($manifestHash -ne $ExpectedR1ManifestSha256) { Write-Failure "R1 manifest SHA-256 does not match the approved transfer." }
        $r1Manifest = Get-Content -Raw -LiteralPath $r1ManifestPath | ConvertFrom-Json
        if ($r1Manifest.source_zip_sha256 -ne $ExpectedV10SourceZipSha256) { Write-Failure "R1 V10 source ZIP SHA does not match the approved candidate." }
        if ([int]$r1Manifest.v10_frames_count -ne 240 -or [int]$r1Manifest.v10_clips_present -ne 23 -or [int]$r1Manifest.v10_expected -ne 24) {
            Write-Failure "R1 source is not the documented 240-frame, 23-of-24 V10 candidate."
        }
        if ([string]$r1Manifest.death_left -ne "MISSING") { Write-Failure "R1 animation completeness marker is unexpected." }
        if ($r1Manifest.files -eq $null) { Write-Failure "R1 file checksum list is missing." }

        $r1Resolved = [IO.Path]::GetFullPath($r1Root).TrimEnd("\") + "\"
        $assetPrefix = "godot/labs/combat_lab/as_char49_vfx_playtest/"
        $assetEntries = @($r1Manifest.files.PSObject.Properties | Where-Object { $_.Name.StartsWith($assetPrefix, [StringComparison]::Ordinal) })
        if ($assetEntries.Count -ne 252) { Write-Failure "R1 asset manifest does not contain the expected 252 lab assets." }
        foreach ($entry in $assetEntries) {
            $relative = [string]$entry.Name
            if ([IO.Path]::IsPathRooted($relative) -or $relative -match '(^|[\\/])\.\.([\\/]|$)') { Write-Failure "Unsafe R1 manifest path." }
            $source = Join-Path $r1Root ($relative -replace "/", "\")
            $resolved = [IO.Path]::GetFullPath($source)
            if (-not $resolved.StartsWith($r1Resolved, [StringComparison]::OrdinalIgnoreCase)) { Write-Failure "R1 manifest path escaped its folder." }
            if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { Write-Failure "R1 transfer file is missing: $relative" }
            $sourceHash = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash.ToLowerInvariant()
            if ($sourceHash -ne ([string]$entry.Value).ToLowerInvariant()) { Write-Failure "R1 transfer checksum mismatch: $relative" }
        }

        $r1Lab = Join-Path $r1Root $R1LabRelative
        $characterResource = Join-Path $r1Lab "FemaleSwordV10.tres"
        $heroFrames = Join-Path $r1Lab "hero_frames"
        $approvedArt = Join-Path $r1Lab "approved_art"
        if (-not (Test-Path -LiteralPath $characterResource -PathType Leaf)) { Write-Failure "R1 character SpriteFrames resource is missing." }
        if ((Get-ChildItem -LiteralPath $heroFrames -Filter "*.png" -File -Recurse).Count -ne 240) { Write-Failure "R1 does not contain all 240 V10 frame PNGs." }
        if ((Get-ChildItem -LiteralPath $approvedArt -File).Count -ne 8) { Write-Failure "R1 approved-art transfer count is not 8." }

        if (Test-Path -LiteralPath $runtimeRoot) { Write-Failure "Partial QA runtime exists without a valid R1 marker; it was preserved. See LocalAppData\TMB\QA49." }
        New-Item -ItemType Directory -Path $runtimeRoot -Force | Out-Null
        Copy-Item -LiteralPath $projectTemplate -Destination $runtimeProject -Recurse
        $runtimeLab = Join-Path $runtimeProject $LabRuntimeRelative
        Copy-Item -LiteralPath $characterResource -Destination (Join-Path $runtimeLab "FemaleSwordV10.tres")
        Copy-Item -LiteralPath $heroFrames -Destination (Join-Path $runtimeLab "hero_frames") -Recurse
        Copy-Item -LiteralPath $approvedArt -Destination (Join-Path $runtimeLab "approved_art") -Recurse
        [IO.File]::WriteAllText($marker, $ExpectedR1ManifestSha256, [Text.Encoding]::ASCII)
        Write-Output "QA49_R1_ASSETS_INSTALLED_ONCE"
        Write-Output "R1_MANIFEST_SHA256=$ExpectedR1ManifestSha256"
        Write-Output "R1_ASSET_FILE_HASHES_CHECKED=$($assetEntries.Count)"
        Write-Output "R1_OLD_INSTALLER_SCRIPTS=not used; launcher scripts are excluded from asset copying"
        Write-Output "V10_FRAMES=240"
        Write-Output "V10_CLIPS=23/24; Death_Left absent"
    }

    $runtimeLab = Join-Path $runtimeProject $LabRuntimeRelative
    if ((Get-ChildItem -LiteralPath (Join-Path $runtimeLab "hero_frames") -Filter "*.png" -File -Recurse).Count -ne 240) {
        Write-Failure "Installed V10 frames are incomplete; package was preserved."
    }
    $scene = $DefaultScene
    if (-not [string]::IsNullOrWhiteSpace($SceneOverride)) { $scene = $SceneOverride }
    if ($scene -notmatch "^res://.*\.tscn$") { Write-Failure "Scene override must be a packaged res:// .tscn path." }

    $logRoot = Join-Path $runtimeRoot "logs"
    New-Item -ItemType Directory -Path $logRoot -Force | Out-Null
    $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $importLog = Join-Path $logRoot ("import_" + $stamp + ".log")
    $gameLog = Join-Path $logRoot ("game_" + $stamp + ".log")
    $profileRoot = Join-Path $runtimeRoot "profile"
    $qaRoaming = Join-Path $profileRoot "Roaming"
    $qaLocal = Join-Path $profileRoot "Local"
    New-Item -ItemType Directory -Path $qaRoaming,$qaLocal -Force | Out-Null
    $oldAppData = $env:APPDATA
    $oldLocalAppData = $env:LOCALAPPDATA
    $env:APPDATA = $qaRoaming
    $env:LOCALAPPDATA = $qaLocal
    try {
        if (-not (Test-Path -LiteralPath (Join-Path $runtimeProject ".godot\imported"))) {
            $importConsoleLog = Join-Path $logRoot ("import_console_" + $stamp + ".log")
            $importErrorLog = Join-Path $logRoot ("import_stderr_" + $stamp + ".log")
            $importArguments = '--headless --path "' + $runtimeProject + '" --editor --import --quit --log-file "' + $importLog + '"'
            $importProcess = Start-Process -FilePath $engine -ArgumentList $importArguments -WorkingDirectory $runtimeProject -Wait -PassThru -RedirectStandardOutput $importConsoleLog -RedirectStandardError $importErrorLog
            $importExit = $importProcess.ExitCode
            if ($importExit -ne 0) { Write-Failure "Godot import failed with exit $importExit. Log: $importLog" }
            if (Select-String -LiteralPath $importLog,$importConsoleLog,$importErrorLog -Pattern "SCRIPT ERROR|Parse Error|Failed to load resource" -Quiet) {
                Write-Failure "Godot import contains a parse/load error. Log: $importLog"
            }
            Write-Output "GODOT_IMPORT_EXIT=$importExit"
        } else {
            Write-Output "GODOT_IMPORT=already-cached"
        }
        $arguments = '--path "' + $runtimeProject + '" --resolution 1280x720 --position 40,40 --log-file "' + $gameLog + '" --scene "' + $scene + '"'
        $game = Start-Process -FilePath $engine -ArgumentList $arguments -WorkingDirectory $runtimeProject -PassThru -Wait
    } finally {
        $env:APPDATA = $oldAppData
        $env:LOCALAPPDATA = $oldLocalAppData
    }
    Write-Output "GODOT_GUI_EXIT=$($game.ExitCode)"
    Write-Output "GAME_LOG=$gameLog"
    Write-Output "QA_SAVE_PROFILE=$profileRoot"
    Write-Output "SOURCE_SHA=$sourceCommit"
    if ($game.ExitCode -ne 0) { Write-Failure "Godot closed with exit $($game.ExitCode). Review $gameLog" }
    Write-Output "QA49_GAME_CLOSED_NORMALLY"
    exit 0
} catch {
    [Console]::Error.WriteLine("QA49_ERROR: " + $_.Exception.Message)
    exit 21
}

