param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# Stage A is an additive visual proof. Keep the full runtime-green Character Creator
# chain green before checking locally installed pivot-lock assets.
. (Join-Path $PSScriptRoot "Verify-P3-2-Character-Creator.ps1") -GodotBin $GodotBin

Write-Host "[P3.2 Female Stage A] Down/front asset contracts"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/presentation/p3_2_female_stage_a_down_contract_test.gd"
) -TimeoutSeconds 120 -Label "P3.2 female Stage A down asset contracts"

Write-Host "[P3.2 Female Stage A] Down/front sandbox smoke"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "--quit-after", "120",
    "res://scenes/p3/p3_2_female_stage_a_down_sandbox.tscn"
) -TimeoutSeconds 90 -Label "P3.2 female Stage A down sandbox smoke"

Write-Host "P3.2 FEMALE STAGE A DOWN PIVOT-LOCK GATE: PASS"
