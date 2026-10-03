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

function Probe-GodotVersion([string]$Candidate, [string]$ExpectedVersion) {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $Candidate
    $psi.Arguments = "--version"
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $psi
    try {
        if (-not $process.Start()) {
            return [pscustomobject]@{ Ok = $false; Version = ""; Detail = "failed to start" }
        }
        if (-not $process.WaitForExit(10000)) {
            try { $process.Kill() } catch { }
            return [pscustomobject]@{ Ok = $false; Version = ""; Detail = "version probe timed out" }
        }
        $stdout = $process.StandardOutput.ReadToEnd().Trim()
        $stderr = $process.StandardError.ReadToEnd().Trim()
        $version = if (-not [string]::IsNullOrWhiteSpace($stdout)) { ($stdout -split "`r?`n")[0].Trim() } elseif (-not [string]::IsNullOrWhiteSpace($stderr)) { ($stderr -split "`r?`n")[0].Trim() } else { "" }
        $exitCode = [int]$process.ExitCode
        $expectedPattern = "^" + [regex]::Escape($ExpectedVersion)
        if ($exitCode -eq 0 -and $version -match $expectedPattern) {
            return [pscustomobject]@{ Ok = $true; Version = $version; Detail = "exit=0" }
        }
        return [pscustomobject]@{ Ok = $false; Version = $version; Detail = "exit=$exitCode" }
    } catch {
        return [pscustomobject]@{ Ok = $false; Version = ""; Detail = $_.Exception.Message }
    } finally {
        $process.Dispose()
    }
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
    foreach ($candidate in $candidates) {
        Write-Host "[Godot] Probing $candidate"
        $probe = Probe-GodotVersion $candidate $ExpectedVersion
        if ($probe.Ok) {
            return [pscustomobject]@{ Path = $candidate; Version = $probe.Version }
        }
        $failures.Add("$candidate => $($probe.Detail) version='$($probe.Version)'")
    }

    $details = if ($failures.Count -gt 0) {
        [Environment]::NewLine + "Candidates tried:" + [Environment]::NewLine + " - " + ($failures -join ([Environment]::NewLine + " - "))
    } else {
        [Environment]::NewLine + "No Godot executable candidate file was found in GODOT_BIN, PATH, drive root, running processes, Downloads, Desktop, or the repository."
    }
    throw "No working Godot $ExpectedVersion CLI found. Set GODOT_BIN only if auto-discovery still misses it.$details"
}

function Invoke-QuickGodot([string[]]$Args, [int]$TimeoutSeconds, [string]$Label) {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $script:Godot
    $psi.Arguments = (($Args | ForEach-Object {
        $v = [string]$_
        if ($v -match '[\s"]') { '"' + ($v -replace '"','\"') + '"' } else { $v }
    }) -join ' ')
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
            if ($env:OS -eq "Windows_NT") { & taskkill.exe /PID $process.Id /T /F 2>$null | Out-Null } else { $process.Kill() }
            $process.WaitForExit()
            throw "$Label timed out after ${TimeoutSeconds}s."
        }
        $stdout.Wait(); $stderr.Wait()
        if ($stdout.Result) { Write-Host $stdout.Result.TrimEnd() }
        if ($stderr.Result) { Write-Host $stderr.Result.TrimEnd() }
        if ($process.ExitCode -ne 0) { throw "Godot command failed with exit code $($process.ExitCode): $Label" }
    } finally {
        $process.Dispose()
    }
}

$resolvedGodot = Resolve-QuickGodot $GodotBin $ExpectedVersion
$Godot = [string]$resolvedGodot.Path
Write-Host "=== P3.2 FEMALE STAGE A FAST CHECK ==="
Write-Host "[Godot] $($resolvedGodot.Version)"
Write-Host "[Godot] $Godot"

Write-Host "[1/4] Importing new/changed Stage A assets"
Invoke-QuickGodot @("--headless", "--path", $Project, "--import") 120 "Stage A import"

Write-Host "[2/4] Character Creator shared-rig contract"
Invoke-QuickGodot @("--headless", "--path", $Project, "-s", "res://tests/presentation/p3_2_modular_actor_contract_test.gd") 120 "Character Creator shared-rig contract"

Write-Host "[3/4] Female Stage A down/front asset contract"
Invoke-QuickGodot @("--headless", "--path", $Project, "-s", "res://tests/presentation/p3_2_female_stage_a_down_contract_test.gd") 120 "Female Stage A down asset contract"

Write-Host "[4/4] Female Stage A down/front sandbox smoke"
Invoke-QuickGodot @("--headless", "--path", $Project, "--quit-after", "120", "res://scenes/p3/p3_2_female_stage_a_down_sandbox.tscn") 90 "Female Stage A down sandbox smoke"

Write-Host "P3.2 FEMALE STAGE A FAST CHECK: PASS"
