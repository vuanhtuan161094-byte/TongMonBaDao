$ErrorActionPreference = 'Stop'

function Assert-NoGodotProcess {
    $active = @(Get-Process | Where-Object { $_.ProcessName -match '^Godot' })
    if ($active.Count -gt 0) {
        throw ('Godot single-process gate: another process is active: ' + (($active | ForEach-Object { '{0} ({1})' -f $_.ProcessName,$_.Id }) -join ', '))
    }
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$godot = 'E:\Godot_v4.7.2-stable_win64_console.exe'
$godotProject = Join-Path $repoRoot 'godot'
$sourceSha = (git -C $repoRoot rev-parse HEAD).Trim()
$logRoot = Join-Path $repoRoot 'outputs\endgame_qa_20261026\logs\endgame_map_additional'
$cases = @(
    @{path='res://tests/presentation/endgame_fixture_contract_test.gd'; marker='TMB_ENDGAME_FIXTURE_CONTRACT PASS'},
    @{path='res://tests/presentation/endgame_map_density_test.gd'; marker='TMB_ENDGAME_MAP_DENSITY PASS'},
    @{path='res://tests/presentation/sect_map_d2_visual_contract_test.gd'; marker='MAP-D2 VISUAL CONTRACT PASS'},
    @{path='res://tests/presentation/pve_world_topology_preview_contract_test.gd'; marker='PVE WORLD TOPOLOGY PREVIEW CONTRACT PASS'},
    @{path='res://tests/simulation/pve_multi_camp_population_v1_test.gd'; marker='PVE MULTI CAMP POPULATION CONTRACT PASS'},
    @{path='res://tests/simulation/pve_multicamp_combat_hp0_bridge_test.gd'; marker='PVE MULTICAMP COMBAT HP0 BRIDGE PASS'}
)

New-Item -ItemType Directory -Force -Path $logRoot | Out-Null
$results = [System.Collections.Generic.List[object]]::new()
for ($i = 0; $i -lt $cases.Count; $i++) {
    $case = $cases[$i]
    $name = [IO.Path]::GetFileName([string]$case.path)
    $log = Join-Path $logRoot ($name + '.log')
    $caseRoot = Join-Path $repoRoot ("outputs\endgame_qa_20261026\test_userdata\" + $name)
    $roaming = Join-Path $caseRoot 'Roaming'
    $local = Join-Path $caseRoot 'Local'
    New-Item -ItemType Directory -Force -Path $roaming,$local | Out-Null
    $env:APPDATA = $roaming
    $env:LOCALAPPDATA = $local
    Write-Output ("START {0}/{1} {2}" -f ($i+1),$cases.Count,$case.path)
    Assert-NoGodotProcess
    & $godot --headless --path $godotProject --quit-after 3600 --script ([string]$case.path) *>&1 | Out-File -LiteralPath $log -Encoding utf8
    $exitCode = $LASTEXITCODE
    $text = Get-Content -Raw -LiteralPath $log
    $found = $text.Contains([string]$case.marker)
    $status = if ($exitCode -eq 0 -and $found) {'PASS'} else {'FAIL'}
    $results.Add([pscustomobject]@{TestPath=$case.path; ExitCode=$exitCode; Status=$status; PassMarker=$case.marker; MarkerFound=$found; LogPath=$log; SourceSHA=$sourceSha})
    Write-Output ("{0} {1} exit={2} marker={3}" -f $status,$name,$exitCode,$found)
}
$csv = Join-Path $logRoot 'focused_results.csv'
$results | Export-Csv -NoTypeInformation -Encoding UTF8 $csv
$passed = @($results | Where-Object Status -eq 'PASS').Count
$failed = @($results | Where-Object Status -eq 'FAIL').Count
Write-Output ("SUMMARY PASS={0} FAIL={1} TOTAL={2} SHA={3} CSV={4}" -f $passed,$failed,$results.Count,$sourceSha,$csv)
if ($failed -gt 0) { exit 1 }
