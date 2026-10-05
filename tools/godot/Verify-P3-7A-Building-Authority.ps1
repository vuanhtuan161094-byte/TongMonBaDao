param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$Project = Join-Path $RepoRoot "godot"
$ExpectedVersion = [string]((Get-Content -Raw (Join-Path $PSScriptRoot "TOOLING_LOCK.json") | ConvertFrom-Json).engine.version)

function Add-Candidate([System.Collections.Generic.List[string]]$Candidates, [string]$Path) {
    if ([string]::IsNullOrWhiteSpace($Path)) { return }
    try {
        if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return }
        $resolved = (Resolve-Path -LiteralPath $Path).Path
        if (-not $Candidates.Contains($resolved)) { $Candidates.Add($resolved) }
    } catch {}
}

function Add-WithConsole([System.Collections.Generic.List[string]]$Candidates, [string]$Path) {
    if ([string]::IsNullOrWhiteSpace($Path)) { return }
    if ($Path -match "(?i)\.exe$" -and $Path -notmatch "(?i)_console\.exe$") {
        Add-Candidate $Candidates ($Path -replace "(?i)\.exe$", "_console.exe")
    }
    Add-Candidate $Candidates $Path
}

function Resolve-FastGodot([string]$Explicit) {
    $candidates = New-Object "System.Collections.Generic.List[string]"
    if ($Explicit) { Add-WithConsole $candidates $Explicit }

    foreach ($name in @("Godot_v4.7.2-stable_win64_console.exe","Godot_v4.7.2-stable_win64.exe","godot_console.exe","godot.exe","godot")) {
        $cmd = Get-Command $name -ErrorAction SilentlyContinue
        if ($null -ne $cmd -and $cmd.Source) { Add-WithConsole $candidates $cmd.Source }
    }

    if ($IsWindows -or $env:OS -eq "Windows_NT") {
        $driveRoot = [IO.Path]::GetPathRoot($RepoRoot)
        if ($driveRoot) {
            Add-WithConsole $candidates (Join-Path $driveRoot "Godot_v4.7.2-stable_win64_console.exe")
            Add-WithConsole $candidates (Join-Path $driveRoot "Godot_v4.7.2-stable_win64.exe")
        }
        foreach ($root in @((Join-Path $env:USERPROFILE "Downloads"),(Join-Path $env:USERPROFILE "Desktop"),$RepoRoot)) {
            if (-not (Test-Path -LiteralPath $root)) { continue }
            foreach ($pattern in @("Godot_v4.7.2-stable_win64_console.exe","Godot_v4.7.2-stable_win64.exe")) {
                foreach ($file in @(Get-ChildItem -LiteralPath $root -Filter $pattern -File -Recurse -ErrorAction SilentlyContinue)) {
                    Add-WithConsole $candidates $file.FullName
                }
            }
        }
    }

    $expectedPattern = "^" + [regex]::Escape($ExpectedVersion)
    foreach ($candidate in $candidates) {
        $global:LASTEXITCODE = 0
        try {
            $output = @(& $candidate --version 2>&1)
            $version = if ($output.Count -gt 0) { ([string]$output[0]).Trim() } else { "" }
            if ($LASTEXITCODE -eq 0 -and $version -match $expectedPattern) {
                return [pscustomobject]@{ Path = $candidate; Version = $version }
            }
        } catch {}
    }
    throw "No working Godot $ExpectedVersion found for P3.7A FAST gate. Set GODOT_BIN if needed."
}

function Invoke-FastGodot([string[]]$CommandArgs, [string]$Label) {
    Write-Host "[FAST] $Label"
    & $Godot @CommandArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Godot command failed with exit code $LASTEXITCODE : $Label"
    }
}

$running = @()
if ($IsWindows -or $env:OS -eq "Windows_NT") {
    $running = @(Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -like "Godot*" })
}
if ($running.Count -gt 0) {
    throw "Godot is already running. Close Godot before the FAST gate."
}

$resolved = Resolve-FastGodot $GodotBin
$Godot = [string]$resolved.Path
Write-Host "=== P3.7A BUILDING AUTHORITY + MINE FAST GATE ==="
Write-Host "[Godot] $($resolved.Version)"
Write-Host "[Mode] FAST - P3.7A backend only"

Write-Host "[0/2] Refresh Godot script-class cache"
Invoke-FastGodot @("--headless","--path",$Project,"--editor","--quit") "Refresh project script classes"

Write-Host "[1/2] Parse changed/adjacent P3.7A scripts"
foreach ($script in @(
    "res://src/simulation/state/building_state.gd",
    "res://src/simulation/building/building_system.gd",
    "res://src/simulation/core/p3_7_factory.gd",
    "res://src/simulation/state/simulation_state.gd",
    "res://src/simulation/state/disciple_state.gd",
    "res://src/simulation/workforce/workforce_system.gd",
    "res://src/simulation/core/simulation_scheduler.gd",
    "res://tests/simulation/p3_7a_building_authority_test.gd"
)) {
    Invoke-FastGodot @("--headless","--path",$Project,"--check-only","--script",$script) "Parse $script"
}

Write-Host "[2/2] Building authority, timed upgrade, Mine cycle, save/load contracts"
Invoke-FastGodot @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/simulation/p3_7a_building_authority_test.gd"
) "P3.7A building authority + Mine contract"

Write-Host "P3.7A BUILDING AUTHORITY + MINE FAST GATE: PASS"
