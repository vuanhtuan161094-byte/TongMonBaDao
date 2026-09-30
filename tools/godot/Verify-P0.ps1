param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$Project = Join-Path $RepoRoot "godot"
$ToolingLockPath = Join-Path $PSScriptRoot "TOOLING_LOCK.json"
$ToolingLock = Get-Content -Raw $ToolingLockPath | ConvertFrom-Json
$ExpectedEngineVersion = [string]$ToolingLock.engine.version

function Add-GodotCandidate([System.Collections.Generic.List[string]]$Candidates, [string]$Path) {
    if ([string]::IsNullOrWhiteSpace($Path)) { return }
    try {
        if (-not (Test-Path $Path -PathType Leaf)) { return }
        $resolved = (Resolve-Path $Path).Path
        if (-not $Candidates.Contains($resolved)) { $Candidates.Add($resolved) }
    } catch { return }
}

function Add-GodotWithConsoleSibling([System.Collections.Generic.List[string]]$Candidates, [string]$Path) {
    if ([string]::IsNullOrWhiteSpace($Path)) { return }
    if ($Path -match "(?i)\.exe$" -and $Path -notmatch "(?i)_console\.exe$") {
        Add-GodotCandidate $Candidates ($Path -replace "(?i)\.exe$", "_console.exe")
    }
    Add-GodotCandidate $Candidates $Path
}

function Resolve-GodotBinary([string]$Explicit, [string]$ExpectedVersion) {
    $candidates = New-Object "System.Collections.Generic.List[string]"

    if ($Explicit) { Add-GodotWithConsoleSibling $candidates $Explicit }

    foreach ($name in @(
        "Godot_v4.7.2-stable_win64_console.exe",
        "Godot_v4.7.2-stable_win64.exe",
        "godot_console.exe",
        "godot.exe",
        "godot"
    )) {
        $cmd = Get-Command $name -ErrorAction SilentlyContinue
        if ($null -ne $cmd -and $cmd.Source) {
            Add-GodotWithConsoleSibling $candidates $cmd.Source
        }
    }

    if ($IsWindows -or $env:OS -eq "Windows_NT") {
        $running = Get-Process -ErrorAction SilentlyContinue |
            Where-Object { $_.ProcessName -like "Godot*" -and $_.Path }
        foreach ($process in $running) {
            Add-GodotWithConsoleSibling $candidates $process.Path
        }

        foreach ($root in @(
            (Join-Path $env:USERPROFILE "Downloads"),
            (Join-Path $env:USERPROFILE "Desktop"),
            $RepoRoot
        )) {
            if (-not (Test-Path $root)) { continue }
            foreach ($pattern in @(
                "Godot_v4.7.2-stable_win64_console.exe",
                "Godot_v4.7.2-stable_win64.exe"
            )) {
                $found = Get-ChildItem -Path $root -Filter $pattern -File -Recurse -ErrorAction SilentlyContinue
                foreach ($file in $found) {
                    Add-GodotWithConsoleSibling $candidates $file.FullName
                }
            }
        }
    }

    $failures = New-Object "System.Collections.Generic.List[string]"
    $expectedPattern = "^" + [regex]::Escape($ExpectedVersion)

    foreach ($candidate in $candidates) {
        Write-Host "[Godot] Probing $candidate"
        $global:LASTEXITCODE = 0
        try {
            $output = @(& $candidate --version 2>&1)
            $exitCode = $LASTEXITCODE
            $version = ""
            if ($output.Count -gt 0 -and $null -ne $output[0]) {
                $version = ([string]$output[0]).Trim()
            }
            if ($exitCode -eq 0 -and $version -match $expectedPattern) {
                return [pscustomobject]@{ Path = $candidate; Version = $version }
            }
            $failures.Add("$candidate => exit=$exitCode version='$version'")
        } catch {
            $failures.Add("$candidate => $($_.Exception.Message)")
        }
    }

    $details = if ($failures.Count -gt 0) {
        [Environment]::NewLine + "Candidates tried:" + [Environment]::NewLine + " - " + ($failures -join ([Environment]::NewLine + " - "))
    } else { "" }

    throw "No working Godot $ExpectedVersion CLI binary found. Set GODOT_BIN to the full Godot executable path if auto-discovery misses it.$details"
}

function Assert-NoRunningGodot {
    if (-not ($IsWindows -or $env:OS -eq "Windows_NT")) { return }

    $running = @(Get-Process -ErrorAction SilentlyContinue |
        Where-Object { $_.ProcessName -like "Godot*" })

    if ($running.Count -eq 0) { return }

    $names = ($running | ForEach-Object { "$($_.ProcessName) (PID $($_.Id))" }) -join ", "
    throw "Godot is already running: $names. Close all Godot editor/project-manager windows before running Verify-P0.cmd. This avoids the headless import waiting on an editor/project lock."
}

function Invoke-Godot([string[]]$Args) {
    & $Godot @Args
    if ($LASTEXITCODE -ne 0) {
        throw "Godot command failed with exit code $LASTEXITCODE : $Godot $($Args -join ' ')"
    }
}

Write-Host "=== TONG MON TYCOON P0 GATE ==="
Assert-NoRunningGodot
$resolvedGodot = Resolve-GodotBinary $GodotBin $ExpectedEngineVersion
$Godot = [string]$resolvedGodot.Path
Write-Host "[Godot] $($resolvedGodot.Version)"
Write-Host "[Godot] $Godot"

Write-Host "[1/9] Import"
Invoke-Godot @("--headless", "--path", $Project, "--import")

Write-Host "[2/9] Parse project scripts"
$Scripts = Get-ChildItem -Path (Join-Path $Project "src"), (Join-Path $Project "tests") -Recurse -Filter *.gd
foreach ($Script in $Scripts) {
    $Relative = $Script.FullName.Substring($Project.Length + 1).Replace("\", "/")
    Invoke-Godot @("--headless", "--path", $Project, "--check-only", "--script", "res://$Relative")
}

Write-Host "[3/9] Decision contracts"
Invoke-Godot @("--headless", "--path", $Project, "-s", "res://tests/simulation/p0_decision_contract_test.gd")

Write-Host "[4/9] Economy contracts"
Invoke-Godot @("--headless", "--path", $Project, "-s", "res://tests/simulation/p0_economy_contract_test.gd")

Write-Host "[5/9] Deterministic invariant scenario"
Invoke-Godot @("--headless", "--path", $Project, "-s", "res://tests/simulation/p0_invariant_test.gd")

Write-Host "[6/9] Save/load round trip"
Invoke-Godot @("--headless", "--path", $Project, "-s", "res://tests/simulation/p0_save_roundtrip_test.gd")

Write-Host "[7/9] Same-seed reproducibility"
Invoke-Godot @("--headless", "--path", $Project, "-s", "res://tests/simulation/p0_reproducibility_test.gd")

Write-Host "[8/9] Multi-seed benchmark"
Invoke-Godot @("--headless", "--path", $Project, "-s", "res://tests/simulation/p0_benchmark_test.gd")

Write-Host "[9/9] Runtime smoke"
Invoke-Godot @("--headless", "--path", $Project, "--quit-after", "180")

Write-Host "P0 FOUNDATION GATE: PASS"
