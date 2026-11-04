param(
    [Parameter(Mandatory = $true)][string] $GodotPath,
    [Parameter(Mandatory = $true)][string] $ProjectPath,
    [Parameter(Mandatory = $true)][string] $PlayLog,
    [Parameter(Mandatory = $true)][string] $LauncherLog,
    [ValidateRange(5, 180)][int] $TimeoutSeconds = 90
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'tri03_launcher_support.ps1')
foreach ($required in @($GodotPath, (Join-Path $ProjectPath 'project.godot'))) {
    if (-not (Test-Path -LiteralPath $required -PathType Leaf)) { throw "Required game file is missing: $required" }
}
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $PlayLog), (Split-Path -Parent $LauncherLog) | Out-Null
$script:LauncherLogPath = [IO.Path]::GetFullPath($LauncherLog)
$mutex = $null
$ownsMutex = $false
$process = $null
$finalExitCode = 1
function Write-TRI03LauncherLog {
    param([Parameter(Mandatory = $true)][string] $Message)
    Add-Content -LiteralPath $script:LauncherLogPath -Encoding UTF8 -Value ('[{0:o}] {1}' -f [DateTime]::UtcNow, $Message)
}
try {
    $mutexName = Get-TRI03ProjectMutexName -ProjectPath $ProjectPath
    $mutex = [Threading.Mutex]::new($false, $mutexName)
    try { $ownsMutex = $mutex.WaitOne(0) }
    catch [Threading.AbandonedMutexException] {
        $ownsMutex = $true
        Write-TRI03LauncherLog -Message ('abandoned_mutex_recovered mutex={0}' -f $mutexName)
    }

    if (-not $ownsMutex) {
        Write-TRI03LauncherLog -Message ('duplicate_launch_blocked mutex={0}' -f $mutexName)
        Write-Output 'TMB_LAUNCH_ALREADY_RUNNING: use the existing game window; no second Godot process was started.'
        $finalExitCode = 0
    } else {
        $sessionId = [Diagnostics.Process]::GetCurrentProcess().SessionId
        $assessments = @(Get-TRI03ExistingGodotProcesses -GodotPath $GodotPath -ProjectPath $ProjectPath -CurrentSessionId $sessionId)
        foreach ($assessment in $assessments | Where-Object { -not $_.BlocksLaunch }) {
            if ($assessment.Reason -eq 'same_session_different_project') {
                Write-TRI03LauncherLog -Message ('unrelated_godot_ignored pid={0} session={1} reason={2}' -f $assessment.Id, $assessment.SessionId, $assessment.Reason)
            } else {
                Write-TRI03LauncherLog -Message ('unknown_process_identity pid={0} session={1} reason={2}; project_mutex_remains_authoritative=1' -f $assessment.Id, $assessment.SessionId, $assessment.Reason)
            }
        }
        $existing = @($assessments | Where-Object { $_.BlocksLaunch })
        if ($existing.Count -gt 0) {
            $details = ($existing | ForEach-Object { '{0}:{1}' -f $_.Id, $_.Reason }) -join ','
            Write-TRI03LauncherLog -Message ('existing_godot_blocked session={0} identities={1}; no new process started' -f $sessionId, $details)
            Write-Output ('TMB_LAUNCH_BLOCKED_EXISTING_GODOT: same-session process identity is {0}; no second game was started.' -f $details)
            $finalExitCode = 13
        } else {
            $runId = New-TRI03RunId
            $logs = Get-TRI03RunLogPaths -PlayLog $PlayLog -RunId $runId
            $arguments = @('--path', $ProjectPath, '--resolution', '1280x720', '--windowed', '--verbose', '--log-file', $logs.PlayLog)
            $startedAt = [DateTime]::UtcNow
            $process = Start-Process -FilePath $GodotPath -ArgumentList $arguments -WorkingDirectory $ProjectPath `
                -RedirectStandardOutput $logs.Stdout -RedirectStandardError $logs.Stderr -PassThru
            if ($null -eq $process) { throw 'Windows did not return a process handle for Godot.' }
            Write-TRI03LauncherLog -Message ('launch_process_created pid={0} run_id={1} godot={2} stdout={3} stderr={4}' -f $process.Id, $runId, $GodotPath, $logs.Stdout, $logs.Stderr)

            $ready = $false
            $deadline = [DateTime]::UtcNow.AddSeconds($TimeoutSeconds)
            while ([DateTime]::UtcNow -lt $deadline) {
                Start-Sleep -Milliseconds 500
                try { $process.Refresh() } catch {}
                if ($process.HasExited) { break }
                if ($process.MainWindowHandle -ne [IntPtr]::Zero -and $process.Responding) {
                    $ready = $true
                    Write-TRI03LauncherLog -Message ('window_ready pid={0} run_id={1} hwnd={2} title="{3}"' -f $process.Id, $runId, $process.MainWindowHandle, $process.MainWindowTitle)
                    Write-Output ('Game window ready: PID {0}, title="{1}". Launcher remains attached until this process exits.' -f $process.Id, $process.MainWindowTitle)
                    break
                }
            }

            if (-not $ready) {
                $finalExitCode = 11
                if ($process.HasExited) {
                    $process.Refresh()
                    Write-TRI03LauncherLog -Message ('launch_failed_before_window pid={0} run_id={1} exit_code={2} log={3}' -f $process.Id, $runId, $process.ExitCode, $logs.PlayLog)
                } else {
                    Write-TRI03LauncherLog -Message ('launch_not_ready pid={0} run_id={1} timeout_seconds={2} process_left_running=1 log={3}' -f $process.Id, $runId, $TimeoutSeconds, $logs.PlayLog)
                    Write-Output ('No responsive window after {0}s. PID {1} remains for diagnosis; the one-game lock stays held until exit. Log: {2}' -f $TimeoutSeconds, $process.Id, $logs.PlayLog)
                }
            }

            if (-not $process.HasExited) {
                $process.WaitForExit()
                $process.Refresh()
            }
            if ($process.HasExited) {
                $exit = $process.ExitCode
                Write-TRI03LauncherLog -Message ('process_exited pid={0} run_id={1} exit_code={2} lifetime_seconds={3:N1}' -f $process.Id, $runId, $exit, ([DateTime]::UtcNow - $startedAt).TotalSeconds)
                if ($ready) { $finalExitCode = if ($exit -eq 0) { 0 } else { $exit } } else { $finalExitCode = 11 }
            }
        }
    }
} catch {
    try { Write-TRI03LauncherLog -Message ('launcher_exception type={0} message="{1}"' -f $_.Exception.GetType().FullName, $_.Exception.Message) } catch {}
    if ($process) {
        try {
            $process.Refresh()
            if (-not $process.HasExited) {
                Write-Output ('Launcher error after starting PID {0}; retaining its lock until that process exits.' -f $process.Id)
                $process.WaitForExit()
                $process.Refresh()
            }
            if ($process.HasExited) {
                Write-TRI03LauncherLog -Message ('process_exited_after_launcher_error pid={0} exit_code={1}' -f $process.Id, $process.ExitCode)
            }
        } catch {}
    }
    Write-Error $_
    $finalExitCode = 1
} finally {
    if ($process) { $process.Dispose() }
    if ($mutex) {
        if ($ownsMutex) { try { $mutex.ReleaseMutex() } catch {} }
        $mutex.Dispose()
    }
}
exit $finalExitCode
