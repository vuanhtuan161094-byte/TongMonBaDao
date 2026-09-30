param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# P2.1 builds on the full P1.6 stack. P1.4-P1.6 are still awaiting the same local runtime proof.
. (Join-Path $PSScriptRoot "Verify-P1-6.ps1") -GodotBin $GodotBin

Write-Host "[P2.1] Cultivation + breakthrough consequence contracts"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/simulation/p2_1_cultivation_test.gd"
) -TimeoutSeconds 300 -Label "P2.1 Cultivation + breakthrough consequence contracts"

Write-Host "[P2.1] Cultivation interaction scene smoke"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "--quit-after", "120",
    "res://scenes/p2/p2_1_cultivation.tscn"
) -TimeoutSeconds 60 -Label "P2.1 cultivation interaction scene smoke"

Write-Host "P2.1 CULTIVATION + BREAKTHROUGH CONSEQUENCE GATE: PASS"
