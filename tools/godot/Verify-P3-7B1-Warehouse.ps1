param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# Preserve all P3.7A contracts before validating the warehouse migration.
. (Join-Path $PSScriptRoot "Verify-P3-7A2-Spirit-Field.ps1") -GodotBin $GodotBin

Write-Host "[P3.7B1] Parse canonical resource/warehouse backend"
foreach ($script in @(
    "res://src/simulation/resource/resource_registry.gd",
    "res://src/simulation/resource/warehouse_system.gd",
    "res://src/simulation/state/sect_state.gd",
    "res://src/simulation/save/save_service.gd",
    "res://src/simulation/core/p3_7_factory.gd",
    "res://src/simulation/building/building_system.gd",
    "res://src/simulation/equipment/equipment_system.gd",
    "res://src/simulation/technique/technique_system.gd",
    "res://src/simulation/cultivation/root_refinement_system.gd",
    "res://src/simulation/bloodline/bloodline_system.gd",
    "res://src/simulation/physique/physique_system.gd",
    "res://tests/simulation/p3_7b1_warehouse_test.gd"
)) {
    Invoke-FastGodot @("--headless","--path",$Project,"--check-only","--script",$script) "Parse $script"
}

Write-Host "[P3.7B1] Resource Registry + canonical warehouse contracts"
Invoke-FastGodot @("--headless","--path",$Project,"-s","res://tests/simulation/p3_7b1_warehouse_test.gd") "P3.7B1 warehouse contract"

Write-Host "P3.7B1 CANONICAL WAREHOUSE FAST GATE: PASS"
