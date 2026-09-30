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
    throw "Godot is already running: $names. Close all Godot editor/project-manager windows before running Verify-P0.cmd. This avoids the headless verifier competing with an editor process."
}

function Quote-ProcessArgument([string]$Value) {
    if ($Value -notmatch '[\s"]') { return $Value }
    return '"' + ($Value -replace '(\\*)"', '$1$1\"' -replace '(\\+)$', '$1$1') + '"'
}

function Invoke-GodotWithTimeout(
    [string[]]$CommandArgs,
    [int]$TimeoutSeconds,
    [string]$Label
) {
    if ($null -eq $CommandArgs -or $CommandArgs.Count -eq 0) {
        throw "$Label received no Godot command arguments."
    }

    $argumentLine = ($CommandArgs | ForEach-Object { Quote-ProcessArgument ([string]$_) }) -join ' '
    if ([string]::IsNullOrWhiteSpace($argumentLine)) {
        throw "$Label produced an empty Godot argument line."
    }

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $Godot
    $startInfo.Arguments = $argumentLine
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo

    try {
        if (-not $process.Start()) {
            throw "$Label failed to start Godot."
        }

        $stdoutTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()

        if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
            Write-Host "[TIMEOUT] $Label exceeded ${TimeoutSeconds}s. Killing Godot process tree..."
            if ($IsWindows -or $env:OS -eq "Windows_NT") {
                & taskkill.exe /PID $process.Id /T /F 2>$null | Out-Null
            } else {
                $process.Kill()
            }
            $process.WaitForExit()
            $stdoutTask.Wait()
            $stderrTask.Wait()
            if ($stdoutTask.Result) { Write-Host $stdoutTask.Result.TrimEnd() }
            if ($stderrTask.Result) { Write-Host $stderrTask.Result.TrimEnd() }
            throw "$Label timed out after ${TimeoutSeconds}s. Godot was terminated so the verifier cannot hang indefinitely."
        }

        $process.WaitForExit()
        $stdoutTask.Wait()
        $stderrTask.Wait()

        if ($stdoutTask.Result) { Write-Host $stdoutTask.Result.TrimEnd() }
        if ($stderrTask.Result) { Write-Host $stderrTask.Result.TrimEnd() }

        $exitCode = [int]$process.ExitCode
        if ($exitCode -ne 0) {
            throw "Godot command failed with exit code $exitCode : $Godot $($CommandArgs -join ' ')"
        }
    } finally {
        $process.Dispose()
    }
}

Write-Host "=== TONG MON TYCOON P0 GATE ==="
Assert-NoRunningGodot
$resolvedGodot = Resolve-GodotBinary $GodotBin $ExpectedEngineVersion
$Godot = [string]$resolvedGodot.Path
Write-Host "[Godot] $($resolvedGodot.Version)"
Write-Host "[Godot] $Godot"

Write-Host "[1/9] Import"
Invoke-GodotWithTimeout -CommandArgs @("--headless", "--path", $Project, "--import") -TimeoutSeconds 120 -Label "Godot import"

Write-Host "[2/9] Parse project scripts"
$Scripts = @(Get-ChildItem -Path (Join-Path $Project "src"), (Join-Path $Project "tests") -Recurse -Filter *.gd | Sort-Object FullName)
$ScriptIndex = 0
foreach ($Script in $Scripts) {
    $ScriptIndex += 1
    $Relative = $Script.FullName.Substring($Project.Length + 1).Replace("\", "/")
    Write-Host ("  [Parse {0}/{1}] {2}" -f $ScriptIndex, $Scripts.Count, $Relative)
    Invoke-GodotWithTimeout -CommandArgs @("--headless", "--path", $Project, "--check-only", "--script", "res://$Relative") -TimeoutSeconds 45 -Label "Parse $Relative"
}

Write-Host "[3/9] Decision contracts"
Invoke-GodotWithTimeout -CommandArgs @("--headless", "--path", $Project, "-s", "res://tests/simulation/p0_decision_contract_test.gd") -TimeoutSeconds 60 -Label "Decision contracts"

Write-Host "[4/9] Economy contracts"
Invoke-GodotWithTimeout -CommandArgs @("--headless", "--path", $Project, "-s", "res://tests/simulation/p0_economy_contract_test.gd") -TimeoutSeconds 60 -Label "Economy contracts"

Write-Host "[5/9] Deterministic invariant scenario"
Invoke-GodotWithTimeout -CommandArgs @("--headless", "--path", $Project, "-s", "res://tests/simulation/p0_invariant_test.gd") -TimeoutSeconds 120 -Label "Deterministic invariant scenario"

Write-Host "[6/9] Save/load round trip"
Invoke-GodotWithTimeout -CommandArgs @("--headless", "--path", $Project, "-s", "res://tests/simulation/p0_save_roundtrip_test.gd") -TimeoutSeconds 120 -Label "Save/load round trip"

Write-Host "[7/9] Same-seed reproducibility"
Invoke-GodotWithTimeout -CommandArgs @("--headless", "--path", $Project, "-s", "res://tests/simulation/p0_reproducibility_test.gd") -TimeoutSeconds 120 -Label "Same-seed reproducibility"

Write-Host "[8/9] Multi-seed benchmark"
Invoke-GodotWithTimeout -CommandArgs @("--headless", "--path", $Project, "-s", "res://tests/simulation/p0_benchmark_test.gd") -TimeoutSeconds 240 -Label "Multi-seed benchmark"

Write-Host "[9/9] Runtime smoke"
Invoke-GodotWithTimeout -CommandArgs @("--headless", "--path", $Project, "--quit-after", "180") -TimeoutSeconds 60 -Label "Runtime smoke"

Write-Host "P0 FOUNDATION GATE: PASS"
