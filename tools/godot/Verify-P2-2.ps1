param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# P2.2 builds on P2.1 and intentionally re-runs every earlier pending/locked gate first.
. (Join-Path $PSScriptRoot "Verify-P2-1.ps1") -GodotBin $GodotBin

Write-Host "[P2.2] Spiritual root + growth consequence contracts"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/simulation/p2_2_spiritual_roots_test.gd"
) -TimeoutSeconds 300 -Label "P2.2 Spiritual root + growth consequence contracts"

Write-Host "[P2.2] Spiritual root recruitment scene smoke"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "--quit-after", "120",
    "res://scenes/p2/p2_2_spiritual_roots.tscn"
) -TimeoutSeconds 60 -Label "P2.2 spiritual root recruitment scene smoke"

Write-Host "P2.2 SPIRITUAL ROOT + GROWTH CONSEQUENCE GATE: PASS"
