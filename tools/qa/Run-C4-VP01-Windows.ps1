param(
    [string]$GodotExe = "",
    [switch]$SkipGui
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$branch = "c4-vp01-sourcevl-real-combat-pilot-20261018"
$repo = "https://github.com/vuanhtuan161094-byte/TongMonBaDao.git"
$testPaths = @(
    "res://tests/presentation/combat_v4_world_layer_cast_schema_test.gd",
    "res://tests/presentation/c4_vp01_source_vl_battle_visual_test.gd",
    "res://tests/simulation/dv2_02_group_map_battle_test.gd"
)
$timestamp = (Get-Date).ToUniversalTime().ToString("yyyyMMddTHHmmssZ")
$root = Join-Path ([IO.Path]::GetTempPath()) ("C4_VP01_QA_{0}_{1}" -f $timestamp, ([guid]::NewGuid().ToString("N").Substring(0,8)))
$clone = Join-Path $root "repo"
$logs = Join-Path $root "logs"
New-Item -ItemType Directory -Force -Path $logs | Out-Null
$report = Join-Path $logs "RESULT.txt"
$script:failed = $false

function Write-Result([string]$s) {
    $s | Out-File -FilePath $report -Encoding UTF8 -Append
    Write-Host $s
}
function Fail([string]$why) {
    $script:failed = $true
    throw $why
}
function Invoke-Focused([string]$title, [string[]]$arguments, [string]$requiredMarker = "") {
    $safeName = $title.Replace(" ","_")
    $logFile = Join-Path $logs ("{0}.log" -f $safeName)
    & $GodotExe @arguments *> $logFile
    $exitCode = $LASTEXITCODE
    $out = Get-Content -Raw -LiteralPath $logFile -ErrorAction SilentlyContinue
    if ($null -eq $out) { $out = "" }
    Write-Result ("{0}: EXIT={1}; log={2}" -f $title, $exitCode, $logFile)
    if ($exitCode -ne 0) { Fail ("{0} failed with exit {1}" -f $title, $exitCode) }
    if ($out -match 'SCRIPT ERROR:|Parse Error:|Parser Error:|Failed to load script|Error parsing') {
        Fail ("{0}: Godot parse/import error detected" -f $title)
    }
    if ($requiredMarker.Length -gt 0 -and -not $out.Contains($requiredMarker)) {
        Fail ("{0}: required PASS marker missing" -f $title)
    }
}
Write-Result ("C4-VP01 isolated Windows QA start: {0}" -f (Get-Date))
Write-Result ("TEMP clone: {0}" -f $clone)
Write-Result "No original repository, game files, PR20, saves or untracked files will be modified."
$oldEnv = @{}
foreach ($key in @("APPDATA","LOCALAPPDATA","USERPROFILE","TEMP","TMP")) {
    $oldEnv[$key] = [Environment]::GetEnvironmentVariable($key,"Process")
}
try {
    $git = Get-Command git -ErrorAction SilentlyContinue
    if ($null -eq $git) { Fail "git not found in PATH" }
    & git -c core.longpaths=true clone --single-branch --depth 1 --branch $branch $repo $clone *> (Join-Path $logs "git-clone.log")
    if ($LASTEXITCODE -ne 0) { Fail "TEMP clone failed; inspect git-clone.log" }
    $headSha = (& git -C $clone rev-parse HEAD).Trim()
    if ($LASTEXITCODE -ne 0 -or $headSha -notmatch "^[0-9a-f]{40}$") { Fail "Could not verify cloned HEAD" }
    Write-Result ("Verified branch: {0}; SHA: {1}" -f $branch, $headSha)
    $game = Join-Path $clone "godot"
    if (-not (Test-Path (Join-Path $game "project.godot"))) { Fail "Godot project missing in clone" }
    if ([string]::IsNullOrWhiteSpace($GodotExe)) {
        foreach ($name in @("godot","godot4","Godot_v4.7.2-stable_win64.exe","Godot_v4.7.2-stable_win64_console.exe")) {
            $found = Get-Command $name -ErrorAction SilentlyContinue
            if ($null -ne $found) { $GodotExe = $found.Source; break }
        }
    }
    if ([string]::IsNullOrWhiteSpace($GodotExe)) {
        $candidates = @(
            (Join-Path $oldEnv["USERPROFILE"] "Downloads\Godot_v4.7.2-stable_win64_console.exe"),
            (Join-Path $oldEnv["USERPROFILE"] "Downloads\Godot_v4.7.2-stable_win64.exe"),
            "C:\Godot\Godot_v4.7.2-stable_win64_console.exe",
            "C:\Godot\Godot_v4.7.2-stable_win64.exe"
        )
        foreach ($candidate in $candidates) {
            if (Test-Path -LiteralPath $candidate -PathType Leaf) { $GodotExe = $candidate; break }
        }
    }
    if ([string]::IsNullOrWhiteSpace($GodotExe) -or -not (Test-Path -LiteralPath $GodotExe -PathType Leaf)) {
        Fail "Godot binary not found: rerun with -GodotExe 'C:\path\Godot_v4.7.2-stable_win64_console.exe'."
    }
    $version = (& $GodotExe --version 2>&1 | Out-String).Trim()
    Write-Result ("Godot: {0}; executable: {1}" -f $version, $GodotExe)
    if ($version -notmatch '^4\.7\.2\.stable') { Fail ("Wrong Godot version: {0}; requires official 4.7.2 stable" -f $version) }
    # Isolate user:// and editor state in THIS process and its child Godot processes.
    $sandbox = Join-Path $root "isolated_user"
    $env:APPDATA = Join-Path $sandbox "AppData\Roaming"
    $env:LOCALAPPDATA = Join-Path $sandbox "AppData\Local"
    $env:USERPROFILE = Join-Path $sandbox "Profile"
    $env:TEMP = Join-Path $sandbox "Temp"
    $env:TMP = $env:TEMP
    foreach ($d in @($env:APPDATA,$env:LOCALAPPDATA,$env:USERPROFILE,$env:TEMP)) {
        New-Item -ItemType Directory -Force -Path $d | Out-Null
    }
    Write-Result ("Isolated user data: {0}" -f $sandbox)
    Invoke-Focused "01_import" @("--headless","--path",$game,"--import")
    $n = 1
    foreach ($test in $testPaths) {
        $n += 1
        $marker = ""
        if ($test -match "c4_vp01_source_vl") {
            $marker = "C4-VP01 SOURCE VL REAL ATLAS + MAPBATTLE V2 VISUAL TEST: PASS"
        }
        Invoke-Focused ("0{0}_focused" -f $n) @("--headless","--path",$game,"--script",$test) $marker
    }
    Invoke-Focused "05_scene_parse_smoke" @("--headless","--path",$game,"--quit-after","180","res://scenes/p3/combat_v4_pilot.tscn")
    Write-Result "Focused headless gates passed at exact cloned HEAD. UX/window FPS remains PENDING."
    if (-not $SkipGui) {
        Write-Result "Launching ONE manual 1280x720 scene. Capture real game screenshots; close the window after observing one full fight."
        $argLine = ('--path "{0}" --resolution 1280x720 res://scenes/p3/combat_v4_pilot.tscn' -f $game)
        $process = Start-Process -FilePath $GodotExe -ArgumentList $argLine -PassThru
        $process.WaitForExit()
        Write-Result ("Visual scene exited with code {0}. USER screenshot/FPS and owner UX approval remain PENDING." -f $process.ExitCode)
    }
} catch {
    $script:failed = $true
    Write-Result ("FAILED OR BLOCKED: {0}" -f $_.Exception.Message)
} finally {
    foreach ($key in $oldEnv.Keys) {
        [Environment]::SetEnvironmentVariable($key,$oldEnv[$key],"Process")
    }
    Write-Result ("C4-VP01 final status: {0}" -f $(if ($script:failed) { "NOT PASS / SEE LOGS" } else { "FOCUSED GREEN / GUI OWNER PENDING" }))
    Write-Result ("Evidence folder: {0}" -f $root)
    $zipPath = Join-Path $root "C4_VP01_QA_LOGS.zip"
    try { Compress-Archive -Path (Join-Path $logs "*") -DestinationPath $zipPath -Force -ErrorAction Stop } catch { Write-Host ("Zip warning: {0}" -f $_.Exception.Message) }
    Write-Host ("Evidence zip: {0}" -f $zipPath)
}
if ($script:failed) { exit 1 }
exit 0
