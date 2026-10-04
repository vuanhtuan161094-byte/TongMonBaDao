param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# P3.5 builds on the full runtime-green P3.4 building-management chain.
. (Join-Path $PSScriptRoot "Verify-P3-4C-Building-Actions.ps1") -GodotBin $GodotBin

Write-Host "[P3.5] Living cue resolver + transient tracker contracts"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/presentation/p3_5_living_cue_core_test.gd"
) -TimeoutSeconds 120 -Label "P3.5 living cue core"

Write-Host "[P3.5] Live map cue render + routing contract"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/presentation/p3_5_living_cue_map_integration_test.gd"
) -TimeoutSeconds 120 -Label "P3.5 living cue map integration"

Write-Host "[P3.5] Live sect scene smoke"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "--quit-after", "180",
    "res://scenes/p3/p3_2_landscape_sect.tscn"
) -TimeoutSeconds 90 -Label "P3.5 live sect scene smoke"

Write-Host "P3.5 LIVING SECT CUES GATE: PASS"
