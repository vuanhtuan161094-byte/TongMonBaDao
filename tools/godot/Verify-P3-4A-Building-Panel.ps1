param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# P3.4A builds on the locked P3.3 interaction flow.
. (Join-Path $PSScriptRoot "Verify-P3-3-Disciple-Flow.ps1") -GodotBin $GodotBin

Write-Host "[P3.4A] Read-only building operation panel contract"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/presentation/p3_4a_building_operation_panel_test.gd"
) -TimeoutSeconds 120 -Label "P3.4A building operation panel"

Write-Host "[P3.4A] Live map scene smoke"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "--quit-after", "180",
    "res://scenes/p3/p3_2_landscape_sect.tscn"
) -TimeoutSeconds 90 -Label "P3.4A live map scene smoke"

Write-Host "P3.4A BUILDING OPERATION PANEL GATE: PASS"
