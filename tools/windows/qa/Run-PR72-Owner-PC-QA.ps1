[CmdletBinding()]
param([switch]$ResumeOnly,[switch]$HarnessSelfTest)
$ErrorActionPreference = 'Stop'
$branch = 'integration/pve-p0-playable-ui-20261103'
$canonical = 'E:\TongMonBaDaoWorkspace\01_Game\TongMonBaDao'
$windowApi = @'
using System;
using System.Runtime.InteropServices;
public static class PR72Window {
 [StructLayout(LayoutKind.Sequential)] public struct Rect { public int Left,Top,Right,Bottom; }
 [StructLayout(LayoutKind.Sequential)] public struct Point { public int X,Y; }
 [DllImport("user32.dll")] public static extern bool GetClientRect(IntPtr hWnd,out Rect rect);
 [DllImport("user32.dll")] public static extern bool ClientToScreen(IntPtr hWnd,ref Point point);
 [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
 [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
}
'@
Add-Type -AssemblyName System.Drawing
Add-Type -TypeDefinition $windowApi -ErrorAction Stop
if ($HarnessSelfTest) { Write-Host 'PR72_OWNER_PC_QA_HARNESS_SELFTEST_PASS: Windows PowerShell + Win32 compiled'; exit 0 }
function Fail([string]$why) { throw ('PR72_PC_QA_BLOCKED: ' + $why) }
function Identity([string]$path) {
 if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return 'MISSING' }
 return (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
}
function FindGame {
 $name = [IO.Path]::GetFileName($godot).Replace("'","''")
 foreach($x in @(Get-CimInstance Win32_Process -Filter ("Name='{0}'" -f $name))) {
  $line = [string]$x.CommandLine
  if($line.IndexOf('--path',[StringComparison]::OrdinalIgnoreCase) -ge 0 -and
     $line.IndexOf($project,[StringComparison]::OrdinalIgnoreCase) -ge 0) { return $x }
 }
 return $null
}
function Sample([string]$stage) {
 $p = Get-Process -Id $script:pidGodot -ErrorAction SilentlyContinue
 if($null -eq $p) { return }
 try {
  $p.Refresh()
  $script:samples.Add(('{0},{1},{2},{3},{4},{5}' -f
    [DateTime]::UtcNow.ToString('o'),$script:pidGodot,$stage,
    [math]::Round($p.WorkingSet64/1MB,2),[math]::Round($p.PrivateMemorySize64/1MB,2),
    [math]::Round($p.TotalProcessorTime.TotalSeconds,2)))
 } catch {}
}
function Capture([string]$name) {
 $p = Get-Process -Id $script:pidGodot -ErrorAction Stop
 $p.Refresh()
 if($p.MainWindowHandle -eq [IntPtr]::Zero) { Fail ('No real HWND: '+$name) }
 $rect = New-Object PR72Window+Rect
 $point = New-Object PR72Window+Point
 if(-not [PR72Window]::GetClientRect($p.MainWindowHandle,[ref]$rect) -or
    -not [PR72Window]::ClientToScreen($p.MainWindowHandle,[ref]$point)) { Fail 'Cannot locate Godot client area' }
 $w = $rect.Right-$rect.Left; $h = $rect.Bottom-$rect.Top
 if($w -le 0 -or $h -le 0) { Fail 'Godot window has no visible client area' }
 [PR72Window]::SetForegroundWindow($p.MainWindowHandle) | Out-Null
 Start-Sleep -Milliseconds 600
 $bmp = [Drawing.Bitmap]::new($w,$h)
 $graphics = [Drawing.Graphics]::FromImage($bmp)
 try {
  $graphics.CopyFromScreen($point.X,$point.Y,0,0,[Drawing.Size]::new($w,$h))
  $dest = Join-Path $out ($name+'.png')
  $bmp.Save($dest,[Drawing.Imaging.ImageFormat]::Png)
  $script:photos.Add([pscustomobject]@{file=$dest;width=$w;height=$h;status='MANUAL_VISUAL_REVIEW_PENDING'})
  if($w -ne 1280 -or $h -ne 720) { $script:warnings.Add(('Window client is {0}x{1}, not 1280x720 at {2}' -f $w,$h,$name)) }
  Write-Host ('Captured Windows screenshot: '+$dest)
 } finally { $graphics.Dispose(); $bmp.Dispose() }
}
function Stage([string]$instruction,[string]$shot) {
 Write-Host ''
 Write-Host ('PLAY IN GODOT: '+$instruction)
 Write-Host 'Return to this QA console; ENTER = screenshot, S = skip (PENDING), Q = stop (without killing game).'
 $next = Get-Date
 while($true) {
  if($null -eq (Get-Process -Id $script:pidGodot -ErrorAction SilentlyContinue)) { Fail ('Game exited during '+$shot) }
  if((Get-Date) -ge $next) { Sample $shot; $next = (Get-Date).AddSeconds(1) }
  if([Console]::KeyAvailable) {
   $key = [Console]::ReadKey($true).Key
   if($key -eq [ConsoleKey]::Enter) { Capture $shot; return $true }
   if($key -eq [ConsoleKey]::S) { $script:warnings.Add('SKIPPED '+$shot); return $true }
   if($key -eq [ConsoleKey]::Q) { $script:warnings.Add('USER_STOPPED '+$shot); return $false }
  }
  Start-Sleep -Milliseconds 160
 }
}
function WaitForClose {
 Write-Host 'Save by using the real GAME controls, then close the Godot window normally. No force-kill.'
 $start = Get-Date; $next = Get-Date
 while(((Get-Date)-$start).TotalMinutes -lt 25) {
  if($null -eq (Get-Process -Id $script:pidGodot -ErrorAction SilentlyContinue)) { return $true }
  if((Get-Date) -ge $next) { Sample 'waiting_for_manual_close'; $next=(Get-Date).AddSeconds(1) }
  Start-Sleep -Milliseconds 250
 }
 $script:warnings.Add('Game still open; QA did not kill it')
 return $false
}
function Launch([string]$id) {
 if($null -ne (FindGame)) { Fail 'Same-project Godot already running: no duplicate launch' }
 $env:TMB_PROFILE_ROOT = $qaProfile
 $env:TMB_SESSION_PARENT = Join-Path $out ('godot_sessions_'+$id)
 $env:TMB_PVE_RAW_FRAME_LOG_PATH = Join-Path $out ('frames_'+$id+'.csv')
 $env:TMB_PVE_PERF_LOG = '0'
 $wrapper = Join-Path $out ('open_'+$id+'.cmd')
 $stdout = Join-Path $out ('launcher_'+$id+'.log')
 @('@echo off',('call "'+(Join-Path $root 'MO_GAME.cmd')+'" > "'+$stdout+'" 2>&1'),
    'exit /b %ERRORLEVEL%') | Set-Content -LiteralPath $wrapper -Encoding ASCII
 $pinfo = [Diagnostics.ProcessStartInfo]::new()
 $pinfo.FileName=$env:ComSpec
 $pinfo.Arguments=('/d /s /c ""{0}""' -f $wrapper)
 $pinfo.WorkingDirectory=$root
 $pinfo.UseShellExecute=$true
 $process=[Diagnostics.Process]::Start($pinfo)
 if($null -eq $process) { Fail 'Canonical MO_GAME launcher did not start' }
 $start=Get-Date
 while(((Get-Date)-$start).TotalSeconds -lt 110) {
  $found=FindGame
  if($null -ne $found) {
   $script:pidGodot=[int]$found.ProcessId
   $p=Get-Process -Id $script:pidGodot -ErrorAction SilentlyContinue
   if($null -ne $p -and $p.MainWindowHandle -ne [IntPtr]::Zero -and $p.Responding) {
    Write-Host ('Actual Godot Windows GUI PID: '+$script:pidGodot)
    return
   }
  }
  if($process.HasExited) { Fail ('MO_GAME exited before responsive Godot window; see '+$stdout) }
  Start-Sleep -Milliseconds 800
 }
 Fail ('No responsive Godot HWND within 110s; see '+$stdout)
}
function Fps([string]$id) {
 $file=Join-Path $out ('frames_'+$id+'.csv')
 if(-not (Test-Path -LiteralPath $file)) { return @{session=$id;status='NO_REAL_FRAME_CSV'} }
 $data=@(Import-Csv -LiteralPath $file)
 $values=@($data | Where-Object { [double]$_.fps -gt 0 })
 if($values.Count -lt 10) { return @{session=$id;status='INSUFFICIENT_FRAMES';count=$values.Count} }
 $mean=($values | Measure-Object -Property fps -Average).Average
 $frameMs=@($values | ForEach-Object { [double]$_.delta_ms } | Sort-Object)
 $idx=[int][math]::Floor(0.95*($frameMs.Count-1))
 return @{session=$id;status='GODOT_FRAME_LOG';frames=$values.Count;
  mean_fps=[math]::Round($mean,2);p95_frame_ms=[math]::Round($frameMs[$idx],2)}
}
$root=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..')).TrimEnd('\')
if(-not [string]::Equals($root,$canonical,[StringComparison]::OrdinalIgnoreCase)) { Fail ('Expected canonical E: checkout, found '+$root) }
$project=Join-Path $root 'godot'
if(-not (Test-Path (Join-Path $project 'project.godot'))) { Fail 'project.godot missing' }
$head=(& git -C $root rev-parse HEAD 2>&1 | Select-Object -Last 1)
$actualBranch=(& git -C $root branch --show-current 2>&1 | Select-Object -Last 1)
if($LASTEXITCODE -ne 0 -or $actualBranch -ne $branch -or $head -notmatch '^[a-f0-9]{40}$') {
 Fail ('Git must be on PR72 branch, SHA='+$head+' branch='+$actualBranch)
}
$godot='E:\TongMonBaDaoWorkspace\04_Tools\Godot\Godot_v4.7.2-stable_win64.exe'
if(-not (Test-Path $godot)) { $godot='E:\Godot_v4.7.2-stable_win64.exe' }
if(-not (Test-Path $godot)) { Fail 'Official Godot Windows 4.7.2 GUI not found on E:' }
$version=@(& $godot --headless --version 2>&1) -join ' '
if($LASTEXITCODE -ne 0 -or $version -notmatch '4\.7\.2\.stable\.official') { Fail ('Wrong Godot version: '+$version) }
if($null -ne (FindGame)) { Fail 'A Godot instance of this project is already running; do not duplicate' }
$qaBase='E:\TongMonBaDaoWorkspace\03_QA_Logs\PR72_PC_QA'
$out=Join-Path $qaBase ('run_'+[DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfffZ'))
$qaProfile=Join-Path $qaBase 'isolated_profile'
New-Item -ItemType Directory -Force -Path $out,$qaProfile | Out-Null
$qaSave=Join-Path $qaProfile 'Roaming\Godot\app_userdata\Tong Mon Ba Dao\tong_mon_ba_dao_live_v2.json'
$originalSave=Join-Path $root 'godot\outputs\one_game_newgame\owner_playtest_profile\Roaming\Godot\app_userdata\Tong Mon Ba Dao\tong_mon_ba_dao_live_v2.json'
$before=@{}; foreach($ext in @('','.bak','.tmp')) { $before[$ext]=Identity ($originalSave+$ext) }
$script:photos=New-Object 'System.Collections.Generic.List[object]'
$script:warnings=New-Object 'System.Collections.Generic.List[string]'
$script:samples=New-Object 'System.Collections.Generic.List[string]'
$script:samples.Add('utc,pid,stage,working_set_mb,private_mb,cpu_seconds')
$startUtc=[DateTime]::UtcNow
$manifest=[ordered]@{source_sha=$head;branch=$actualBranch;godot_version=$version;
 evidence_kind='REAL_WINDOWS10_PC_PENDING_USER_EXECUTION';started_utc=$startUtc.ToString('o');
 original_save_before=$before;qa_profile=$qaProfile;output_dir=$out;run_status='PENDING';
 screenshots=@();gpu=@(Get-CimInstance Win32_VideoController | Select-Object Name,DriverVersion,DriverDate);
 windows=(Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version,BuildNumber);
 android='NOT_TESTED'}
Write-Host ('PR72 Windows QA source: '+$head)
Write-Host ('Original owner Save isolated; QA evidence at '+$out)
try {
 $stamp=Join-Path $qaBase 'last_closed_utc.txt'
 if($ResumeOnly) {
  if(-not (Test-Path $qaSave)) { Fail 'No isolated QA Save available for cold resume' }
  if(Test-Path $stamp) {
   $closed=[datetime]::Parse((Get-Content $stamp -Raw).Trim(),[Globalization.CultureInfo]::InvariantCulture,[Globalization.DateTimeStyles]::RoundtripKind)
   $manifest.elapsed_real_minutes_since_last_close=[math]::Round(($startUtc-$closed.ToUniversalTime()).TotalMinutes,2)
   $manifest.offline_label='Wall-clock interval, requires user observation of no intervening game launch'
  }
  Launch 'resume'
  [void](Stage 'Reopen QA Save and inspect Warehouse/profession XP' '06_resumed_warehouse')
  [void](WaitForClose)
 } else {
  Launch 'first'
  foreach($part in @(
   @('Map: real mouse pan/zoom, confirm no clipping','00_map'),
   @('Mine: assign worker, start real job, inspect timer/XP','01_mine'),
   @('Linh Lam: assign worker, inspect timber and ETA','02_forest'),
   @('Linh Dien: plant/harvest and inspect real crop progress','03_field'),
   @('Warehouse: inspect actual settled goods','04_warehouse'))) {
   if(-not (Stage $part[0] $part[1])) { break }
  }
  if(WaitForClose) {
   if(-not (Test-Path $qaSave)) { Fail 'Isolated QA Save not found after first closure' }
   $manifest.qa_save_first_sha256=Identity $qaSave
   Launch 'reopen'
   [void](Stage 'Cold Save/Load: compare Warehouse and worker levels' '05_cold_reopened_warehouse')
   [void](WaitForClose)
  }
 }
 if(Test-Path $qaSave) {
  $manifest.qa_save_final_sha256=Identity $qaSave
  try { Get-Content $qaSave -Raw -Encoding UTF8 | ConvertFrom-Json -ErrorAction Stop | Out-Null }
  catch { Fail ('QA Save JSON invalid: '+$_.Exception.Message) }
 }
} catch { $script:warnings.Add('BLOCKED/FAIL: '+$_.Exception.Message) }
finally {
 $alive=FindGame
 if($null -ne $alive) { $script:warnings.Add('Game still running; process not killed: '+$alive.ProcessId) }
 elseif((Test-Path $qaSave) -and $script:warnings.Count -eq 0) {
  [DateTime]::UtcNow.ToString('o') | Set-Content -LiteralPath (Join-Path $qaBase 'last_closed_utc.txt') -Encoding ASCII
 }
 $after=@{};foreach($ext in @('','.bak','.tmp')) {
  $after[$ext]=Identity ($originalSave+$ext)
  if($after[$ext] -ne $before[$ext]) { $script:warnings.Add('OWNER SAVE CHANGED: '+$ext) }
 }
 $script:samples | Set-Content -LiteralPath (Join-Path $out 'process_ram_cpu_samples.csv') -Encoding UTF8
 $events=@()
 try {
  $events=@(Get-WinEvent -FilterHashtable @{LogName='Application';Id=@(1000,1001);StartTime=$startUtc.ToLocalTime()} -ErrorAction SilentlyContinue |
    Where-Object { $_.Message -match 'ig11icd64|Godot_v4\.7\.2|Godot.*\.exe' } |
    Select-Object -First 15 TimeCreated,Id,ProviderName,Message)
 } catch {}
 if($events.Count -gt 0) { $script:warnings.Add('Godot/Intel crash events detected in Windows Event Viewer') }
 $manifest.original_save_after=$after
 $manifest.crash_events=$events
 $manifest.screenshots=@($script:photos.ToArray())
 $manifest.fps=@(Fps 'first',Fps 'reopen',Fps 'resume')
 $manifest.warnings=@($script:warnings.ToArray())
 $manifest.run_status=if($script:warnings.Count -gt 0) {'PARTIAL_OR_BLOCKED'} else {'EVIDENCE_CAPTURED_VISUAL_ACCEPTANCE_PENDING'}
 $manifest.ended_utc=[DateTime]::UtcNow.ToString('o')
 $manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $out 'manifest.json') -Encoding UTF8
 Write-Host ('QA evidence: '+$out)
 Write-Host ('QA status: '+$manifest.run_status)
 Write-Host 'NO Android hardware or owner visual PASS is implied.'
}
if($script:warnings.Count -gt 0) { exit 1 }
exit 0
