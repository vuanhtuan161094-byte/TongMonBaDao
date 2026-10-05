param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# Final/cross-baseline gate: prove the complete locked P0-P2.12 stack first.
. (Join-Path $PSScriptRoot "Verify-P2-12.ps1") -GodotBin $GodotBin

Write-Host "[P3.7A1] Parse new backend scripts"
foreach ($script in @(
    "res://src/simulation/state/building_state.gd",
    "res://src/simulation/building/building_system.gd",
    "res://src/simulation/core/p3_7_factory.gd",
    "res://tests/simulation/p3_7a1_building_authority_test.gd"
)) {
    Invoke-GodotWithTimeout -CommandArgs @(
        "--headless",
        "--path", $Project,
        "--check-only",
        "--script", $script
    ) -TimeoutSeconds 60 -Label "P3.7A1 parse $script"
}

Write-Host "[P3.7A1] Building authority + Mine backend contracts"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/simulation/p3_7a1_building_authority_test.gd"
) -TimeoutSeconds 240 -Label "P3.7A1 building authority contract"

Write-Host "P3.7A1 BUILDING AUTHORITY FULL GATE: PASS"
