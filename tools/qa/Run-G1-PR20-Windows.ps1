# G1 / PR20 OFFICIAL WINDOWS QA - no GitHub Actions, no main writes.
# This tool fetches the draft branch into an isolated TEMP clone and redirects
# Godot's APPDATA/LOCALAPPDATA to private disposable directories.
param(
    [string]$GodotBin = $env:GODOT_BIN,
    [switch]$Full,
    [switch]$Visual,
    [switch]$Play
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$branchName = "g1-disciple-radar-sourcea-pool-20261017"
$remoteUrl = "https://github.com/vuanhtuan161094-byte/TongMonBaDao.git"
$projectSha = "5ce3c0f7ca4bd9eb0295f56b421ef96fca3a2bc7"
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$downloads = Join-Path $env:USERPROFILE "Downloads"
if (-not (Test-Path $downloads)) { $downloads = Join-Path $env:USERPROFILE "Documents" }
$report = Join-Path $downloads ("TONG_MON_G1_PR20_QA_" + $stamp)
$tempRoot = Join-Path ([IO.Path]::GetTempPath()) ("TMB_G1_ISOLATED_" + [guid]::NewGuid().ToString("N"))
$clone = Join-Path $tempRoot "game"
$project = Join-Path $clone "godot"
$summary = New-Object System.Collections.Generic.List[string]
$failures = New-Object System.Collections.Generic.List[string]
$blocked = New-Object System.Collections.Generic.List[string]
$headSha = ""
$oldAppData = $env:APPDATA
$oldLocalAppData = $env:LOCALAPPDATA
$oldMapOut = $env:MAP25_QA_OUT
$oldMapSha = $env:MAP25_QA_SHA
$status = "BLOCKED"
$zipPath = $report + ".zip"

function Add-Note([string]$line) {
    $script:summary.Add($line)
    Write-Host $line
}
function Invoke-QAProcess {
    param([string]$Label,[string]$Exe,[string]$ArgumentLine,[string]$PassMarker,[int]$TimeoutSec=300)
    $stdout = Join-Path $script:report ($Label + ".stdout.log")
    $stderr = Join-Path $script:report ($Label + ".stderr.log")
    $out = @{
        Label = $Label
        ExitCode = -1
        TimedOut = $false
        MarkerFound = $false
    }
    # Windows PowerShell 5.1 Start-Process -PassThru without -Wait can
    # return an empty ExitCode EVEN AFTER WaitForExit() reports success.
    # Use the .NET Process object directly to retrieve a real integer exit
    # code; drain both streams asynchronously to avoid output deadlocks.
    $start = New-Object System.Diagnostics.ProcessStartInfo
    $start.FileName = $Exe
    $start.Arguments = $ArgumentLine
    $start.UseShellExecute = $false
    $start.CreateNoWindow = $true
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $start
    $stdoutText = ""
    $stderrText = ""
    $stdoutTask = $null
    $stderrTask = $null
    try {
        if (-not $process.Start()) {
            throw "Could not launch $Label"
        }
        $stdoutTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()
        if (-not $process.WaitForExit($TimeoutSec * 1000)) {
            $out.TimedOut = $true
            try { $process.Kill() } catch { }
            $process.WaitForExit()
            $script:failures.Add("$Label timed out after $TimeoutSec seconds")
        } else {
            $process.WaitForExit()
            $process.Refresh()
            $out.ExitCode = [int]$process.ExitCode
        }
        if ($stdoutTask -ne $null) { $stdoutText = $stdoutTask.GetAwaiter().GetResult() }
        if ($stderrTask -ne $null) { $stderrText = $stderrTask.GetAwaiter().GetResult() }
    } catch {
        $script:failures.Add("$Label runner exception: " + $_.Exception.Message)
        Add-Note ("[FAIL] " + $Label + " runner exception: " + $_.Exception.Message)
        return $false
    } finally {
        [IO.File]::WriteAllText($stdout,$stdoutText)
        [IO.File]::WriteAllText($stderr,$stderrText)
        $process.Dispose()
    }
    $combined = $stdoutText + "`n" + $stderrText
    $out.MarkerFound = ($PassMarker -eq "" -or $combined.Contains($PassMarker))
    # Godot occasionally emits parser failures without a non-zero process exit.
    # Fail closed on explicit native parser/runtime error markers.
    $godotErrors = ($combined -match '(?im)^\s*(?:SCRIPT ERROR|Parse Error|ERROR):')
    if ($out.ExitCode -ne 0 -or -not $out.MarkerFound -or $out.TimedOut -or $godotErrors) {
        $script:failures.Add("$Label FAIL (exit=$($out.ExitCode), marker=$($out.MarkerFound), timeout=$($out.TimedOut), godotErrors=$godotErrors)")
        Add-Note ("[FAIL] " + $Label + "; see " + $Label + ".*.log")
        return $false
    }
    Add-Note ("[PASS] " + $Label + " (exit=" + $out.ExitCode + ")")
    return $true
}
function Run-GodotTest([string]$name,[string]$scriptPath,[string]$passMarker) {
    return Invoke-QAProcess -Label $name -Exe $script:GodotBin -ArgumentLine ('--headless --path "' + $script:project + '" --script ' + $scriptPath) -PassMarker $passMarker -TimeoutSec 300
}

try {
    New-Item -Path $report -ItemType Directory -Force | Out-Null
    New-Item -Path $tempRoot -ItemType Directory -Force | Out-Null
    Add-Note "# TONG MON BA DAO - G1 PR20 Windows QA"
    Add-Note ("Run: " + $stamp)
    Add-Note ("Draft branch: " + $branchName)
    Add-Note "Expected ancestor: $projectSha"
    Add-Note "No CI; no merge; never touches owner's tracked/untracked or saves."
    if ([string]::IsNullOrWhiteSpace($GodotBin)) {
        $GodotBin = "E:\Godot_v4.7.2-stable_win64_console.exe"
    }
    if (-not (Test-Path -LiteralPath $GodotBin -PathType Leaf)) {
        $blocked.Add("Official Godot binary missing: $GodotBin")
        throw "Missing Godot 4.7.2 binary"
    }
    if (-not (Get-Command git.exe -ErrorAction SilentlyContinue)) {
        $blocked.Add("git.exe unavailable")
        throw "Git required to clone PR20 branch"
    }

    # Clone GitHub branch, not the local game folder. No reset, checkout,
    # clean, fetch or save changes are performed in any owner checkout.
    $cloneStdout = Join-Path $report "00_clone.stdout.log"
    $cloneStderr = Join-Path $report "00_clone.stderr.log"
    $proc = Start-Process -FilePath "git.exe" -ArgumentList ('clone --no-single-branch --branch ' + $branchName + ' "' + $remoteUrl + '" "' + $clone + '"') -Wait -PassThru -NoNewWindow -RedirectStandardOutput $cloneStdout -RedirectStandardError $cloneStderr
    if ($proc.ExitCode -ne 0 -or -not (Test-Path (Join-Path $project "project.godot"))) {
        $blocked.Add("Git clone failed. Inspect 00_clone.stderr.log; credentials/network may be missing.")
        throw "Unable to clone current PR20 head into temporary folder"
    }
    $headSha = (& git.exe -C $clone rev-parse HEAD).Trim()
    $actualBranch = (& git.exe -C $clone branch --show-current).Trim()
    if ($actualBranch -ne $branchName -or $headSha.Length -ne 40) {
        $blocked.Add("Wrong branch or unresolved Git HEAD: $actualBranch $headSha")
        throw "Unpinned Git checkout"
    }
    & git.exe -C $clone merge-base --is-ancestor $projectSha HEAD | Out-Null
    if ($LASTEXITCODE -ne 0) {
        $blocked.Add("PR20 no longer descends from pinned PR19; stop and re-audit.")
        throw "Unexpected branch ancestry"
    }
    Add-Note ("Actual checked-out SHA: " + $headSha)

    New-Item -ItemType Directory -Force -Path (Join-Path $tempRoot "AppData"),(Join-Path $tempRoot "LocalAppData") | Out-Null
    $env:APPDATA = Join-Path $tempRoot "AppData"
    $env:LOCALAPPDATA = Join-Path $tempRoot "LocalAppData"
    $versionLog = (& $GodotBin --version 2>&1 | Out-String).Trim()
    [IO.File]::WriteAllText((Join-Path $report "01_godot_version.log"), $versionLog)
    if ($LASTEXITCODE -ne 0 -or -not $versionLog.Contains("4.7.2.stable.official")) {
        $blocked.Add("Godot is not verified official 4.7.2: " + $versionLog)
        throw "Official Godot version requirement failed"
    }
    Add-Note ("Official engine: " + $versionLog)

    $importOk = Invoke-QAProcess -Label "02_import" -Exe $GodotBin -ArgumentLine ('--headless --path "'+$project+'" --import') -PassMarker "" -TimeoutSec 300
    if (-not $importOk) { throw "Godot import/parse failed; stop dependent tests" }

    # Quick is the DEFAULT, because G1 only edits presentation/read-only art.
    # Run only four directly relevant tests unless -Full is explicitly selected.
    $tests = @(
        @("03_g1_radar","res://tests/presentation/sect_g1_disciple_radar_test.gd","G1 DISCIPLE RADAR + VERIFIED SOURCE A POOL: PASS"),
        @("04_v2_profile","res://tests/presentation/dv2_03_p3_v2_disciple_profile_test.gd","DV2-03 P3 AUTHENTIC V2 DISCIPLE PROFILE: PASS"),
        @("05_p33_flow","res://tests/presentation/p3_3_disciple_operational_flow_test.gd","P3.3 DISCIPLE OPERATIONAL FLOW TEST PASS"),
        @("06_sourcea_actor","res://tests/presentation/sect_source_a_actor_pilot_test.gd","SOURCE A ACTOR PILOT REAL SCENE PASS")
    )
    if ($Full) {
        $tests += @(
            @("07_workforce","res://tests/presentation/gui_workforce_v1_e2e_test.gd","GUI-WORKFORCE V1 REAL LANDSCAPE END-TO-END PASS"),
            @("08_instance_ids","res://tests/presentation/gui_multiple_resource_instances_test.gd","GUI MULTI-INSTANCE ID ROUTING TEST PASS"),
            @("09_sourcea_art","res://tests/presentation/sect_map25_verified_art_gate_test.gd","MAP25 SOURCE A SHA-GATED ART CONTRACT PASS"),
            @("10_projection","res://tests/presentation/sect_iso_projection_contract_test.gd","CASES PASS"),
            @("11_main_scene","res://tests/presentation/sect_iso_main_integration_test.gd","MAP 2.5D REAL MAIN SCENE WORKFORCE CAMERA PASS")
        )
    }
    Add-Note ("QA scope: " + $(if ($Full) { "FOCUSED + FULL" } else { "G1 QUICK (4 focused tests)" }))
    foreach ($t in $tests) {
        $ok = Run-GodotTest $t[0] $t[1] $t[2]
        if (-not $ok) { Add-Note ("[WARN] Independent tests continue after " + $t[0]) }
    }

    if ($Full) {
        $full = Join-Path $clone "tools\godot\Verify-P3-7C1-Foundation-Dan-Tien-Full.ps1"
        $argsFull = '-NoProfile -ExecutionPolicy Bypass -File "' + $full + '" -GodotBin "' + $GodotBin + '"'
        $null = Invoke-QAProcess -Label "12_full_p37" -Exe "powershell.exe" -ArgumentLine $argsFull -PassMarker "P3.7C1 FOUNDATION + DAN TIEN FULL GATE: PASS" -TimeoutSec 1800
    } else {
        Add-Note "[NOT IN SCOPE] P3.7 FULL (presentation-only change; opt in with -Full)"
    }

    if ($Visual) {
        $capture = Join-Path $report "native_1280x720"
        New-Item -ItemType Directory -Force -Path $capture | Out-Null
        $env:MAP25_QA_OUT = $capture
        $env:MAP25_QA_SHA = $headSha
        $guiOk = Invoke-QAProcess -Label "13_gui_capture" -Exe $GodotBin -ArgumentLine ('--path "' + $project + '" --resolution 1280x720 --script res://tests/presentation/sect_map25_visual_perf_capture_test.gd') -PassMarker "MAP25 VISUAL PERFORMANCE CAPTURE PASS" -TimeoutSec 900
        if ($guiOk) {
            $perfCsv = Join-Path $capture "performance_summary.csv"
            $frameCsv = Join-Path $capture "frame_samples.csv"
            if (-not (Test-Path $perfCsv) -or -not (Test-Path $frameCsv)) {
                $failures.Add("GUI capture claims PASS without both CSV outputs")
            } else {
                $table = @(Import-Csv $perfCsv)
                $pan = @($table | Where-Object { $_.scenario -eq "pan" })
                $zoom = @($table | Where-Object { $_.scenario -eq "zoom" })
                $count = @((Get-Content $frameCsv)).Count - 1
                if ($count -ne 600 -or $pan.Count -ne 1 -or $zoom.Count -ne 1) {
                    $failures.Add("MAP25 CSV missing expected 600 rows and pan/zoom scenarios")
                } else {
                    foreach ($entry in @($pan[0],$zoom[0])) {
                        $p95 = [double]::Parse($entry.p95_interval_ms,[Globalization.CultureInfo]::InvariantCulture)
                        $draws = [double]::Parse($entry.avg_draw_calls,[Globalization.CultureInfo]::InvariantCulture)
                        Add-Note ("MAP25 {0}: p95 {1:N3} ms / draw calls {2:N1}" -f $entry.scenario,$p95,$draws)
                        if ($p95 -gt 33.3 -or $draws -gt 600) {
                            $failures.Add("MAP25 "+$entry.scenario+" performance threshold failed")
                        }
                    }
                }
            }
        }
    } else {
        Add-Note "[NOT IN SCOPE] Native visual/FPS capture (opt in with -Visual)"
    }

    if ($Play) {
        if ($failures.Count -eq 0) {
            Add-Note "[PLAY] Opening the real 1280x720 game in an isolated save directory."
            Add-Note "[PLAY] Try: Hồ sơ đệ tử > Phân công > Mỏ / Linh Lâm / Linh Điền > Giao việc."
            Add-Note "[PLAY] Close the game window to finish and receive the QA ZIP."
            $previewOk = Invoke-QAProcess -Label "14_g15_play_preview" -Exe $GodotBin -ArgumentLine ('--path "' + $project + '" --resolution 1280x720') -PassMarker "" -TimeoutSec 3600
            if (-not $previewOk) {
                Add-Note "[WARN] G1.5 preview returned an error; inspect 14_g15_play_preview logs."
            }
        } else {
            Add-Note "[PLAY BLOCKED] Quick tests failed. No misleading gameplay preview launched."
        }
    }

    $status = if ($failures.Count -gt 0) { "FAIL" } elseif ($blocked.Count -gt 0) { "PENDING" } else { "PASS" }
    if ($status -eq "PASS") {
        Add-Note ("[PASS] " + $(if ($Full -and $Visual) { "WINDOWS FULL + VISUAL" } elseif ($Full) { "WINDOWS FULL" } elseif ($Visual) { "G1 QUICK + VISUAL" } else { "G1 QUICK ONLY" }))
    }
} catch {
    Add-Note ("[BLOCKED/FAIL] " + $_.Exception.Message)
    if ($blocked.Count -eq 0 -and $failures.Count -eq 0) { $failures.Add($_.Exception.Message) }
    $status = if ($blocked.Count -gt 0) { "BLOCKED" } else { "FAIL" }
} finally {
    Add-Note ("Final automated Windows QA: " + $status)
    if ($headSha) { Add-Note ("Pinned tested checkout: " + $headSha) }
    if ($failures.Count -gt 0) { Add-Note ("Failures: " + ($failures -join " | ")) }
    if ($blocked.Count -gt 0) { Add-Note ("Blocked/Pending: " + ($blocked -join " | ")) }
    Add-Note "Visual-quality owner review and Android device QA remain PENDING even if all Windows tests PASS."
    $env:APPDATA = $oldAppData
    $env:LOCALAPPDATA = $oldLocalAppData
    $env:MAP25_QA_OUT = $oldMapOut
    $env:MAP25_QA_SHA = $oldMapSha
    try {
        if (-not (Test-Path $report)) { New-Item -ItemType Directory -Force -Path $report | Out-Null }
        [IO.File]::WriteAllLines((Join-Path $report "SUMMARY.md"),$summary)
        $info = @{ branch=$branchName; head_sha=$headSha; final_status=$status; failing=@($failures); blocked=@($blocked); godot_bin=$GodotBin; source_repo=$remoteUrl; time=$stamp; ci="NOT RUN"; merge="NOT RUN"; android="PENDING"; visual_owner="PENDING" }
        $info | ConvertTo-Json -Depth 5 | Set-Content -Path (Join-Path $report "QA_METADATA.json") -Encoding UTF8
        if (Test-Path $zipPath) { throw "Existing evidence ZIP; refuse overwrite" }
        Compress-Archive -Path (Join-Path $report "*") -DestinationPath $zipPath -CompressionLevel Optimal
        Write-Host ("Evidence ZIP (logs/CSV/screenshots only): " + $zipPath)
    } catch {
        Write-Warning ("QA evidence ZIP not complete: " + $_.Exception.Message)
        $status = "FAIL"
    }
    if (Test-Path $tempRoot) {
        try { Remove-Item -Path $tempRoot -Recurse -Force -ErrorAction Stop }
        catch { Write-Warning ("Isolated TEMP cleanup pending: " + $tempRoot) }
    }
}
if ($status -eq "PASS") { exit 0 }
if ($status -eq "BLOCKED" -or $status -eq "PENDING") { exit 2 }
exit 1
