# CODE-R0 QA: read-only Git grep plus exact Godot 4.7.2 focused tests.
# Produces reports under artifacts/qa/code_r0/; never edits gameplay/save.
# Usage: pwsh -NoProfile -File tools/qa/Invoke-CodeR0-Focused.ps1 -GodotBin "E:\\Tools\\Godot_v4.7.2-stable_win64_console.exe"
[CmdletBinding()]
param(
    [string] $GodotBin = "godot",
    [string] $OutputDir = "",
    [switch] $GrepOnly
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$repo = (Resolve-Path (Join-Path $PSScriptRoot "../..")).Path
$baseline = "5fbdbc6309c3f1386f0d8b619831e007c5a52824"
$tests = @(
    "combat_finite_world_reward_isolation_test",
    "b3_ph0_continuous_kernel_test",
    "b3_fasttrack_hunt_test",
    "b3_care_pills_autohunt_test",
    "combat_v3_s1_edge_contract_test",
    "combat_v3_s1_effects_test",
    "dv2_02_combat_stats_test",
    "dv2_02_group_map_battle_test",
    "dv2_02_battle_snapshot_test",
    "dv2_02_five_level_pve_test",
    "dv2_02_five_level_balance_test",
    "gp_02c1_injury_settlement_test",
    "dv2_03_f0_source_baseline_test",
    "dv2_03_f1_body_gate_manifest_test",
    "dv2_03_f2_body_gate_transaction_test",
    "dv2_03_f3_body_material_earned_claim_test",
    "dv2_03_f6_real_earned_body_gate_integration_test",
    "p2_5_combat_skill_test",
    "p2_6_equipment_combat_effects_test",
    "safe_01_save_recovery_test",
    "safe_02_warehouse_migration_test"
)
Push-Location $repo
try {
    if ([string]::IsNullOrWhiteSpace($OutputDir)) {
        $OutputDir = Join-Path $repo ("artifacts/qa/code_r0/" + (Get-Date -Format "yyyyMMdd-HHmmss"))
    }
    New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
    $head = (& git rev-parse HEAD | Out-String).Trim()
    $branch = (& git branch --show-current | Out-String).Trim()
    & git merge-base --is-ancestor $baseline HEAD
    if ($LASTEXITCODE -ne 0) { throw "HEAD does not descend from CODE-CLEAN baseline $baseline" }
    $dirty = (& git status --porcelain=v1 | Out-String).Trim()
    $provenance = @(
        "HEAD=$head", "BRANCH=$branch", "BASELINE=$baseline",
        "UTC=$([DateTime]::UtcNow.ToString('o'))", "GODOT_TARGET=4.7.2",
        "TREE_DIRTY=$([bool]$dirty)", "OUTPUT=$OutputDir"
    )
    $provenance | Set-Content (Join-Path $OutputDir "provenance.txt") -Encoding UTF8
    & git ls-files | Set-Content (Join-Path $OutputDir "tracked-files.txt") -Encoding UTF8
    $pattern = 'MAX_SECONDS|LEGACY_FINITE_MAX_SECONDS|MAX_REALTIME_SECONDS|timeout_retreat|HuntingPveRunV2|HuntingMapV2|claim_reward|v2_pve_active_runs|v2_pve_reward_claims|v2_pve_settlement_receipts|active_pve_encounter_id|MapBattleSnapshotV2|MapBattleV2|CombatSystem|resolve_encounter'
    $grepFiles = @('*.gd','*.tscn','*.tres','*.ps1','*.cmd','*.py','*.yml','*.yaml','*.json','*.md')
    $matches = & git grep -n -E $pattern -- $grepFiles 2>&1
    $grepExit = $LASTEXITCODE
    if ($grepExit -gt 1) { throw "git grep failed with exit $grepExit" }
    @($matches) | Set-Content (Join-Path $OutputDir "COMBAT_FINITE_ALL_CALLERS.txt") -Encoding UTF8
    Write-Host ("CODE-R0 GREP matches={0} head={1}" -f @($matches).Count,$head)
    if ($GrepOnly) {
        "GREP_ONLY_COMPLETE=TRUE" | Set-Content (Join-Path $OutputDir "summary.txt") -Encoding UTF8
        exit 0
    }
    $resolved = Get-Command $GodotBin -ErrorAction SilentlyContinue
    if ($null -eq $resolved) {
        "BLOCKED: Godot 4.7.2 executable not found: $GodotBin" | Set-Content (Join-Path $OutputDir "summary.txt") -Encoding UTF8
        throw "Godot executable not found. Grep evidence saved at $OutputDir"
    }
    $bin = $resolved.Source
    $version = (& $bin --version 2>&1 | Out-String).Trim()
    $version | Set-Content (Join-Path $OutputDir "godot-version.txt") -Encoding UTF8
    if (-not $version.StartsWith("4.7.2")) {
        "BLOCKED: wrong Godot version $version" | Set-Content (Join-Path $OutputDir "summary.txt") -Encoding UTF8
        throw "Official Godot 4.7.2 required, got $version"
    }
    $failed = 0
    $results = New-Object System.Collections.Generic.List[string]
    $results.Add("case,exit_code")
    $runs = @(
        @{ Name="import"; Args=@("--headless","--path","godot","--editor","--quit") }
    )
    foreach ($name in $tests) {
        $scriptPath = Join-Path $repo "godot/tests/simulation/$name.gd"
        if (-not (Test-Path -LiteralPath $scriptPath)) { throw "Missing test file $scriptPath" }
        $runs += @{ Name=$name; Args=@("--headless","--path","godot","-s","res://tests/simulation/$name.gd") }
    }
    foreach ($run in $runs) {
        $name = [string] $run.Name
        $stdout = Join-Path $OutputDir ("$name.stdout.log")
        $stderr = Join-Path $OutputDir ("$name.stderr.log")
        Write-Host "CASE_START $name"
        $process = Start-Process -FilePath $bin -ArgumentList $run.Args -WorkingDirectory $repo -Wait -PassThru -NoNewWindow -RedirectStandardOutput $stdout -RedirectStandardError $stderr
        $exitCode = [int] $process.ExitCode
        $results.Add("$name,$exitCode")
        Write-Host "CASE_END $name exit=$exitCode"
        if ($exitCode -ne 0) { $failed++ }
    }
    $results | Set-Content (Join-Path $OutputDir "test-exit-codes.csv") -Encoding UTF8
    "TOTAL=$($runs.Count);FAILED=$failed;SHA=$head;GODOT=$version" |
        Set-Content (Join-Path $OutputDir "summary.txt") -Encoding UTF8
    Write-Host "CODE-R0 COMPLETED: tests=$($runs.Count) failures=$failed logs=$OutputDir"
    if ($failed -gt 0) { exit 1 }
    exit 0
}
finally {
    Pop-Location
}
