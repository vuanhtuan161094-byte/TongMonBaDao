param()
$ErrorActionPreference = 'Stop'
$run = Join-Path $PSScriptRoot '..\run'
. (Join-Path $run 'tri03_launcher_support.ps1')
$script:Checks = 0
function Assert-TRI03([bool] $Condition,[string] $Message) {
    $script:Checks++
    if (-not $Condition) { throw "TRI03_LAUNCHER_SAFETY_TEST_FAIL: $Message" }
}
$root = Join-Path ([IO.Path]::GetTempPath()) 'TMB-OneGame-Launcher-Test'
$other = Join-Path ([IO.Path]::GetTempPath()) 'TMB-OneGame-Launcher-Other'
$mutexA = Get-TRI03ProjectMutexName -ProjectPath $root
$mutexA2 = Get-TRI03ProjectMutexName -ProjectPath $root
$mutexB = Get-TRI03ProjectMutexName -ProjectPath $other
Assert-TRI03 ($mutexA -eq $mutexA2) 'same project must map to a stable mutex'
Assert-TRI03 ($mutexA -ne $mutexB) 'different project must not share a mutex'
$run1 = New-TRI03RunId
$run2 = New-TRI03RunId
$logs1 = Get-TRI03RunLogPaths -PlayLog (Join-Path $root 'godot_play.log') -RunId $run1
$logs2 = Get-TRI03RunLogPaths -PlayLog (Join-Path $root 'godot_play.log') -RunId $run2
Assert-TRI03 ($run1 -ne $run2) 'each launcher lifetime must have a unique run id'
Assert-TRI03 ($logs1.PlayLog -ne $logs2.PlayLog) 'each launch must get a distinct Godot log'
Assert-TRI03 ($logs1.Stdout -ne $logs2.Stdout -and $logs1.Stderr -ne $logs2.Stderr) 'stdout/stderr must not overwrite previous launches'
$godot = Join-Path $root 'Godot_v4.7.2-stable_win64.exe'
$pathA = '--path "' + $root + '"'
$pathB = '--path "' + $other + '"'
$snapshot = @(
    [pscustomobject]@{ProcessName='Godot_v4.7.2-stable_win64';Id=2188;SessionId=2;CommandLine=$null},
    [pscustomobject]@{ProcessName='Godot_v4.7.2-stable_win64';Id=2189;SessionId=2;CommandLine="$godot $pathA"},
    [pscustomobject]@{ProcessName='Godot_v4.7.2-stable_win64';Id=3001;SessionId=3;CommandLine="$godot $pathA"},
    [pscustomobject]@{ProcessName='Godot_v4.7.2-stable_win64';Id=3002;SessionId=3;CommandLine="$godot $pathB"},
    [pscustomobject]@{ProcessName='Godot_v4.7.2-stable_win64';Id=3003;SessionId=3;CommandLine=$null},
    [pscustomobject]@{ProcessName='Godot_v4.7.2-stable_win64';Id=3004;SessionId=3;CommandLine="$godot --editor"}
)
$assessed = @(Get-TRI03ExistingGodotProcesses -GodotPath $godot -ProjectPath $root -CurrentSessionId 3 -ProcessSnapshot $snapshot)
$foreignUnknown = @($assessed | Where-Object Id -eq 2188)
Assert-TRI03 ($foreignUnknown.Count -eq 1 -and -not $foreignUnknown[0].BlocksLaunch -and $foreignUnknown[0].Reason -eq 'foreign_unknown_identity') 'foreign-session inaccessible PID 2188 must be warning-only'
$foreignSameProject = @($assessed | Where-Object Id -eq 2189)
Assert-TRI03 ($foreignSameProject.Count -eq 1 -and $foreignSameProject[0].BlocksLaunch -and $foreignSameProject[0].Reason -eq 'foreign_session_same_project') 'known same-project process must remain a duplicate'
$sameProject = @($assessed | Where-Object Id -eq 3001)
Assert-TRI03 ($sameProject.Count -eq 1 -and $sameProject[0].BlocksLaunch -and $sameProject[0].Reason -eq 'same_session_same_project') 'same-session same-project process must block a duplicate'
$otherProject = @($assessed | Where-Object Id -eq 3002)
Assert-TRI03 ($otherProject.Count -eq 1 -and -not $otherProject[0].BlocksLaunch -and $otherProject[0].Reason -eq 'same_session_different_project') 'same-session different-project Godot must not block this project'
$sameUnknown = @($assessed | Where-Object Id -eq 3003)
Assert-TRI03 ($sameUnknown.Count -eq 1 -and $sameUnknown[0].BlocksLaunch -and $sameUnknown[0].Reason -eq 'same_session_unknown_process_identity') 'same-session inaccessible Godot must fail closed'
$sameEditorUnknown = @($assessed | Where-Object Id -eq 3004)
Assert-TRI03 ($sameEditorUnknown.Count -eq 1 -and $sameEditorUnknown[0].BlocksLaunch -and $sameEditorUnknown[0].Reason -eq 'same_session_missing_project_argument') 'same-session process without project argument must fail closed'
Assert-TRI03 (@($assessed | Where-Object { $_.BlocksLaunch }).Count -eq 4) 'only verified same-project or same-session unknown processes may block'

