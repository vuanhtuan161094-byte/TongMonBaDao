param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# P3.6A productizes the already runtime-green P3.5/P3.4/P3.3 chain.
. (Join-Path $PSScriptRoot "Verify-P3-5-Living-Cues.ps1") -GodotBin $GodotBin

Write-Host "[P3.6A] Player-facing vertical-slice contract"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/presentation/p3_6a_playable_slice_test.gd"
) -TimeoutSeconds 120 -Label "P3.6A playable slice"

Write-Host "[P3.6A] Live main scene smoke"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "--quit-after", "180",
    "res://scenes/p3/p3_2_landscape_sect.tscn"
) -TimeoutSeconds 90 -Label "P3.6A live main scene smoke"

Write-Host "P3.6A PLAYABLE VERTICAL SLICE GATE: PASS"
