param([string]$Repository,[string]$Output,[string]$GodotExe,[string]$SourceSha)
$ErrorActionPreference='Continue'
$project=Join-Path $Repository 'godot'
$logs=Join-Path $Output 'logs'
$cases=@(
@{Group='PR51 core';Name='core_runtime_clock';Script='res://tests/simulation/dv2_03_runtime_clock_test.gd'},
@{Group='PR51 core';Name='core_d7_save_ab';Script='res://tests/simulation/pve_aux01_save_stage_differential_test.gd'},
@{Group='PR51 core';Name='core_safe_recovery';Script='res://tests/simulation/safe_01_save_recovery_test.gd'},
@{Group='PR51 core';Name='core_live_runtime_1';Script='res://tests/simulation/dv2_03_live_runtime_integration_test.gd'},
@{Group='PR51 core';Name='core_live_runtime_2';Script='res://tests/simulation/dv2_03_live_runtime_integration_test.gd'},
@{Group='PR51 core';Name='core_save_return_reload';Script='res://tests/simulation/pve_save_return_reload_exactly_once_test.gd'},
@{Group='PR51 core';Name='core_c17';Script='res://tests/simulation/pve_same_cell_move_c17_regression_test.gd'},
@{Group='PR51 core';Name='core_unique_formation';Script='res://tests/simulation/pve_group_move_unique_formation_test.gd'},
@{Group='PR51 core';Name='core_population_20';Script='res://tests/simulation/pve_multi_camp_population_v1_test.gd'},
@{Group='PR51 core';Name='core_hp0_bridge';Script='res://tests/simulation/pve_multicamp_combat_hp0_bridge_test.gd'},
@{Group='PR51 core';Name='core_injury120';Script='res://tests/simulation/gp_02c1_injury_settlement_test.gd'},
@{Group='PR51 core';Name='core_sourcea_pointer_2172';Script='res://tests/presentation/pve_aux02_world_input_contract_test.gd'},
@{Group='PR51 core';Name='core_autonomous_zone_progression';Script='res://tests/simulation/pve_aux02_autonomous_zone_progression_test.gd'},
@{Group='PR51 core';Name='core_p3_2_live_integration';Script='res://tests/presentation/pve_multicamp_p3_2_live_integration_test.gd'},
@{Group='PR50 presentation';Name='visual_jx_vfx_saveresume';Script='res://tests/presentation/pve_jx_sword_vfx_adapter_test.gd'},
@{Group='PR50 presentation';Name='visual_sourcea_death_snapshot';Script='res://tests/presentation/pve_sourcea_death_snapshot_contract_test.gd'},
@{Group='PR50 presentation';Name='visual_perf_probe';Script='res://tests/presentation/pve_perf_probe_contract_test.gd'},
@{Group='PR50 presentation';Name='visual_care_combat_presenter';Script='res://tests/presentation/b3_care_combat_v5_presenter_test.gd'},
@{Group='PR50 presentation';Name='visual_p3_2_camera';Script='res://tests/presentation/p3_2_map_camera_test.gd'},
@{Group='PR50 presentation';Name='visual_p3_2_live_map';Script='res://tests/presentation/p3_2_live_modular_map_test.gd'},
@{Group='PR50 presentation';Name='visual_disciple_ui';Script='res://tests/presentation/p3_2_disciple_ui_test.gd'},
@{Group='PR50 presentation';Name='visual_injury_presentation';Script='res://tests/presentation/gp_02c1_injury_presentation_test.gd'}
)
$missing=@($cases | Where-Object { -not (Test-Path -LiteralPath (Join-Path $project ($_.Script -replace '^res://','').Replace('/','\'))) })
if($missing.Count){$missing | ForEach-Object {Write-Output "MISSING $($_.Name) $($_.Script)"};exit 98}
$rows=[System.Collections.Generic.List[object]]::new()
$engine=(& $GodotExe --version | Select-Object -First 1).Trim()
$seq=0
foreach($case in $cases){
  $seq++
  $started=Get-Date
  $sw=[Diagnostics.Stopwatch]::StartNew()
  $stdout=Join-Path $logs ($case.Name+'.stdout.txt')
  $godotLog=Join-Path $logs ($case.Name+'.godot.log')
  $exitFile=Join-Path $logs ($case.Name+'.exit.txt')
  $caseData=Join-Path $Output ('userdata\case_'+$case.Name)
  $appData=Join-Path $caseData 'appdata';$localData=Join-Path $caseData 'localappdata';$temp=Join-Path $caseData 'temp'
  New-Item -ItemType Directory -Force -Path $appData,$localData,$temp | Out-Null
  $env:APPDATA=$appData;$env:LOCALAPPDATA=$localData;$env:TEMP=$temp;$env:TMP=$temp
  Write-Output ("[{0}/22] START {1} {2}" -f $seq,$case.Name,$case.Script)
  & $GodotExe --headless --path $project --log-file $godotLog --script $case.Script *>&1 | Out-File -LiteralPath $stdout -Encoding utf8
  $code=$LASTEXITCODE
  $sw.Stop();$ended=Get-Date
  Set-Content -LiteralPath $exitFile -Value $code -NoNewline
  $status=if($code -eq 0){'PASS'}else{'FAIL'}
  $row=[pscustomobject]@{Index=$seq;Group=$case.Group;Case=$case.Name;Command="Godot_v4.7.2-stable_win64_console.exe --headless --path godot --log-file logs/$($case.Name).godot.log --script $($case.Script)";ExitCode=$code;Status=$status;ExactSourceSHA=$SourceSha;Engine=$engine;Started=$started.ToString('o');Ended=$ended.ToString('o');ElapsedSeconds=[math]::Round($sw.Elapsed.TotalSeconds,3);Stdout="logs/$($case.Name).stdout.txt";GodotLog="logs/$($case.Name).godot.log";ExitFile="logs/$($case.Name).exit.txt"}
  $rows.Add($row)
  $row | ConvertTo-Json -Compress | Add-Content -LiteralPath (Join-Path $Output 'test_progress.jsonl')
  Write-Output ("[{0}/22] {1} exit={2} elapsed={3:N2}s" -f $seq,$case.Name,$code,$sw.Elapsed.TotalSeconds)
}
$rows | Export-Csv -LiteralPath (Join-Path $Output 'FULL_22_TEST_MATRIX.csv') -NoTypeInformation -Encoding utf8
$pass=@($rows | Where-Object Status -eq 'PASS').Count;$fail=@($rows | Where-Object Status -eq 'FAIL').Count
@{SourceSHA=$SourceSha;Engine=$engine;Total=$rows.Count;Pass=$pass;Fail=$fail;Started=$rows[0].Started;Ended=$rows[-1].Ended} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $Output 'FULL_22_SUMMARY.json')
Write-Output "FULL_22_SUMMARY total=$($rows.Count) pass=$pass fail=$fail sha=$SourceSha engine=$engine"
if($fail){exit 1}else{exit 0}
