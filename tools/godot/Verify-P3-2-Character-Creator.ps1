param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# Character Creator V1 is additive presentation work. The existing P3.2 camera/UI
# cumulative gate must be green first; this script does not redefine that gate.
. (Join-Path $PSScriptRoot "Verify-P3-2-Camera.ps1") -GodotBin $GodotBin

Write-Host "[P3.2 Character Creator] Shared Skeleton2D rig contracts"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/presentation/p3_2_modular_actor_contract_test.gd"
) -TimeoutSeconds 120 -Label "P3.2 Character Creator shared rig contracts"

Write-Host "P3.2 CHARACTER CREATOR SCAFFOLD GATE: PASS"
