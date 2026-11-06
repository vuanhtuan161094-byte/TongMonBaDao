<#
  Low-memory sequential QA for the owner's 8 GiB Windows computer.
  Default Smoke: one headless import, then V2 visual parse/run.
  Optional Full: also run the larger V1 549-ID skill matrix.
  NEVER kills processes. Refuses to launch while any Godot is running.
  Default RAM safety floor is 1024 MiB AVAILABLE, not an unrealistic 3 GiB.
  A free-memory gate reduces risk but cannot guarantee crash-free operation.
  HEADLESS TESTS ONLY, NOT GUI ART ACCEPTANCE.
#>
[CmdletBinding()]
param(
    [string]$GodotExe = "godot",
    [string]$RepositoryRoot = "",
    [string]$OutputRoot = "",
    [ValidateSet("Smoke", "Full")][string]$Mode = "Smoke",
    [ValidateRange(1024, 8192)][int]$MinimumAvailableMB = 1024
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\.."))
}
$project = Join-Path $RepositoryRoot "godot"
if (-not (Test-Path (Join-Path $project "project.godot"))) {
    throw "BLOCKED_PROJECT_NOT_FOUND: $project"
}
function Assert-CanStartGodot([string]$Phase) {
    # Re-evaluate before EVERY process: import and tests can release or consume RAM.
    $active = @(Get-Process -Name "*godot*" -ErrorAction SilentlyContinue)
    if ($active.Count -gt 0) {
        throw ("BLOCKED_OTHER_GODOT [{0}]: {1}. Close normally; runner never kills PIDs." -f
            $Phase, (($active | ForEach-Object { "$($_.ProcessName) PID=$($_.Id)" }) -join ", "))
    }
    try {
        $system = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        $availableMb = [double]$system.FreePhysicalMemory / 1024.0
    } catch {
        throw ("BLOCKED_RAM_READ [{0}]: {1}" -f $Phase, $_.Exception.Message)
    }
    Write-Host ("RAM_PREFLIGHT [{0}]: available={1:N0} MiB; minimum={2} MiB; mode={3}" -f
        $Phase, $availableMb, $MinimumAvailableMB, $Mode)
    if ($availableMb -lt $MinimumAvailableMB) {
        throw ("BLOCKED_LOW_RAM [{0}]: {1:N0} MiB available; minimum={2} MiB. No Godot started." -f
            $Phase, $availableMb, $MinimumAvailableMB)
    }
    if ($availableMb -lt 1536) {
        Write-Warning "LOW_MEMORY_CAUTION: under 1536 MiB available. Avoid running editor/browser/extra QA concurrently."
    }
}
Assert-CanStartGodot "initial"
if ([string]::IsNullOrWhiteSpace($OutputRoot)) {
    $OutputRoot = Join-Path ([IO.Path]::GetTempPath()) ("TMB-LABV2-" + (Get-Date -Format "yyyyMMdd_HHmmss"))
}
New-Item -ItemType Directory -Force -Path $OutputRoot | Out-Null
$profile = Join-Path $OutputRoot "isolated_profile"
New-Item -ItemType Directory -Force -Path (Join-Path $profile "Roaming") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $profile "Local") | Out-Null
$old = @{}
foreach ($key in @("APPDATA","LOCALAPPDATA","XDG_DATA_HOME","XDG_CONFIG_HOME","XDG_CACHE_HOME")) {
    $old[$key] = [Environment]::GetEnvironmentVariable($key, "Process")
}
[Environment]::SetEnvironmentVariable("APPDATA", (Join-Path $profile "Roaming"), "Process")
[Environment]::SetEnvironmentVariable("LOCALAPPDATA", (Join-Path $profile "Local"), "Process")
[Environment]::SetEnvironmentVariable("XDG_DATA_HOME", (Join-Path $profile "Data"), "Process")
[Environment]::SetEnvironmentVariable("XDG_CONFIG_HOME", (Join-Path $profile "Config"), "Process")
[Environment]::SetEnvironmentVariable("XDG_CACHE_HOME", (Join-Path $profile "Cache"), "Process")
function Invoke-Run([string]$Name, [string[]]$Arguments) {
    Assert-CanStartGodot $Name
    $stdout = Join-Path $OutputRoot ($Name + ".out.log")
    $stderr = Join-Path $OutputRoot ($Name + ".err.log")
    $p = Start-Process -FilePath $GodotExe -ArgumentList $Arguments -WorkingDirectory $RepositoryRoot -Wait -PassThru -RedirectStandardOutput $stdout -RedirectStandardError $stderr
    Write-Host ("{0}: exit={1}, out={2}, err={3}" -f $Name, [int]$p.ExitCode, $stdout, $stderr)
    if ([int]$p.ExitCode -ne 0) {
        if (Test-Path $stderr) { Get-Content $stderr -Tail 30 | Out-Host }
        if (Test-Path $stdout) { Get-Content $stdout -Tail 30 | Out-Host }
        throw ("GODOT_TEST_FAILURE: " + $Name)
    }
}
try {
    Invoke-Run "00-version" @("--version")
    $version = Get-Content (Join-Path $OutputRoot "00-version.out.log") -Raw
    if ($version -notmatch "^4\.7\.2\.") { throw "Godot official 4.7.2 required: $version" }
    $sha = "UNAVAILABLE"
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $sha = (& git -C $RepositoryRoot rev-parse HEAD 2>$null)
    }
    @("Godot=$version", "HEAD=$sha", "Project=$project", "Profile=$profile") | Set-Content -Encoding UTF8 (Join-Path $OutputRoot "SOURCE_INFO.txt")
    Invoke-Run "01-import" @("--headless","--path",$project,"--import")
    $tests = @("res://tests/labs/combat_lab/combat_lab_v2_visual_test.gd")
    if ($Mode -eq "Full") {
        $tests = @("res://tests/labs/combat_lab/combat_lab_focused_test.gd") + $tests
    }
    foreach ($test in $tests) {
        $testName = [IO.Path]::GetFileNameWithoutExtension($test)
        Invoke-Run ("02-parse-" + $testName) @("--headless","--path",$project,"--check-only","--script",$test)
        Invoke-Run ("03-run-" + $testName) @("--headless","--path",$project,"--script",$test)
    }
    Write-Host ("COMBAT_LAB_V2_{0}_HEADLESS_EXIT_0; GUI/physical-mouse/art acceptance remains PENDING." -f $Mode.ToUpperInvariant())
} finally {
    foreach ($key in $old.Keys) {
        [Environment]::SetEnvironmentVariable($key, $old[$key], "Process")
    }
}
