param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# P3.2 remains presentation over the runtime-green simulation. Re-run the full
# P3.1 cumulative chain before checking camera and integrated disciple UI.
. (Join-Path $PSScriptRoot "Verify-P3-1.ps1") -GodotBin $GodotBin

Write-Host "[P3.2 Camera] Zoom + pan + focus contracts"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/presentation/p3_2_map_camera_test.gd"
) -TimeoutSeconds 120 -Label "P3.2 map camera contracts"

Write-Host "[P3.2 UI] Disciple tabs + real-system action contracts"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/presentation/p3_2_disciple_ui_test.gd"
) -TimeoutSeconds 120 -Label "P3.2 disciple UI integration"

Write-Host "[P3.2] Zoomable landscape scene smoke"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "--quit-after", "180",
    "res://scenes/p3/p3_2_landscape_sect.tscn"
) -TimeoutSeconds 90 -Label "P3.2 zoomable landscape scene smoke"

Write-Host "P3.2 CAMERA + DISCIPLE UI GATE: PASS"
