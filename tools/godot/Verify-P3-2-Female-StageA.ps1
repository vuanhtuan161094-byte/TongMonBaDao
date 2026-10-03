param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$Project = Join-Path $RepoRoot "godot"
$ToolingLock = Get-Content -Raw (Join-Path $PSScriptRoot "TOOLING_LOCK.json") | ConvertFrom-Json
$ExpectedVersion = [string]$ToolingLock.engine.version

function Add-Candidate([System.Collections.Generic.List[string]]$List, [string]$Path) {
    if ([string]::IsNullOrWhiteSpace($Path)) { return }
    try {
        if (-not (Test-Path $Path -PathType Leaf)) { return }
        $resolved = (Resolve-Path $Path).Path
        if (-not $List.Contains($resolved)) { $List.Add($resolved) }
    } catch { }
}

function Resolve-QuickGodot([string]$Explicit) {
    $candidates = New-Object "System.Collections.Generic.List[string]"
    Add-Candidate $candidates $Explicit

    foreach ($name in @("Godot_v4.7.2-stable_win64_console.exe", "godot_console.exe", "godot.exe", "godot")) {
        $cmd = Get-Command $name -ErrorAction SilentlyContinue
        if ($null -ne $cmd -and $cmd.Source) { Add-Candidate $candidates $cmd.Source }
    }

    if ($env:OS -eq "Windows_NT") {
        $driveRoot = [IO.Path]::GetPathRoot($RepoRoot)
        Add-Candidate $candidates (Join-Path $driveRoot "Godot_v4.7.2-stable_win64_console.exe")
        Add-Candidate $candidates (Join-Path $driveRoot "Godot_v4.7.2-stable_win64.exe")
        foreach ($p in @(Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -like "Godot*" -and $_.Path })) {
            Add-Candidate $candidates $p.Path
        }
    }

    foreach ($candidate in $candidates) {
        $version = (& $candidate --version 2>$null | Select-Object -First 1)
        if ($LASTEXITCODE -eq 0 -and ([string]$version).Trim().StartsWith($ExpectedVersion)) {
            return $candidate
        }
    }
    throw "No working Godot $ExpectedVersion CLI found. Set GODOT_BIN if auto-discovery misses it."
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

$Godot = Resolve-QuickGodot $GodotBin
Write-Host "=== P3.2 FEMALE STAGE A FAST CHECK ==="
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
