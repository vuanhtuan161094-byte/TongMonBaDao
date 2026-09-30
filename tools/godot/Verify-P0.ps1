$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$Project = Join-Path $RepoRoot "godot"

function Invoke-Godot([string[]]$Args) {
    & godot @Args
    if ($LASTEXITCODE -ne 0) {
        throw "Godot command failed with exit code $LASTEXITCODE : godot $($Args -join ' ')"
    }
}

Write-Host "=== TONG MON TYCOON P0 GATE ==="
& godot --version
if ($LASTEXITCODE -ne 0) { throw "Godot executable not found or failed." }

Write-Host "[1/7] Import"
Invoke-Godot @("--headless", "--path", $Project, "--import")

Write-Host "[2/7] Parse project scripts"
$Scripts = Get-ChildItem -Path (Join-Path $Project "src"), (Join-Path $Project "tests") -Recurse -Filter *.gd
foreach ($Script in $Scripts) {
    $Relative = $Script.FullName.Substring($Project.Length + 1).Replace("\", "/")
    Invoke-Godot @("--headless", "--path", $Project, "--check-only", "--script", "res://$Relative")
}

Write-Host "[3/7] Deterministic invariant scenario"
Invoke-Godot @("--headless", "--path", $Project, "-s", "res://tests/simulation/p0_invariant_test.gd")

Write-Host "[4/7] Save/load round trip"
Invoke-Godot @("--headless", "--path", $Project, "-s", "res://tests/simulation/p0_save_roundtrip_test.gd")

Write-Host "[5/7] Same-seed reproducibility"
Invoke-Godot @("--headless", "--path", $Project, "-s", "res://tests/simulation/p0_reproducibility_test.gd")

Write-Host "[6/7] Multi-seed benchmark"
Invoke-Godot @("--headless", "--path", $Project, "-s", "res://tests/simulation/p0_benchmark_test.gd")

Write-Host "[7/7] Runtime smoke"
Invoke-Godot @("--headless", "--path", $Project, "--quit-after", "180")

Write-Host "P0 FOUNDATION GATE: PASS"
