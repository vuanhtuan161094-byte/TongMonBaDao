param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# P2.6 builds on P2.5 and intentionally re-runs every earlier gate first.
. (Join-Path $PSScriptRoot "Verify-P2-5.ps1") -GodotBin $GodotBin

Write-Host "[P2.6] Forge + autonomous/manual equipment contracts"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/simulation/p2_6_equipment_test.gd"
) -TimeoutSeconds 360 -Label "P2.6 forge + autonomous/manual equipment contracts"

Write-Host "[P2.6] Equipment interaction scene smoke"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "--quit-after", "120",
    "res://scenes/p2/p2_6_equipment.tscn"
) -TimeoutSeconds 60 -Label "P2.6 equipment interaction scene smoke"

Write-Host "P2.6 FORGE + EQUIPMENT TYCOON GATE: PASS"
