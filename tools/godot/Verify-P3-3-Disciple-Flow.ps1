param(
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"

# P3.3 is presentation over the locked simulation + P3.2 interaction baseline.
# Re-run that cumulative interaction chain first; the separate female Stage A
# FAST gate remains the authority for the external-pack live modular actor proof.
. (Join-Path $PSScriptRoot "Verify-P3-2-Camera.ps1") -GodotBin $GodotBin

Write-Host "[P3.3] Disciple operational summary -> deep screen -> context restore"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "-s", "res://tests/presentation/p3_3_disciple_operational_flow_test.gd"
) -TimeoutSeconds 120 -Label "P3.3 disciple operational flow"

Write-Host "[P3.3] Live map scene smoke"
Invoke-GodotWithTimeout -CommandArgs @(
    "--headless",
    "--path", $Project,
    "--quit-after", "180",
    "res://scenes/p3/p3_2_landscape_sect.tscn"
) -TimeoutSeconds 90 -Label "P3.3 live map scene smoke"

Write-Host "P3.3 DISCIPLE OPERATIONAL FLOW GATE: PASS"
