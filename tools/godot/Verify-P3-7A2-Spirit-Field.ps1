param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# First prove the complete P3.7A1 Building/Mine backend contract.
. (Join-Path $PSScriptRoot "Verify-P3-7A1-Building-Authority.ps1") -GodotBin $GodotBin

Write-Host "[P3.7A2] Parse Spirit Field backend scripts"
foreach ($script in @(
    "res://src/simulation/state/building_state.gd",
    "res://src/simulation/building/building_system.gd",
    "res://src/simulation/state/disciple_state.gd",
    "res://src/simulation/workforce/workforce_system.gd",
    "res://src/simulation/core/simulation_scheduler.gd",
    "res://tests/simulation/p3_7a2_spirit_field_test.gd"
)) {
    Invoke-FastGodot @("--headless","--path",$Project,"--check-only","--script",$script) "Parse $script"
}

Write-Host "[P3.7A2] Spirit Field lifecycle contracts"
Invoke-FastGodot @("--headless","--path",$Project,"-s","res://tests/simulation/p3_7a2_spirit_field_test.gd") "P3.7A2 Spirit Field contract"

Write-Host "P3.7A2 SPIRIT FIELD FAST GATE: PASS"
