$ErrorActionPreference = 'Continue'
$sourceSha = '4b02a0c61a2771d9d4638129d96b68ad292270dc'
$sourceTreeSha = '352700b65d3cd0ef7039df22a1153d81b2fd7b82'
$godot = 'E:\Godot_v4.7.2-stable_win64_console.exe'
$project = (Resolve-Path 'godot').Path
$root = (Resolve-Path 'artifacts/packet_b').Path
$logs = Join-Path $root 'logs/focused_sha4b02'
$userdata = Join-Path $root 'userdata/focused_sha4b02'
New-Item -ItemType Directory -Force -Path $logs,$userdata | Out-Null

$tests = @(
    'd7_foundation_v3_migration_test.gd',
    'b3_main_hunt_integration_test.gd',
    'b3_fasttrack_hunt_test.gd',
    'b3_care_pills_autohunt_test.gd',
    'b3_pill_satiety_test.gd',
    'b3_ph0_continuous_kernel_test.gd',
    'dv2_02_battle_snapshot_test.gd',
    'dv2_02_group_map_battle_test.gd',
    'dv2_02_five_level_pve_test.gd',
    'gp_02c1_injury_settlement_test.gd',
    'dv2_03_p3_v2_disciple_profile_test.gd',
    'gp_02a_v2_cultivation_panel_test.gd',
    'p3_2_map_camera_test.gd',
    'p3_1_landscape_shell_test.gd',
    'sect_iso_projection_contract_test.gd',
    'sect_map25_verified_art_gate_test.gd',
    'sect_iso_main_integration_test.gd',
    'sect_g1_disciple_radar_test.gd',
    'b3_care_combat_v5_presenter_test.gd',
    'p3_o9_m2_production_rehearsal_test.gd',
    'tmb_pr27_ui_readability_test.gd',
    'combat_v3_s1_effects_test.gd',
    'dv2_02_combat_stats_test.gd',
    'dv2_02_monster_context_test.gd',
    'p2_5_combat_skill_test.gd',
    'p2_6_equipment_combat_effects_test.gd',
    'combat_v3_s1_edge_contract_test.gd',
    'pr28_s1_combat_status_presenter_test.gd'
)

$results = [System.Collections.Generic.List[object]]::new()
foreach ($test in $tests) {
    $category = if (Test-Path -LiteralPath (Join-Path $project ("tests/simulation/$test"))) { 'simulation' } else { 'presentation' }
    $scriptPath = "res://tests/$category/$test"
    $localScript = Join-Path $project ("tests/$category/$test")
    if (-not (Test-Path -LiteralPath $localScript)) {
        $results.Add([pscustomobject]@{ TestPath=$scriptPath; SourceSha=$sourceSha; SourceTreeSha=$sourceTreeSha; ExitCode=127; Status='MISSING'; PassMarker=''; ParseErrors=0; AssertionErrors=0; RuntimeErrorLines=0; ElapsedMs=0; ExactCommand=''; LogPath=''; UserdataProfile='' })
        Write-Output "FAIL MISSING $scriptPath"
        continue
    }
    $testName = [IO.Path]::GetFileNameWithoutExtension($test)
    $caseRoot = Join-Path $userdata $testName
    $env:APPDATA = Join-Path $caseRoot 'roaming'
    $env:LOCALAPPDATA = Join-Path $caseRoot 'local'
    $env:TEMP = Join-Path $caseRoot 'tmp'
    $env:TMP = $env:TEMP
    New-Item -ItemType Directory -Force -Path $env:APPDATA,$env:LOCALAPPDATA,$env:TEMP | Out-Null
    $log = Join-Path $logs ($testName + '.log')
    $commandText = '"' + $godot + '" --headless --path "' + $project + '" --script ' + $scriptPath + ' --log-file "' + $log + '"'
    $watch = [Diagnostics.Stopwatch]::StartNew()
    $output = & $godot --headless --path $project --script $scriptPath --log-file $log 2>&1
    $exitCode = $LASTEXITCODE
    $watch.Stop()
    $outputText = ($output | Out-String).TrimEnd()
    Set-Content -LiteralPath $log -Value $outputText -Encoding utf8
    $lines = @($outputText -split "`r?`n")
    $markers = @($lines | Where-Object { $_ -match 'PASS' -and $_ -notmatch '^Godot Engine' })
    $marker = if ($markers.Count -gt 0) { $markers[-1].Trim() } else { '' }
    $parseErrors = @($lines | Where-Object { $_ -match 'SCRIPT ERROR: Parse Error|Parse Error:' }).Count
    $assertionErrors = @($lines | Where-Object { $_ -match 'Assertion failed|ASSERTION FAILED|TEST FAIL|FOCUSED FAIL' }).Count
    $runtimeErrors = @($lines | Where-Object { $_ -match '^ERROR:' }).Count
    $status = if ($exitCode -eq 0 -and $marker -ne '' -and $parseErrors -eq 0 -and $assertionErrors -eq 0) { 'PASS' } else { 'FAIL' }
    $results.Add([pscustomobject]@{
        TestPath=$scriptPath; SourceSha=$sourceSha; SourceTreeSha=$sourceTreeSha;
        ExitCode=$exitCode; Status=$status; PassMarker=$marker; ParseErrors=$parseErrors;
        AssertionErrors=$assertionErrors; RuntimeErrorLines=$runtimeErrors; ElapsedMs=$watch.ElapsedMilliseconds;
        ExactCommand=$commandText; LogPath=('logs/focused_sha4b02/' + $testName + '.log');
        UserdataProfile=('userdata/focused_sha4b02/' + $testName)
    })
    Write-Output ("{0} {1} exit={2} elapsed_ms={3}" -f $status,$test,$exitCode,$watch.ElapsedMilliseconds)
}
$csvPath = Join-Path $root 'focused_results_sha4b02.csv'
$results | Export-Csv -NoTypeInformation -Encoding utf8 $csvPath
$failed = @($results | Where-Object { $_.Status -ne 'PASS' })
Write-Output ("FOCUSED_SUMMARY total={0} passed={1} failed={2}" -f $results.Count,($results.Count-$failed.Count),$failed.Count)
if ($failed.Count -gt 0) { exit 1 }
exit 0

