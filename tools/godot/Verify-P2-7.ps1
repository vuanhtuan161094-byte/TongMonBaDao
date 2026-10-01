param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# P2.7 builds on the locked P2.6 stack and intentionally re-runs all earlier gates first.
. (Join-Path $PSScriptRoot "Verify-P2-6.ps1") -GodotBin $GodotBin

Write-Host "[P2.7] Disciple life + workforce contracts"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/simulation/p2_7_workforce_test.gd"
) -TimeoutSeconds 360 -Label "P2.7 disciple life + workforce contracts"

Write-Host "[P2.7] Workforce interaction scene smoke"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "--quit-after", "120",
    "res://scenes/p2/p2_7_workforce.tscn"
) -TimeoutSeconds 60 -Label "P2.7 workforce interaction scene smoke"

Write-Host "P2.7 DISCIPLE LIFE + WORKFORCE GATE: PASS"
