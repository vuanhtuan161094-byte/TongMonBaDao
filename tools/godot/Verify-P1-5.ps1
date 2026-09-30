param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# P1.5 builds on P1.4, which is still awaiting the same local runtime proof.
. (Join-Path $PSScriptRoot "Verify-P1-4.ps1") -GodotBin $GodotBin

Write-Host "[P1.5] Organization + player-management contracts"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/simulation/p1_5_organization_test.gd"
) -TimeoutSeconds 210 -Label "P1.5 Organization + player-management contracts"

Write-Host "[P1.5] Organization interaction scene smoke"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "--quit-after", "120",
    "res://scenes/p1/p1_5_organization.tscn"
) -TimeoutSeconds 60 -Label "P1.5 organization interaction scene smoke"

Write-Host "P1.5 ORGANIZATION + PLAYER MANAGEMENT GATE: PASS"
