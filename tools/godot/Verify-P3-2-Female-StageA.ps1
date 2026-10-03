param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$Project = Join-Path $RepoRoot "godot"
$ToolingLock = Get-Content -Raw (Join-Path $PSScriptRoot "TOOLING_LOCK.json") | ConvertFrom-Json
$ExpectedVersion = [string]$ToolingLock.engine.version

function Add-GodotCandidate([System.Collections.Generic.List[string]]$Candidates, [string]$Path) {
    if ([string]::IsNullOrWhiteSpace($Path)) { return }
    try {
        if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return }
        $resolved = (Resolve-Path -LiteralPath $Path).Path
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

function Assert-NoRunningGodot {
    if (-not ($IsWindows -or $env:OS -eq "Windows_NT")) { return }

    $running = @(Get-Process -ErrorAction SilentlyContinue |
        Where-Object { $_.ProcessName -like "Godot*" })

    if ($running.Count -eq 0) { return }

    $names = ($running | ForEach-Object { "$($_.ProcessName) (PID $($_.Id))" }) -join ", "
    throw "Godot is already running: $names. Close all Godot editor/project-manager windows before running the Stage A FAST check. This avoids the headless import competing for the project/import cache."
}

function Resolve-QuickGodot([string]$Explicit, [string]$ExpectedVersion) {
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
        $driveRoot = [IO.Path]::GetPathRoot($RepoRoot)
        if (-not [string]::IsNullOrWhiteSpace($driveRoot)) {
            Add-GodotWithConsoleSibling $candidates (Join-Path $driveRoot "Godot_v4.7.2-stable_win64_console.exe")
            Add-GodotWithConsoleSibling $candidates (Join-Path $driveRoot "Godot_v4.7.2-stable_win64.exe")
        }

        $running = @(Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -like "Godot*" -and $_.Path })
        foreach ($p in $running) {
            Add-GodotWithConsoleSibling $candidates $p.Path
        }

        foreach ($root in @(
            (Join-Path $env:USERPROFILE "Downloads"),
            (Join-Path $env:USERPROFILE "Desktop"),
            $RepoRoot
        )) {
            if (-not (Test-Path -LiteralPath $root)) { continue }
            foreach ($pattern in @(
                "Godot_v4.7.2-stable_win64_console.exe",
                "Godot_v4.7.2-stable_win64.exe"
            )) {
                $found = @(Get-ChildItem -LiteralPath $root -Filter $pattern -File -Recurse -ErrorAction SilentlyContinue)
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
            # Same direct-invocation approach as the already proven P0 resolver.
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
    } else {
        [Environment]::NewLine + "No Godot executable candidate file was found in GODOT_BIN, PATH, drive root, running processes, Downloads, Desktop, or the repository."
    }
    throw "No working Godot $ExpectedVersion CLI found. Set GODOT_BIN only if auto-discovery still misses it.$details"
}

function Quote-ProcessArgument([string]$Value) {
    if ($Value -notmatch '[\s"]') { return $Value }
    return '"' + ($Value -replace '(\\*)"', '$1$1\"' -replace '(\\+)$', '$1$1') + '"'
}

function Invoke-QuickGodot(
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

    Write-Host "[Godot command] $Godot $argumentLine"

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $Godot
    $psi.Arguments = $argumentLine
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $psi
    try {
        if (-not $process.Start()) { throw "$Label failed to start Godot." }
        $stdout = $process.StandardOutput.ReadToEndAsync()
        $stderr = $process.StandardError.ReadToEndAsync()
        if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
            Write-Host "[TIMEOUT] $Label exceeded ${TimeoutSeconds}s. Killing Godot process tree..."
            if ($IsWindows -or $env:OS -eq "Windows_NT") {
                & taskkill.exe /PID $process.Id /T /F 2>$null | Out-Null
            } else {
                $process.Kill()
            }
            $process.WaitForExit()
            $stdout.Wait(); $stderr.Wait()
            if ($stdout.Result) { Write-Host $stdout.Result.TrimEnd() }
            if ($stderr.Result) { Write-Host $stderr.Result.TrimEnd() }
            throw "$Label timed out after ${TimeoutSeconds}s."
        }
        $process.WaitForExit()
        $stdout.Wait(); $stderr.Wait()
        if ($stdout.Result) { Write-Host $stdout.Result.TrimEnd() }
        if ($stderr.Result) { Write-Host $stderr.Result.TrimEnd() }
        if ($process.ExitCode -ne 0) { throw "Godot command failed with exit code $($process.ExitCode): $Label" }
    } finally {
        $process.Dispose()
    }
}

Write-Host "=== P3.2 FEMALE STAGE A THREE-DIRECTION FAST CHECK ==="
Assert-NoRunningGodot
$resolvedGodot = Resolve-QuickGodot $GodotBin $ExpectedVersion
$Godot = [string]$resolvedGodot.Path
Write-Host "[Godot] $($resolvedGodot.Version)"
Write-Host "[Godot] $Godot"

Write-Host "[1/5] Importing new/changed Stage A assets"
Invoke-QuickGodot -CommandArgs @("--headless", "--path", $Project, "--import") -TimeoutSeconds 120 -Label "Stage A import"

Write-Host "[2/5] Character Creator shared-rig contract"
Invoke-QuickGodot -CommandArgs @("--headless", "--path", $Project, "-s", "res://tests/presentation/p3_2_modular_actor_contract_test.gd") -TimeoutSeconds 120 -Label "Character Creator shared-rig contract"

Write-Host "[3/5] Female Stage A down/front regression contract"
Invoke-QuickGodot -CommandArgs @("--headless", "--path", $Project, "-s", "res://tests/presentation/p3_2_female_stage_a_down_contract_test.gd") -TimeoutSeconds 120 -Label "Female Stage A down regression contract"

Write-Host "[4/5] Female Stage A authored down/right/up asset contract"
Invoke-QuickGodot -CommandArgs @("--headless", "--path", $Project, "-s", "res://tests/presentation/p3_2_female_stage_a_directions_contract_test.gd") -TimeoutSeconds 120 -Label "Female Stage A three-direction asset contract"

Write-Host "[5/5] Female Stage A authored direction sandbox smoke"
Invoke-QuickGodot -CommandArgs @("--headless", "--path", $Project, "--quit-after", "120", "res://scenes/p3/p3_2_female_stage_a_directions_sandbox.tscn") -TimeoutSeconds 90 -Label "Female Stage A direction sandbox smoke"

Write-Host "P3.2 FEMALE STAGE A 3-DIRECTION FAST CHECK: PASS"
