[CmdletBinding()]
param(
    [string]$GodotExe = "",
    [string]$ExpectedSha = "",
    [switch]$OpenVisual,
    [switch]$KeepClone
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2.0

# Fresh temporary clone, never sync/mutate the owner's live workspace/save.
$repo = "https://github.com/vuanhtuan161094-byte/TongMonBaDao.git"
$branch = "c4-pres01-jx-motion-readability-20261019"
$runId = [guid]::NewGuid().ToString("N").Substring(0,12)
$root = Join-Path $env:TEMP ("C4_PRES01_QA_" + $runId)
$clone = Join-Path $root "repo"
$logs = Join-Path $root "logs"
$profile = Join-Path $root "isolated_user"
New-Item -ItemType Directory -Path $root,$logs,$profile -Force | Out-Null
$oldApp = $env:APPDATA
$oldLocal = $env:LOCALAPPDATA
$oldGodotData = $env:GODOT_USER_DATA_DIR
$oldXdg = $env:XDG_DATA_HOME
$exitCode = 1
$headSha = ""

function Require-Zero([string]$Name, [int]$Code) {
    if ($Code -ne 0) {
        throw "$Name failed with exit code $Code. See $logs"
    }
}

function Invoke-GodotQA([string]$Name, [string[]]$GodotArguments, [string]$PassMarker) {
    $out = Join-Path $logs ($Name + ".log")
    Write-Host "--> $Name"
    # PowerShell 5.1 can promote native stderr into terminating
    # NativeCommandError with ErrorActionPreference=Stop. Negative QA fixtures
    # may write expected stderr even when the process exits 0. Trust the
    # process exit code and explicit PASS marker, preserving merged log.
    $oldPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = "Continue"
        & $GodotExe @GodotArguments > $out 2>&1
        $code = [int]$LASTEXITCODE
    } finally {
        $ErrorActionPreference = $oldPreference
    }
    Require-Zero $Name $code
    # A successful process exit is insufficient when Godot logged a script
    # parse/import failure yet continued running another scene or test.
    if (Select-String -LiteralPath $out -Pattern @(
            "SCRIPT ERROR:", "Parse Error:", "Parser Error:",
            "Failed to load script", "Error parsing") -SimpleMatch -Quiet) {
        throw "$Name logged a Godot parser/import error despite exit 0: $out"
    }
    if ($PassMarker -ne "" -and -not (Select-String -LiteralPath $out -Pattern $PassMarker -SimpleMatch -Quiet)) {
        throw "$Name exit 0 but missing explicit PASS marker '$PassMarker': $out"
    }
    Write-Host "PASS: $Name (exit 0 + marker). Log: $out"
}

