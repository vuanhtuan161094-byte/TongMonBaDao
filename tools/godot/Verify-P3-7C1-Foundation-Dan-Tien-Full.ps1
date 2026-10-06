param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# Closing gate: prove the full locked P0-P2.12 + P3.7A/B baseline first.
. (Join-Path $PSScriptRoot "Verify-P3-7B1-Warehouse-Full.ps1") -GodotBin $GodotBin

Write-Host "[P3.7C1] Parse open-foundation + Dẫn Tiên backend"
foreach ($script in @(
    "res://src/simulation/foundation/foundation_system.gd",
    "res://src/simulation/recruitment/disciple_generator_open_points.gd",
    "res://src/simulation/recruitment/recruitment_system.gd",
    "res://src/simulation/state/disciple_state.gd",
    "res://src/simulation/state/candidate_state.gd",
    "res://src/simulation/state/sect_state.gd",
    "res://src/simulation/building/building_system.gd",
    "res://src/simulation/workforce/character_modifier_system.gd",
    "res://src/simulation/save/save_service.gd",
    "res://src/simulation/core/p3_7_factory.gd",
    "res://src/simulation/core/simulation_scheduler.gd",
    "res://tests/simulation/p3_7c1_foundation_guidance_test.gd"
)) {
    Invoke-GodotWithTimeout -CommandArgs @(
        "--headless",
        "--path", $Project,
        "--check-only",
        "--script", $script
    ) -TimeoutSeconds 60 -Label "P3.7C1 parse $script"
}

Write-Host "[P3.7C1] Six-foundation + Dẫn Tiên contracts"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/simulation/p3_7c1_foundation_guidance_test.gd"
) -TimeoutSeconds 240 -Label "P3.7C1 contract"

Write-Host "P3.7C1 FOUNDATION + DAN TIEN FULL GATE: PASS"
