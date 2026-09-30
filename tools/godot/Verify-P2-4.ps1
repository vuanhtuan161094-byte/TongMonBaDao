param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# P2.4 builds on P2.3 and intentionally re-runs every earlier gate first.
. (Join-Path $PSScriptRoot "Verify-P2-3.ps1") -GodotBin $GodotBin

Write-Host "[P2.4] Cultivation path + identity consequence contracts"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/simulation/p2_4_cultivation_path_test.gd"
) -TimeoutSeconds 360 -Label "P2.4 Cultivation path + identity consequence contracts"

Write-Host "[P2.4] Cultivation path interaction scene smoke"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "--quit-after", "120",
    "res://scenes/p2/p2_4_cultivation_paths.tscn"
) -TimeoutSeconds 60 -Label "P2.4 cultivation path interaction scene smoke"

Write-Host "P2.4 CULTIVATION PATH + IDENTITY CONSEQUENCE GATE: PASS"
