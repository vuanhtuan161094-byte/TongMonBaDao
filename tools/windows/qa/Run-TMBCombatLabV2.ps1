<#
  Isolated official Godot 4.7.2 Combat Lab V2 focused runner.
  NEVER kills processes. Refuses to run with any existing Godot process or
  less than 3 GiB free RAM. HEADLESS TESTS ONLY, NOT GUI ART ACCEPTANCE.
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
    $RepositoryRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\.."))
}
$project = Join-Path $RepositoryRoot "godot"
if (-not (Test-Path (Join-Path $project "project.godot"))) {
    throw "BLOCKED_PROJECT_NOT_FOUND: $project"
}
$active = @(Get-Process -Name "*godot*" -ErrorAction SilentlyContinue)
if ($active.Count -gt 0) {
    throw ("BLOCKED_OTHER_GODOT: " + (($active | ForEach-Object { "$($_.ProcessName) PID=$($_.Id)" }) -join ", "))
}
try {
    $system = Get-CimInstance Win32_OperatingSystem
    $freeGb = [double]$system.FreePhysicalMemory * 1024.0 / 1GB
    if ($freeGb -lt 3.0) { throw ("BLOCKED_LOW_RAM: {0:N2} GiB available; minimum 3 GiB." -f $freeGb) }
} catch {
    throw "BLOCKED_RAM_PREFLIGHT: $($_.Exception.Message)"
}
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
    foreach ($test in @(
        "res://tests/labs/combat_lab/combat_lab_focused_test.gd",
        "res://tests/labs/combat_lab/combat_lab_v2_visual_test.gd"
    )) {
        $testName = [IO.Path]::GetFileNameWithoutExtension($test)
        Invoke-Run ("02-parse-" + $testName) @("--headless","--path",$project,"--check-only","--script",$test)
        Invoke-Run ("03-run-" + $testName) @("--headless","--path",$project,"--script",$test)
    }
    Write-Host "COMBAT_LAB_V2_HEADLESS_EXIT_0; GUI/physical-mouse/art acceptance remains PENDING."
} finally {
    foreach ($key in $old.Keys) {
        [Environment]::SetEnvironmentVariable($key, $old[$key], "Process")
    }
}
