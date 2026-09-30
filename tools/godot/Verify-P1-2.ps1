param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# P1.2 is additive: P0 and the locked P1.1 gate must remain green first.
. (Join-Path $PSScriptRoot "Verify-P1-1.ps1") -GodotBin $GodotBin

Write-Host "[P1.2] Recruitment + player-choice contracts"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/simulation/p1_2_recruitment_test.gd"
) -TimeoutSeconds 150 -Label "P1.2 Recruitment + player-choice contracts"

Write-Host "[P1.2] Recruitment interaction scene smoke"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "--quit-after", "120",
    "res://scenes/p1/p1_2_recruitment.tscn"
) -TimeoutSeconds 60 -Label "P1.2 recruitment interaction scene smoke"

Write-Host "P1.2 RECRUITMENT + PLAYER CHOICE GATE: PASS"
