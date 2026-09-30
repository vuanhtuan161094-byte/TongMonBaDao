param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# P1.6 builds on P1.5; P1.4/P1.5 are still awaiting the same local runtime proof.
. (Join-Path $PSScriptRoot "Verify-P1-5.ps1") -GodotBin $GodotBin

Write-Host "[P1.6] Sect needs + resource-consequence contracts"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/simulation/p1_6_needs_test.gd"
) -TimeoutSeconds 240 -Label "P1.6 Sect needs + resource-consequence contracts"

Write-Host "[P1.6] Sect needs interaction scene smoke"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "--quit-after", "120",
    "res://scenes/p1/p1_6_needs.tscn"
) -TimeoutSeconds 60 -Label "P1.6 sect needs interaction scene smoke"

Write-Host "P1.6 SECT NEEDS + RESOURCE CONSEQUENCE GATE: PASS"
