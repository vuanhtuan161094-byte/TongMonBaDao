<#
Run isolated official Godot 4.7.2 skill matrices on a verified local
PR #72 checkout, with NO access to the player's default AppData profile.
Example:
  powershell -NoProfile -ExecutionPolicy Bypass -File tools/windows/qa/Run-V63QuyenDocMatrix.ps1 -GodotExe "E:\\Godot\\Godot_v4.7.2-stable_win64.exe"
If Godot is on PATH, omit -GodotExe.
The script runs real Godot; it never treats GitHub Actions zero-step failure as a combat failure.
#>
[CmdletBinding()]
param(
    [string]$GodotExe = "godot",
    [string]$RepositoryRoot = "",
    [string]$OutputRoot = ""
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\.."))
}
$project = Join-Path $RepositoryRoot "godot"
if (-not (Test-Path (Join-Path $project "project.godot"))) {
    throw "Missing Godot project: $project"
}
if ([string]::IsNullOrWhiteSpace($OutputRoot)) {
    $OutputRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("TMB-V63-MATRIX-" + (Get-Date -Format "yyyyMMdd_HHmmss"))
}
New-Item -Path $OutputRoot -ItemType Directory -Force | Out-Null
$profile = Join-Path $OutputRoot "isolated-godot-profile"
New-Item -Path (Join-Path $profile "Roaming") -ItemType Directory -Force | Out-Null
New-Item -Path (Join-Path $profile "Local") -ItemType Directory -Force | Out-Null

# Safe default for the owner's 8 GB Windows machine. Never terminate existing Godot.
# On a machine with an existing Godot process, wait for the user/operator to
# close it normally; this runner will not attempt a concurrent import.
$runningGodot = @(Get-Process -Name "*godot*" -ErrorAction SilentlyContinue)
if ($runningGodot.Count -gt 0) {
    $details = ($runningGodot | ForEach-Object { "$($_.ProcessName) PID=$($_.Id)" }) -join "; "
    throw "BLOCKED_EXISTING_GODOT: $details. Do not start another Godot; no process was killed."
}
# A safety cutoff, not a guarantee: headless Godot can still fail for other reasons.
try {
    $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
    $freeBytes = [int64]$os.FreePhysicalMemory * 1024
    $minimum = [int64]3 * 1024 * 1024 * 1024
    if ($freeBytes -lt $minimum) {
        throw ("BLOCKED_LOW_FREE_RAM: {0:N2} GiB free; need at least 3 GiB before starting QA." -f ($freeBytes / 1GB))
    }
} catch {
    throw "BLOCKED_RAM_PREFLIGHT: $($_.Exception.Message). No Godot process started."
}

$oldAppData = $env:APPDATA
$oldLocalAppData = $env:LOCALAPPDATA
$oldXdgData = $env:XDG_DATA_HOME
$oldXdgConfig = $env:XDG_CONFIG_HOME
$oldXdgCache = $env:XDG_CACHE_HOME
$env:APPDATA = Join-Path $profile "Roaming"
$env:LOCALAPPDATA = Join-Path $profile "Local"
$env:XDG_DATA_HOME = Join-Path $profile "XdgData"
$env:XDG_CONFIG_HOME = Join-Path $profile "XdgConfig"
$env:XDG_CACHE_HOME = Join-Path $profile "XdgCache"

function Invoke-FocusedGodot([string]$Label, [string[]]$Arguments) {
    $log = Join-Path $OutputRoot ($Label + ".log")
    & $GodotExe @Arguments > $log 2>&1
    $code = [int]$LASTEXITCODE
    Write-Host ("{0}: exit {1} -> {2}" -f $Label, $code, $log)
    if ($code -ne 0) {
        Get-Content -Path $log -Tail 35 | Out-Host
        throw ("Godot QA failed: " + $Label + " (exit " + $code + ")")
    }
}
try {
    Invoke-FocusedGodot "00-version" @("--version")
    $version = ((Get-Content (Join-Path $OutputRoot "00-version.log") -Raw).Trim())
    if (-not $version.StartsWith("4.7.2.")) {
        throw "Godot 4.7.2 required; got: $version"
    }
    $gitSha = ""
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $gitSha = (& git -C $RepositoryRoot rev-parse HEAD 2>$null)
    }
    $metadata = @("Godot: " + $version, "Source HEAD: " + $gitSha, "Project: " + $project, "Isolated QA profile: " + $profile)
    $metadata | Set-Content -Path (Join-Path $OutputRoot "RUN_INFO.txt") -Encoding UTF8

    Invoke-FocusedGodot "01-import" @("--headless", "--path", $project, "--import")
    $tests = @(
        "res://tests/simulation/tmb_quyen_183_combat_handoff_test.gd",
        "res://tests/simulation/v63_doc_full_combat_matrix_test.gd",
        "res://tests/simulation/v65_poison_combat_contract_test.gd",
        "res://tests/simulation/v63_cung_full_combat_matrix_test.gd"
    )
    for ($i = 0; $i -lt $tests.Count; $i++) {
        $testName = [System.IO.Path]::GetFileNameWithoutExtension($tests[$i])
        Invoke-FocusedGodot ("02-parse-" + $testName) @("--headless", "--path", $project, "--check-only", "--script", $tests[$i])
        Invoke-FocusedGodot ("03-run-" + $testName) @("--headless", "--path", $project, "-s", $tests[$i])
    }
    Write-Host ("All focused Godot tests exited 0. Verify *_SUMMARY / *_PASS markers in: " + $OutputRoot)
    Write-Host "This does NOT certify the 26 poison Divine DESIGN_PENDING effects or player GUI/manual-source integration."
}
finally {
    $env:APPDATA = $oldAppData
    $env:LOCALAPPDATA = $oldLocalAppData
    $env:XDG_DATA_HOME = $oldXdgData
    $env:XDG_CONFIG_HOME = $oldXdgConfig
    $env:XDG_CACHE_HOME = $oldXdgCache
}
