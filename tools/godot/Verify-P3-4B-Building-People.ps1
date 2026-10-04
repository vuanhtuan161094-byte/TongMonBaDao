param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# P3.4B builds on the locked P3.4A panel baseline.
. (Join-Path $PSScriptRoot "Verify-P3-4A-Building-Panel.ps1") -GodotBin $GodotBin

Write-Host "[P3.4B] Building people-management contract"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/presentation/p3_4b_building_people_management_test.gd"
) -TimeoutSeconds 120 -Label "P3.4B building people management"

Write-Host "[P3.4B] Live map scene smoke"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "--quit-after", "180",
    "res://scenes/p3/p3_2_landscape_sect.tscn"
) -TimeoutSeconds 90 -Label "P3.4B live map scene smoke"

Write-Host "P3.4B BUILDING PEOPLE MANAGEMENT GATE: PASS"
