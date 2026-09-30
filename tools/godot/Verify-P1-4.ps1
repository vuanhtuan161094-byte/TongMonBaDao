param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# P1.4 is additive: all locked P0/P1.1/P1.2/P1.3 gates must remain green first.
. (Join-Path $PSScriptRoot "Verify-P1-3.ps1") -GodotBin $GodotBin

Write-Host "[P1.4] Memory + consequence contracts"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/simulation/p1_4_memory_test.gd"
) -TimeoutSeconds 210 -Label "P1.4 Memory + consequence contracts"

Write-Host "[P1.4] Memory interaction scene smoke"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "--quit-after", "120",
    "res://scenes/p1/p1_4_memories.tscn"
) -TimeoutSeconds 60 -Label "P1.4 memory interaction scene smoke"

Write-Host "P1.4 MEMORY + CONSEQUENCE GATE: PASS"
