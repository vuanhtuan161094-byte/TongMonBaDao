param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# P2.3 builds on P2.2 and intentionally re-runs every earlier gate first.
. (Join-Path $PSScriptRoot "Verify-P2-2.ps1") -GodotBin $GodotBin

Write-Host "[P2.3] Technique economy + mastery consequence contracts"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/simulation/p2_3_technique_test.gd"
) -TimeoutSeconds 360 -Label "P2.3 Technique economy + mastery consequence contracts"

Write-Host "[P2.3] Technique interaction scene smoke"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "--quit-after", "120",
    "res://scenes/p2/p2_3_techniques.tscn"
) -TimeoutSeconds 60 -Label "P2.3 technique interaction scene smoke"

Write-Host "P2.3 TECHNIQUE ECONOMY + MASTERY CONSEQUENCE GATE: PASS"
