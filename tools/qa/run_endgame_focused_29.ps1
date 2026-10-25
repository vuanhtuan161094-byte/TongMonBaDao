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
$baseline = Join-Path $repoRoot 'outputs\map_d1b\logs\final_29_verified\focused_results.csv'
$runId = Get-Date -Format 'yyyyMMdd_HHmmss_fff'
$logRoot = Join-Path $repoRoot ("outputs\endgame_qa_20261026\logs\focused_29_final_" + $runId)

if (-not (Test-Path -LiteralPath $godot -PathType Leaf)) { throw "Godot 4.7.2 missing: $godot" }
if (-not (Test-Path -LiteralPath $baseline -PathType Leaf)) { throw "Focused test manifest missing: $baseline" }
New-Item -ItemType Directory -Force -Path $logRoot | Out-Null

$results = [System.Collections.Generic.List[object]]::new()
$cases = Import-Csv -LiteralPath $baseline
for ($i = 0; $i -lt $cases.Count; $i++) {
    $case = $cases[$i]
    $name = [IO.Path]::GetFileName([string]$case.TestPath)
    $log = Join-Path $logRoot ($name + '.log')
    # Give every suite run a fresh user:// root. Keep all earlier QA saves intact.
    $caseUserData = Join-Path $repoRoot ("outputs\endgame_qa_20261026\test_userdata\" + $runId + "\" + $name)
    $roaming = Join-Path $caseUserData 'Roaming'
    $local = Join-Path $caseUserData 'Local'
    New-Item -ItemType Directory -Force -Path $roaming,$local | Out-Null
    # Test-specific user:// paths prevent one test's durable .bak or live save
    # from becoming the next test's implicit fixture.
    $env:APPDATA = $roaming
    $env:LOCALAPPDATA = $local
    Write-Output ("START {0}/{1} {2}" -f ($i + 1),$cases.Count,$case.TestPath)
    Assert-NoGodotProcess
    & $godot --headless --path $godotProject --quit-after 3600 --script ([string]$case.TestPath) *>&1 | Out-File -LiteralPath $log -Encoding utf8
    $exitCode = $LASTEXITCODE
    $text = Get-Content -Raw -LiteralPath $log
    $marker = [string]$case.PassMarker
    $markerFound = -not [string]::IsNullOrWhiteSpace($marker) -and $text.Contains($marker)
    $status = if ($exitCode -eq 0 -and $markerFound) { 'PASS' } else { 'FAIL' }
    $results.Add([pscustomobject]@{
        Index = $i + 1; TestPath = [string]$case.TestPath; ExitCode = $exitCode
        Status = $status; PassMarker = $marker; MarkerFound = $markerFound
        LogPath = $log; SourceSHA = $sourceSha
    })
    Write-Output ("{0} {1} exit={2} marker={3}" -f $status,$name,$exitCode,$markerFound)
}

$csv = Join-Path $logRoot 'focused_results.csv'
$results | Export-Csv -NoTypeInformation -Encoding UTF8 $csv
$passCount = @($results | Where-Object Status -eq 'PASS').Count
$failCount = @($results | Where-Object Status -ne 'PASS').Count
Write-Output ("SUMMARY PASS={0} FAIL={1} TOTAL={2} SHA={3} CSV={4}" -f $passCount,$failCount,$results.Count,$sourceSha,$csv)
if ($failCount -gt 0) { exit 1 }
