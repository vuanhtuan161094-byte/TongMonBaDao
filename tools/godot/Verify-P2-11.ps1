param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# P2.11 sits on top of the runtime-green P2.10 stack and re-runs every earlier gate first.
. (Join-Path $PSScriptRoot "Verify-P2-10.ps1") -GodotBin $GodotBin

Write-Host "[P2.11] Persistence diagnostic"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/simulation/p2_11_persistence_diagnostic.gd"
) -TimeoutSeconds 240 -Label "P2.11 persistence diagnostic"

Write-Host "[P2.11] Bloodline + awakening contracts"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/simulation/p2_11_bloodline_test.gd"
) -TimeoutSeconds 360 -Label "P2.11 bloodline + awakening contracts"

Write-Host "[P2.11] Bloodline interaction scene smoke"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "--quit-after", "120",
    "res://scenes/p2/p2_11_bloodline.tscn"
) -TimeoutSeconds 60 -Label "P2.11 bloodline interaction scene smoke"

Write-Host "P2.11 BLOODLINE + AWAKENING GATE: PASS"
