param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# P2.8 builds on the runtime-green P2.7 stack and re-runs every earlier gate first.
. (Join-Path $PSScriptRoot "Verify-P2-7.ps1") -GodotBin $GodotBin

Write-Host "[P2.8] Persistence diagnostic"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/simulation/p2_8_persistence_diagnostic.gd"
) -TimeoutSeconds 240 -Label "P2.8 persistence diagnostic"

Write-Host "[P2.8] Disciple generation v2 contracts"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/simulation/p2_8_disciple_generation_test.gd"
) -TimeoutSeconds 360 -Label "P2.8 disciple generation v2 contracts"

Write-Host "[P2.8] Disciple identity interaction scene smoke"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "--quit-after", "120",
    "res://scenes/p2/p2_8_disciple_generation.tscn"
) -TimeoutSeconds 60 -Label "P2.8 disciple identity interaction scene smoke"

Write-Host "P2.8 DISCIPLE GENERATION V2 GATE: PASS"
