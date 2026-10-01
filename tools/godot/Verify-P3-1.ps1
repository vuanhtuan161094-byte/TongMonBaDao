param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# P3.1 is presentation-only and sits on top of the runtime-green P2.12 stack.
. (Join-Path $PSScriptRoot "Verify-P2-12.ps1") -GodotBin $GodotBin

Write-Host "[P3.1] Landscape shell contracts"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/presentation/p3_1_landscape_shell_test.gd"
) -TimeoutSeconds 120 -Label "P3.1 landscape shell contracts"

Write-Host "[P3.1] Landscape living-sect scene smoke"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "--quit-after", "180",
    "res://scenes/p3/p3_1_landscape_sect.tscn"
) -TimeoutSeconds 90 -Label "P3.1 landscape living-sect scene smoke"

Write-Host "P3.1 LANDSCAPE SECT SHELL GATE: PASS"
