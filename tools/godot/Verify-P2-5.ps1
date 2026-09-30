param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# P2.5 builds on P2.4 and intentionally re-runs every earlier gate first.
. (Join-Path $PSScriptRoot "Verify-P2-4.ps1") -GodotBin $GodotBin

Write-Host "[P2.5] Real-time combat + independent skill contracts"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/simulation/p2_5_combat_skill_test.gd"
) -TimeoutSeconds 360 -Label "P2.5 real-time combat + independent skill contracts"

Write-Host "[P2.5] Combat skill interaction scene smoke"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "--quit-after", "120",
    "res://scenes/p2/p2_5_combat_skills.tscn"
) -TimeoutSeconds 60 -Label "P2.5 combat skill interaction scene smoke"

Write-Host "P2.5 REALTIME COMBAT + INDEPENDENT SKILLS GATE: PASS"
