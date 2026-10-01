param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# P2.12 sits on top of the runtime-green P2.11 stack and re-runs every earlier gate first.
. (Join-Path $PSScriptRoot "Verify-P2-11.ps1") -GodotBin $GodotBin

Write-Host "[P2.12] Persistence diagnostic"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/simulation/p2_12_persistence_diagnostic.gd"
) -TimeoutSeconds 240 -Label "P2.12 persistence diagnostic"

Write-Host "[P2.12] Physique + tempering + transformation contracts"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/simulation/p2_12_physique_test.gd"
) -TimeoutSeconds 360 -Label "P2.12 physique + tempering + transformation contracts"

Write-Host "[P2.12] Physique interaction scene smoke"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "--quit-after", "120",
    "res://scenes/p2/p2_12_physique.tscn"
) -TimeoutSeconds 60 -Label "P2.12 physique interaction scene smoke"

Write-Host "P2.12 PHYSIQUE + TEMPERING + TRANSFORMATION GATE: PASS"