try {
    if ([string]::IsNullOrWhiteSpace($GodotExe)) {
        $cmd = Get-Command "godot.exe" -ErrorAction SilentlyContinue
        if ($null -eq $cmd) {
            $cmd = Get-Command "Godot_v4.7.2-stable_win64_console.exe" -ErrorAction SilentlyContinue
        }
        if ($null -ne $cmd) {
            $GodotExe = $cmd.Source
        } else {
            $downloads = Join-Path $env:USERPROFILE "Downloads"
            if (Test-Path -LiteralPath $downloads) {
                $candidate = Get-ChildItem -LiteralPath $downloads -File -Filter "*.exe" |
                    Where-Object { $_.Name -match "Godot.*4[.]7[.]2.*(console|win64)" } |
                    Select-Object -First 1
                if ($null -ne $candidate) { $GodotExe = $candidate.FullName }
            }
        }
    }
    if ([string]::IsNullOrWhiteSpace($GodotExe) -or -not (Test-Path -LiteralPath $GodotExe -PathType Leaf)) {
        throw "Godot 4.7.2 runner NOT FOUND. Supply -GodotExe 'C:\\path\\Godot.exe'. Runtime PENDING."
    }
    $oldPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = "Continue"
        $version = (& $GodotExe --version 2>&1 | Out-String).Trim()
        $versionCode = [int]$LASTEXITCODE
    } finally {
        $ErrorActionPreference = $oldPreference
    }
    Require-Zero "Godot version" $versionCode
    if ($version -notmatch "^4[.]7[.]2([.]|$)") {
        throw "Wrong Godot runner: '$version'; requires 4.7.2 stable."
    }
    Write-Host "Official Godot candidate: $version"

    $git = Get-Command "git.exe" -ErrorAction Stop
    Write-Host "--> Clone isolated branch $branch to $clone"
    $oldPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = "Continue"
        & $git.Source clone --quiet --single-branch --branch $branch $repo $clone 2>&1 |
            Out-File -LiteralPath (Join-Path $logs "clone.log") -Encoding UTF8
        $cloneExit = [int]$LASTEXITCODE
    } finally {
        $ErrorActionPreference = $oldPreference
    }
    Require-Zero "TEMP clone" $cloneExit
    $headSha = (& $git.Source -C $clone rev-parse HEAD | Out-String).Trim()
    Require-Zero "HEAD identity" ([int]$LASTEXITCODE)
    if ($headSha -notmatch "^[a-f0-9]{40}$") {
        throw "Clone HEAD not a valid SHA: $headSha"
    }
    if ($ExpectedSha -ne "" -and $headSha -ne $ExpectedSha) {
        throw "Branch moved! Expected $ExpectedSha, observed $headSha. Refuse to test a different commit."
    }
    Write-Host "VERIFIED COMMIT: $headSha"
    # Checkout may already show CRLF-only tracked drift on Windows.
    # Compare the tracked status before and after Godot instead of false PASS/FAIL.
    $baselineTracked = (& $git.Source -C $clone status --porcelain --untracked-files=no | Out-String).Trim()
    Require-Zero "baseline tracked status" ([int]$LASTEXITCODE)
    $baselineDiff = (& $git.Source -C $clone diff --binary --no-ext-diff | Out-String)
    Require-Zero "baseline tracked diff" ([int]$LASTEXITCODE)
    Write-Host "Pre-QA tracked status: $baselineTracked"
    $project = Join-Path $clone "godot"
    if (-not (Test-Path -LiteralPath (Join-Path $project "project.godot"))) {
        throw "Missing Godot project in isolated clone"
    }
    New-Item -ItemType Directory -Path (Join-Path $profile "AppData_Roaming"),(Join-Path $profile "AppData_Local") -Force | Out-Null
    $env:APPDATA = Join-Path $profile "AppData_Roaming"
    $env:LOCALAPPDATA = Join-Path $profile "AppData_Local"
    $env:GODOT_USER_DATA_DIR = Join-Path $profile "Godot_User"
    $env:XDG_DATA_HOME = Join-Path $profile "XDG"
    New-Item -ItemType Directory -Path $env:GODOT_USER_DATA_DIR,$env:XDG_DATA_HOME -Force | Out-Null

    Invoke-GodotQA "01_import" @("--headless","--path",$project,"--editor","--import") ""
    Invoke-GodotQA "02_pilot_status" @("--headless","--path",$project,"--script",
        "res://tests/simulation/c4_jx_pilot_effects_test.gd") "C4-JX-PILOT focused status, source, skill, 5-elements, snapshot, replay: PASS"
    Invoke-GodotQA "03_snapshot" @("--headless","--path",$project,"--script",
        "res://tests/simulation/dv2_02_battle_snapshot_test.gd") "DV2-02 COMBAT SNAPSHOT MID-FIGHT JSON, RNG, HP, CAST, EVENTS: PASS"
    Invoke-GodotQA "04_group" @("--headless","--path",$project,"--script",
        "res://tests/simulation/dv2_02_group_map_battle_test.gd") "DV2-02D GROUP MAP COMBAT: MOVEMENT/HEAL/AOE/BOSS/30-ACTOR/REPLAY TEST PASS"
    Invoke-GodotQA "05_pres01_motion" @("--headless","--path",$project,"--script",
        "res://tests/presentation/c4_pres01_view_motion_readability_test.gd") "C4 PRES-01 VIEW MOTION READABILITY: PASS"
    Invoke-GodotQA "06_vp01_atlas" @("--headless","--path",$project,"--script",
        "res://tests/presentation/c4_vp01_source_vl_battle_visual_test.gd") "C4-VP01 SOURCE VL REAL ATLAS + MAPBATTLE V2 VISUAL TEST: PASS"
    Invoke-GodotQA "07_cast_schema" @("--headless","--path",$project,"--script",
        "res://tests/presentation/combat_v4_world_layer_cast_schema_test.gd") "C4-01 WORLD CAST SCHEMA: SINGLE TARGET / BOSS AOE / INVALID CAST / PURE VIEW / RELEASE PASS"
    # Parse the real 6v5 pilot scene in the official runtime, not just its tests.
    Invoke-GodotQA "08_scene_smoke" @("--headless","--path",$project,
        "--quit-after","30","res://scenes/p3/combat_v4_jx_pilot.tscn") ""

    $tracked = (& $git.Source -C $clone status --porcelain --untracked-files=no | Out-String).Trim()
    Require-Zero "tracked worktree check" ([int]$LASTEXITCODE)
    $afterDiff = (& $git.Source -C $clone diff --binary --no-ext-diff | Out-String)
    Require-Zero "tracked content diff after QA" ([int]$LASTEXITCODE)
    if ($tracked -ne $baselineTracked -or $afterDiff -cne $baselineDiff) {
        throw "Godot QA modified tracked sources in TEMP clone; inspect tracked diff and logs"
    }
    if ($OpenVisual) {
        Write-Host "--> Manual 1280x720 C4 scene. Inspect + capture the actual game window; close when done."
        $oldPreference = $ErrorActionPreference
        try {
            $ErrorActionPreference = "Continue"
            & $GodotExe --path $project --resolution "1280x720" "res://scenes/p3/combat_v4_jx_pilot.tscn"
            $guiCode = [int]$LASTEXITCODE
        } finally {
            $ErrorActionPreference = $oldPreference
        }
        Require-Zero "Manual scene process" $guiCode
        Write-Host "Scene process exited zero; USER visual review/screenshot is STILL PENDING until supplied."
    } else {
        Write-Host "Manual 1280x720 visual scene not launched. Re-run with -OpenVisual."
    }
    $exitCode = 0
}
catch {
    $err = ($_ | Out-String)
    Write-Host "QA STOPPED: $err"
    $err | Out-File -LiteralPath (Join-Path $logs "ERROR.txt") -Encoding UTF8
}
finally {
    $env:APPDATA = $oldApp
    $env:LOCALAPPDATA = $oldLocal
    $env:GODOT_USER_DATA_DIR = $oldGodotData
    $env:XDG_DATA_HOME = $oldXdg
    $summary = @(
        "C4-PRES01 isolated Godot 4.7.2 focused QA",
        "branch=$branch",
        "commit=$headSha",
        "runner=$GodotExe",
        "exit_code=$exitCode",
        "root=$root",
        "runtime_pass_requires_all_6_markers_and_import_zero=true",
        "visual_owner_acceptance_pending=true",
        "android_pending=true"
    ) -join [Environment]::NewLine
    $summary | Out-File -LiteralPath (Join-Path $root "SUMMARY.txt") -Encoding UTF8
    Write-Host $summary
    # Keep a small auditable report archive even if the temporary clone is removed.
    try {
        $archive = Join-Path $root "C4_PRES01_QA_LOGS.zip"
        Compress-Archive -Path (Join-Path $logs "*"),(Join-Path $root "SUMMARY.txt") -DestinationPath $archive -Force
        Write-Host "Evidence ZIP: $archive"
    } catch {
        Write-Host "Evidence archive failed; raw logs remain at $logs"
    }
    if ($exitCode -eq 0 -and -not $KeepClone) {
        Remove-Item -LiteralPath $clone -Recurse -Force -ErrorAction SilentlyContinue
    }
}
exit $exitCode
