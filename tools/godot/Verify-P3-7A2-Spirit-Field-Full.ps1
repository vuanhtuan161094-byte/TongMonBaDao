param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# Full P0-P2.12 + P3.7A1 regression first.
. (Join-Path $PSScriptRoot "Verify-P3-7A1-Building-Authority-Full.ps1") -GodotBin $GodotBin

Write-Host "[P3.7A2] Parse Spirit Field backend scripts"
foreach ($script in @(
    "res://src/simulation/state/building_state.gd",
    "res://src/simulation/building/building_system.gd",
    "res://src/simulation/state/disciple_state.gd",
    "res://src/simulation/workforce/workforce_system.gd",
    "res://src/simulation/core/simulation_scheduler.gd",
    "res://tests/simulation/p3_7a2_spirit_field_test.gd"
)) {
    Invoke-GodotWithTimeout -CommandArgs @(
        "--headless",
        "--path", $Project,
        "--check-only",
        "--script", $script
    ) -TimeoutSeconds 60 -Label "P3.7A2 parse $script"
}

Write-Host "[P3.7A2] Spirit Field lifecycle contracts"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/simulation/p3_7a2_spirit_field_test.gd"
) -TimeoutSeconds 240 -Label "P3.7A2 Spirit Field contract"

Write-Host "P3.7A2 SPIRIT FIELD FULL GATE: PASS"
