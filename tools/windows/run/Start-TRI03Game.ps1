param(
    [Parameter(Mandatory = $true)][string] $GodotPath,
    [Parameter(Mandatory = $true)][string] $ProjectPath,
    [Parameter(Mandatory = $true)][string] $PlayLog,
    [Parameter(Mandatory = $true)][string] $LauncherLog,
    [ValidateRange(5, 180)][int] $TimeoutSeconds = 90
)

$ErrorActionPreference = 'Stop'
foreach ($required in @($GodotPath, (Join-Path $ProjectPath 'project.godot'))) {
    if (-not (Test-Path -LiteralPath $required -PathType Leaf)) {
        throw "Required game file is missing: $required"
    }
}
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $PlayLog), (Split-Path -Parent $LauncherLog) | Out-Null
$stdoutPath = $PlayLog + '.stdout.log'
$stderrPath = $PlayLog + '.stderr.log'
$arguments = @(
    '--path', $ProjectPath,
    '--resolution', '1280x720',
    '--windowed',
    '--verbose',
    '--log-file', $PlayLog
)
$startedAt = [DateTime]::UtcNow
$process = Start-Process -FilePath $GodotPath -ArgumentList $arguments -WorkingDirectory $ProjectPath `
    -RedirectStandardOutput $stdoutPath -RedirectStandardError $stderrPath -PassThru
if ($null -eq $process) { throw 'Windows did not return a process handle for Godot.' }
Add-Content -LiteralPath $LauncherLog -Encoding UTF8 -Value ('[{0:o}] launch_process_created pid={1} godot={2} stdout={3} stderr={4}' -f $startedAt, $process.Id, $GodotPath, $stdoutPath, $stderrPath)

$deadline = [DateTime]::UtcNow.AddSeconds($TimeoutSeconds)
do {
    Start-Sleep -Milliseconds 500
    try { $process.Refresh() } catch {}
    if ($process.HasExited) {
        $message = 'Godot exited before its game window became ready (exit code {0}); log={1}' -f $process.ExitCode, $PlayLog
        Add-Content -LiteralPath $LauncherLog -Encoding UTF8 -Value ('[{0:o}] launch_failed pid={1} {2}' -f [DateTime]::UtcNow, $process.Id, $message)
        Write-Error $message
        exit 11
    }
    if ($process.MainWindowHandle -ne 0 -and $process.Responding) {
        $message = 'Game window ready: PID {0}, title="{1}".' -f $process.Id, $process.MainWindowTitle
        Add-Content -LiteralPath $LauncherLog -Encoding UTF8 -Value ('[{0:o}] window_ready pid={1} hwnd={2} title="{3}"' -f [DateTime]::UtcNow, $process.Id, $process.MainWindowHandle, $process.MainWindowTitle)
        Write-Output $message
        exit 0
    }
} while ([DateTime]::UtcNow -lt $deadline)

$message = 'Godot PID {0} is still running, but no responsive game window became ready within {1}s; log={2}. The process was left open for diagnosis.' -f $process.Id, $TimeoutSeconds, $PlayLog
Add-Content -LiteralPath $LauncherLog -Encoding UTF8 -Value ('[{0:o}] launch_not_ready pid={1} {2}' -f [DateTime]::UtcNow, $process.Id, $message)
Write-Error $message
exit 12
