param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# P2.10 sits on top of P2.9 and re-runs every earlier gate first.
. (Join-Path $PSScriptRoot "Verify-P2-9.ps1") -GodotBin $GodotBin

Write-Host "[P2.10] Persistence diagnostic"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/simulation/p2_10_persistence_diagnostic.gd"
) -TimeoutSeconds 240 -Label "P2.10 persistence diagnostic"

Write-Host "[P2.10] Spiritual root refinement + mutation contracts"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/simulation/p2_10_root_refinement_test.gd"
) -TimeoutSeconds 360 -Label "P2.10 spiritual root refinement + mutation contracts"

Write-Host "[P2.10] Spiritual root interaction scene smoke"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "--quit-after", "120",
    "res://scenes/p2/p2_10_root_refinement.tscn"
) -TimeoutSeconds 60 -Label "P2.10 spiritual root interaction scene smoke"

Write-Host "P2.10 SPIRITUAL ROOT REFINEMENT + MUTATION GATE: PASS"
