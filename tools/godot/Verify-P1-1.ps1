param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# P1.1 is additive: the locked P0 9-stage gate must remain green first.
. (Join-Path $PSScriptRoot "Verify-P0.ps1") -GodotBin $GodotBin

Write-Host "[P1.1] Goal + Personality contracts"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/simulation/p1_goal_personality_test.gd"
) -TimeoutSeconds 120 -Label "P1.1 Goal + Personality contracts"

Write-Host "P1.1 GOAL + PERSONALITY GATE: PASS"
