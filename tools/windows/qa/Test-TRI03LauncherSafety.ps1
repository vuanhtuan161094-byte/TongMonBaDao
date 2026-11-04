param()
$ErrorActionPreference = 'Stop'
$run = Join-Path $PSScriptRoot '..\run'
. (Join-Path $run 'tri03_launcher_support.ps1')
function Assert-TRI03([bool] $Condition,[string] $Message) { if (-not $Condition) { throw "TRI03_LAUNCHER_SAFETY_TEST_FAIL: $Message" } }
$tempRoot = [IO.Path]::GetTempPath()
$pathA = Join-Path $tempRoot 'TMB-OneGame-Launcher-Test'
$pathB = Join-Path $tempRoot 'TMB-OneGame-Launcher-Other'
$mutexA = Get-TRI03ProjectMutexName -ProjectPath $pathA
$mutexA2 = Get-TRI03ProjectMutexName -ProjectPath $pathA
$mutexB = Get-TRI03ProjectMutexName -ProjectPath $pathB
Assert-TRI03 ($mutexA -eq $mutexA2) 'same project must map to a stable mutex'
Assert-TRI03 ($mutexA -ne $mutexB) 'different project must not share a mutex'
$run1 = New-TRI03RunId
$run2 = New-TRI03RunId
$logs1 = Get-TRI03RunLogPaths -PlayLog (Join-Path $tempRoot 'godot_play.log') -RunId $run1
$logs2 = Get-TRI03RunLogPaths -PlayLog (Join-Path $env:TEMP 'godot_play.log') -RunId $run2
Assert-TRI03 ($logs1.PlayLog -ne $logs2.PlayLog) 'each launch must get a distinct Godot log'
Assert-TRI03 ($logs1.Stdout -ne $logs2.Stdout -and $logs1.Stderr -ne $logs2.Stderr) 'stdout/stderr must not overwrite previous launches'
$fakePath = Join-Path $tempRoot 'Godot_v4.7.2-stable_win64.exe'
$snapshot = @([pscustomobject]@{ProcessName='Godot_v4.7.2-stable_win64';Id=2188},[pscustomobject]@{ProcessName='notepad';Id=3000})
$detected = @(Get-TRI03ExistingGodotProcesses -GodotPath $fakePath -ProcessSnapshot $snapshot)
Assert-TRI03 ($detected.Count -eq 1 -and $detected[0].Id -eq 2188) 'guard must block Godot and ignore unrelated processes'
$starterPath = Join-Path $run 'Start-TRI03Game.ps1'
$starterText = Get-Content -LiteralPath $starterPath -Raw
Assert-TRI03 ($starterText.Contains('$process.WaitForExit()')) 'launcher must stay attached until game exits'
Assert-TRI03 ($starterText.Contains('$mutex.ReleaseMutex()')) 'launcher must release the lock after process exit'
Assert-TRI03 ($starterText.Contains('launch_process_created')) 'launcher must log PID and run id'
Assert-TRI03 ($starterText.Contains('existing_godot_blocked')) 'launcher must fail closed with an existing Godot process'
foreach ($target in @($starterPath,(Join-Path $run 'tri03_launcher_support.ps1'),$MyInvocation.MyCommand.Path)) {
    $tokens=$null;$errors=$null
    [void][Management.Automation.Language.Parser]::ParseFile($target,[ref]$tokens,[ref]$errors)
    Assert-TRI03 (@($errors).Count -eq 0) ('parse errors in ' + $target)
}
Write-Output 'TRI03_LAUNCHER_SAFETY_TEST_PASS checks=10'
