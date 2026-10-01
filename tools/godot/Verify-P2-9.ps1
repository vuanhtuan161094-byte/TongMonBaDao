param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# P2.9 builds on the runtime-green P2.8 stack and re-runs every earlier gate first.
. (Join-Path $PSScriptRoot "Verify-P2-8.ps1") -GodotBin $GodotBin

Write-Host "[P2.9] Persistence diagnostic"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/simulation/p2_9_persistence_diagnostic.gd"
) -TimeoutSeconds 240 -Label "P2.9 persistence diagnostic"

Write-Host "[P2.9] Traits + hidden reveal contracts"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/simulation/p2_9_traits_test.gd"
) -TimeoutSeconds 360 -Label "P2.9 traits + hidden reveal contracts"

Write-Host "[P2.9] Trait profile interaction scene smoke"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "--quit-after", "120",
    "res://scenes/p2/p2_9_traits.tscn"
) -TimeoutSeconds 60 -Label "P2.9 trait profile interaction scene smoke"

Write-Host "P2.9 TRAITS + HIDDEN REVEAL GATE: PASS"
