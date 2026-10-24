param(
    [Parameter(Mandatory = $true)]
    [string]$EnginePath
)

$ErrorActionPreference = "Stop"
$qaRoot = $PSScriptRoot
$repoRoot = (Resolve-Path (Join-Path $qaRoot "..\..")).Path
$projectPath = (Resolve-Path (Join-Path $repoRoot "godot")).Path
$sourceHead = (& git -C $repoRoot rev-parse HEAD).Trim()
$logRoot = Join-Path $qaRoot "logs\final"
$profile = Join-Path $qaRoot "userdata\edge_final"
$testPath = "tests/simulation/combat_v3_s1_edge_contract_test.gd"
$testName = [IO.Path]::GetFileNameWithoutExtension($testPath)
New-Item -ItemType Directory -Force -Path $logRoot, $profile,
    (Join-Path $profile "AppData\Roaming"),
    (Join-Path $profile "AppData\Local"),
    (Join-Path $profile "Temp") | Out-Null

$env:APPDATA = Join-Path $profile "AppData\Roaming"
$env:LOCALAPPDATA = Join-Path $profile "AppData\Local"
$env:TEMP = Join-Path $profile "Temp"
$env:TMP = $env:TEMP
$version = (& $EnginePath --version).Trim()
if ($version -ne "4.7.2.stable.official.ed1daf0bf") {
    throw "Wrong official Godot build: $version"
}

$stdoutPath = Join-Path $logRoot "$testName.stdout.txt"
$stderrPath = Join-Path $logRoot "$testName.stderr.txt"
$metaPath = Join-Path $logRoot "$testName.meta.txt"
$command = '"' + $EnginePath + '" --headless --path "' + $projectPath + '" --script res://' + $testPath
$watch = [Diagnostics.Stopwatch]::StartNew()
& $EnginePath --headless --path $projectPath --script "res://$testPath" 1> $stdoutPath 2> $stderrPath
$exitCode = $LASTEXITCODE
$watch.Stop()
$elapsedMs = [int]$watch.ElapsedMilliseconds
$stdoutText = Get-Content -LiteralPath $stdoutPath -Raw
$stderrText = Get-Content -LiteralPath $stderrPath -Raw
$allText = $stdoutText + [Environment]::NewLine + $stderrText
$markerLines = @($stdoutText -split "\r?\n" | Where-Object { $_ -match "(?i)COMBAT_V3_S1_EDGE_CONTRACT_PASS" })
$marker = if ($markerLines.Count -gt 0) { $markerLines -join " || " } else { "N/A" }
$parseErrors = @($allText -split "\r?\n" | Where-Object { $_ -match "(?i)Parse Error|SCRIPT ERROR|Failed to load script" }).Count
$assertionErrors = @($allText -split "\r?\n" | Where-Object { $_ -match "(?i)S1_EDGE_FAIL|S1_EDGE_CONTRACT_FAIL|assertion failed" }).Count
$runtimeErrors = @($allText -split "\r?\n" | Where-Object { $_ -match "(?i)^ERROR:" }).Count
$status = if ($exitCode -eq 0 -and $parseErrors -eq 0 -and $assertionErrors -eq 0 -and $marker -ne "N/A") { "PASS" } else { "FAIL" }
$category = if ($status -eq "PASS") { "none" } elseif ($parseErrors -gt 0) { "parse/script" } elseif ($assertionErrors -gt 0) { "assertion" } elseif ($exitCode -ne 0) { "runner_or_runtime" } else { "required_marker_missing" }

@(
    "command=$command",
    "cwd=$projectPath",
    "engine=$version",
    "source_head=$sourceHead",
    "phase=final_edge_contract",
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

[pscustomobject]@{
    test_path = $testPath
    source_sha = $sourceHead
    exact_command = $command
    exit_code = $exitCode
    pass_marker = $marker
    parse_errors = $parseErrors
    assertion_errors = $assertionErrors
    runtime_error_lines = $runtimeErrors
    elapsed_ms = $elapsedMs
    log_path = "outputs/COMBAT_V3_S1_OFFICIAL_QA_20261024/logs/final/$testName"
    status = $status
    failure_category = $category
    userdata_profile = $profile
} | Export-Csv -LiteralPath (Join-Path $qaRoot "edge_results.csv") -NoTypeInformation -Encoding utf8

Write-Output "edge | $status | $testPath | source=$sourceHead | exit=$exitCode | ${elapsedMs}ms | marker=$marker"
if ($status -ne "PASS") { exit 1 }
