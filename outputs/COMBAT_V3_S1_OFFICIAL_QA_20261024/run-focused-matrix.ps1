param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("baseline", "final")]
    [string]$Phase,
    [Parameter(Mandatory = $true)]
    [string]$EnginePath
)

$ErrorActionPreference = "Stop"
$qaRoot = $PSScriptRoot
$repoRoot = (Resolve-Path (Join-Path $qaRoot "..\..")).Path
$sourceHead = (& git -C $repoRoot rev-parse HEAD).Trim()
$projectPath = (Resolve-Path (Join-Path $repoRoot "godot")).Path
$logRoot = Join-Path $qaRoot "logs\$Phase"
$profile = Join-Path $qaRoot "userdata\$Phase"
New-Item -ItemType Directory -Force -Path $logRoot, $profile,
    (Join-Path $profile "AppData\Roaming"),
    (Join-Path $profile "AppData\Local"),
    (Join-Path $profile "Temp") | Out-Null

# Godot's project data, editor settings and temp paths are isolated under outputs.
$env:APPDATA = Join-Path $profile "AppData\Roaming"
$env:LOCALAPPDATA = Join-Path $profile "AppData\Local"
$env:TEMP = Join-Path $profile "Temp"
$env:TMP = $env:TEMP

$version = (& $EnginePath --version).Trim()
if ($version -ne "4.7.2.stable.official.ed1daf0bf") {
    throw "Wrong official Godot build: $version"
}

$tests = @(
    "tests/simulation/combat_v3_s1_effects_test.gd",
    "tests/simulation/dv2_02_group_map_battle_test.gd",
    "tests/simulation/dv2_02_battle_snapshot_test.gd",
    "tests/simulation/dv2_02_combat_stats_test.gd",
    "tests/simulation/dv2_02_monster_context_test.gd",
    "tests/simulation/dv2_02_five_level_pve_test.gd",
    "tests/simulation/p2_5_combat_skill_test.gd",
    "tests/simulation/p2_6_equipment_combat_effects_test.gd",
    "tests/simulation/b3_ph0_continuous_kernel_test.gd",
    "tests/simulation/b3_care_pills_autohunt_test.gd",
    "tests/simulation/b3_fasttrack_hunt_test.gd",
    "tests/simulation/gp_02c1_injury_settlement_test.gd",
    "tests/presentation/b3_main_hunt_integration_test.gd",
    "tests/simulation/d7_foundation_v3_migration_test.gd"
)

$rows = [System.Collections.Generic.List[object]]::new()
foreach ($testPath in $tests) {
    $name = [IO.Path]::GetFileNameWithoutExtension($testPath)
    $sourcePath = Join-Path $projectPath $testPath.Replace("/", "\")
    if (-not (Test-Path -LiteralPath $sourcePath)) {
        throw "Required test file is missing: $sourcePath"
    }
    $sourceText = Get-Content -LiteralPath $sourcePath -Raw
    $markerRequired = $sourceText -match '(?im)print\s*\([^\r\n]*PASS'
    $stdoutPath = Join-Path $logRoot "$name.stdout.txt"
    $stderrPath = Join-Path $logRoot "$name.stderr.txt"
    $metaPath = Join-Path $logRoot "$name.meta.txt"
    $command = '"' + $EnginePath + '" --headless --path "' + $projectPath +
        '" --script res://' + $testPath
    $args = @("--headless", "--path", $projectPath, "--script", "res://$testPath")
    $watch = [Diagnostics.Stopwatch]::StartNew()
    & $EnginePath @args 1> $stdoutPath 2> $stderrPath
    $exitCode = $LASTEXITCODE
    $watch.Stop()
    $elapsedMs = [int]$watch.ElapsedMilliseconds
    $stdoutText = Get-Content -LiteralPath $stdoutPath -Raw
    $stderrText = Get-Content -LiteralPath $stderrPath -Raw
    $allText = $stdoutText + [Environment]::NewLine + $stderrText
    $markerLines = @($stdoutText -split "\r?\n" | Where-Object { $_ -match "(?i)PASS" })
    $marker = if ($markerLines.Count -gt 0) { $markerLines -join " || " } else { "N/A" }
    $parseErrors = @($allText -split "\r?\n" | Where-Object {
        $_ -match "(?i)Parse Error|SCRIPT ERROR|Failed to load script"
    }).Count
    $assertionErrors = @($allText -split "\r?\n" | Where-Object {
        $_ -match "(?i)assertion failed|assert.*failed|COMBAT.*FAIL|TEST.*FAIL"
    }).Count
    $runtimeErrors = @($allText -split "\r?\n" | Where-Object {
        $_ -match "(?i)^ERROR:"
    }).Count
    $markerMissing = $markerRequired -and $marker -eq "N/A"

    if ($exitCode -eq 0 -and $parseErrors -eq 0 -and $assertionErrors -eq 0 -and -not $markerMissing) {
        $status = "PASS"
        $category = "none"
    } elseif ($exitCode -eq 0 -and ($parseErrors -gt 0 -or $assertionErrors -gt 0 -or $markerMissing)) {
        $status = "FAIL"
        $category = if ($parseErrors -gt 0) { "parse/script" } elseif ($assertionErrors -gt 0) { "assertion" } else { "required_marker_missing" }
    } elseif ($parseErrors -gt 0) {
        $status = "FAIL"
        $category = "parse/script"
    } elseif ($assertionErrors -gt 0) {
        $status = "FAIL"
        $category = "assertion"
    } else {
        $status = "BLOCKED"
        $category = "runner_or_runtime"
    }

    @(
        "command=$command",
        "cwd=$projectPath",
        "engine=$version",
        "source_head=$sourceHead",
        "phase=$Phase",
        "userdata_appdata=$env:APPDATA",
        "userdata_localappdata=$env:LOCALAPPDATA",
        "userdata_temp=$env:TEMP",
        "exit_code=$exitCode",
        "elapsed_ms=$elapsedMs",
        "status=$status",
        "failure_category=$category",
        "pass_marker=$marker",
        "parse_errors=$parseErrors",
        "assertion_errors=$assertionErrors",
        "runtime_error_lines=$runtimeErrors"
    ) | Set-Content -LiteralPath $metaPath -Encoding utf8

    $rows.Add([pscustomobject]@{
        test_path = $testPath
        source_sha = $sourceHead
        exact_command = $command
        exit_code = $exitCode
        pass_marker = $marker
        marker_required = $markerRequired
        parse_errors = $parseErrors
        assertion_errors = $assertionErrors
        runtime_error_lines = $runtimeErrors
        elapsed_ms = $elapsedMs
        log_path = "outputs/COMBAT_V3_S1_OFFICIAL_QA_20261024/logs/$Phase/$name"
        status = $status
        failure_category = $category
        userdata_profile = $profile
    })
    Write-Output ($Phase + " | " + $status + " | " + $testPath + " | exit=" + $exitCode + " | " + $elapsedMs + "ms | marker=" + $marker)
}

$csvPath = Join-Path $qaRoot ($Phase + "_results.csv")
$rows | Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding utf8
$failed = @($rows | Where-Object { $_.status -ne "PASS" }).Count
Write-Output "SUMMARY phase=$Phase total=$($rows.Count) pass=$($rows.Count - $failed) nonpass=$failed csv=$csvPath"