$sequenceName = 'Local\TMB.Test.Lifecycle.' + [Guid]::NewGuid().ToString('N')
$first = [Threading.Mutex]::new($false,$sequenceName)
Assert-TRI03 ($first.WaitOne(0)) 'first launch must acquire its project lock'
$first.ReleaseMutex()
$first.Dispose()
$second = [Threading.Mutex]::new($false,$sequenceName)
Assert-TRI03 ($second.WaitOne(0)) 'clean process exit must allow relaunch'
$second.ReleaseMutex()
$second.Dispose()

if (-not ('TmbTri03MutexAbandoner' -as [type])) {
    Add-Type -TypeDefinition @'
using System;
using System.Threading;
public static class TmbTri03MutexAbandoner {
    public static Thread Start(string name) {
        var thread = new Thread(() => { var mutex = new Mutex(false, name); mutex.WaitOne(); });
        thread.IsBackground = true;
        thread.Start();
        return thread;
    }
}
'@
}
$abandonedName = 'Local\TMB.Test.Abandoned.' + [Guid]::NewGuid().ToString('N')
$ownerThread = [TmbTri03MutexAbandoner]::Start($abandonedName)
$ownerThread.Join()
$abandoned = [Threading.Mutex]::new($false,$abandonedName)
$recovered = $false
try { $recovered = $abandoned.WaitOne(0) }
catch [Threading.AbandonedMutexException] { $recovered = $true }
Assert-TRI03 $recovered 'stale/abandoned project mutex must be recoverable by the next owner'
$abandoned.ReleaseMutex()
$abandoned.Dispose()

$starterPath = Join-Path $run 'Start-TRI03Game.ps1'
$starterText = Get-Content -LiteralPath $starterPath -Raw
Assert-TRI03 ($starterText.Contains('$process.WaitForExit()')) 'launcher must stay attached until game exits'
Assert-TRI03 ($starterText.Contains('$mutex.ReleaseMutex()')) 'launcher must release its lock after process exit'
Assert-TRI03 ($starterText.Contains('launch_process_created')) 'launcher must log PID and run id'
Assert-TRI03 ($starterText.Contains('existing_godot_blocked')) 'launcher must block an identified same-project collision'
Assert-TRI03 ($starterText.Contains('unknown_process_identity')) 'launcher must record inaccessible process identity'
Assert-TRI03 ($starterText.Contains('$process.MainWindowHandle -ne [IntPtr]::Zero -and $process.Responding')) 'READY must require a real responsive window'
Assert-TRI03 ($starterText.IndexOf('Game window ready:') -gt $starterText.IndexOf('$process.MainWindowHandle -ne [IntPtr]::Zero -and $process.Responding')) 'READY marker must not be emitted before the window readiness guard'
foreach ($target in @($starterPath,(Join-Path $run 'tri03_launcher_support.ps1'),$MyInvocation.MyCommand.Path)) {
    $tokens=$null;$errors=$null
    [void][Management.Automation.Language.Parser]::ParseFile($target,[ref]$tokens,[ref]$errors)
    Assert-TRI03 (@($errors).Count -eq 0) ('parse errors in ' + $target)
}
Write-Output ('TRI03_LAUNCHER_SAFETY_TEST_PASS checks={0}' -f $script:Checks)

