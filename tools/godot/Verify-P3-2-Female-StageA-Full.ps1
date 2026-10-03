param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# Final acceptance only: rerun the complete already-locked runtime chain first,
# then verify the Stage A production proof. Do not use this for every art tweak.
. (Join-Path $PSScriptRoot "Verify-P3-2-Character-Creator.ps1") -GodotBin $GodotBin

Write-Host "[P3.2 Female Stage A FULL] Down/front regression contract"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/presentation/p3_2_female_stage_a_down_contract_test.gd"
) -TimeoutSeconds 120 -Label "P3.2 female Stage A down regression contract"

Write-Host "[P3.2 Female Stage A FULL] Authored DOWN / RIGHT / UP asset contract"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/presentation/p3_2_female_stage_a_directions_contract_test.gd"
) -TimeoutSeconds 120 -Label "P3.2 female Stage A three-direction asset contract"

Write-Host "[P3.2 Female Stage A FULL] Authored direction sandbox smoke"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "--quit-after", "120",
    "res://scenes/p3/p3_2_female_stage_a_directions_sandbox.tscn"
) -TimeoutSeconds 90 -Label "P3.2 female Stage A direction sandbox smoke"

Write-Host "P3.2 FEMALE STAGE A FULL CUMULATIVE GATE: PASS"
