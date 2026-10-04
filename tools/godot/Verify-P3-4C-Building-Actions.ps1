param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# P3.4C builds on the locked P3.4B people-management baseline.
. (Join-Path $PSScriptRoot "Verify-P3-4B-Building-People.ps1") -GodotBin $GodotBin

Write-Host "[P3.4C] Real building/system action contract"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/presentation/p3_4c_building_system_actions_test.gd"
) -TimeoutSeconds 120 -Label "P3.4C building system actions"

Write-Host "[P3.4C] Live map scene smoke"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "--quit-after", "180",
    "res://scenes/p3/p3_2_landscape_sect.tscn"
) -TimeoutSeconds 90 -Label "P3.4C live map scene smoke"

Write-Host "P3.4C BUILDING SYSTEM ACTIONS GATE: PASS"
