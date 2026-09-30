param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# P1.3 is additive: all locked P0/P1.1/P1.2 gates must remain green first.
. (Join-Path $PSScriptRoot "Verify-P1-2.ps1") -GodotBin $GodotBin

Write-Host "[P1.3] Relationship + behavior-impact contracts"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/simulation/p1_3_relationship_test.gd"
) -TimeoutSeconds 180 -Label "P1.3 Relationship + behavior-impact contracts"

Write-Host "[P1.3] Relationship interaction scene smoke"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "--quit-after", "120",
    "res://scenes/p1/p1_3_relationships.tscn"
) -TimeoutSeconds 60 -Label "P1.3 relationship interaction scene smoke"

Write-Host "P1.3 RELATIONSHIP + BEHAVIOR IMPACT GATE: PASS"
