@echo off
setlocal
rem PVE PERF-02: ACTUAL P3.2 + Source A, normal interactive GUI, NO MovieWriter.
rem Optional override: set TMB_GODOT=E:\path\to\Godot_v4.7.2-stable_win64_console.exe
if not defined TMB_GODOT set "TMB_GODOT=E:\Godot_v4.7.2-stable_win64_console.exe"
set "TMB_PROJECT=%~dp0godot"
set "TMB_PROFILE=%~dp0outputs\pve_perf_qa_20261026\userdata"
set "TMB_LOG_DIR=%~dp0outputs\pve_perf_qa_20261026\logs"
set "TMB_LOG=%TMB_LOG_DIR%\normal_gui.log"
if not exist "%TMB_GODOT%" (
  echo TMB_PVE_PERF_LAUNCH_FAIL: Godot 4.7.2 binary not found: %TMB_GODOT%
  echo Set TMB_GODOT to your official Godot 4.7.2 Windows console executable.
  pause
  exit /b 2
)
if not exist "%TMB_PROFILE%\Roaming" mkdir "%TMB_PROFILE%\Roaming"
if not exist "%TMB_PROFILE%\Local" mkdir "%TMB_PROFILE%\Local"
if not exist "%TMB_LOG_DIR%" mkdir "%TMB_LOG_DIR%"
set "APPDATA=%TMB_PROFILE%\Roaming"
set "LOCALAPPDATA=%TMB_PROFILE%\Local"
echo Starting REAL Tong Mon Ba Dao P3.2 (Source A PvE) at 1280x720.
echo Uses isolated QA save. Does not read or change your production save.
echo Play Sect for 15 seconds, enter Thanh Truc Lam and fight for 30 seconds.
echo Metrics: godot\outputs\pve_perf_qa_20261026\metrics\*.jsonl
echo Runtime log: %TMB_LOG%
"%TMB_GODOT%" --path "%TMB_PROJECT%" --resolution 1280x720 --log-file "%TMB_LOG%" --script res://tools/qa/pve_playable_perf_launcher.gd
set "TMB_RESULT=%errorlevel%"
if not "%TMB_RESULT%"=="0" (
  echo TMB_PVE_PERF: Godot exited with error code %TMB_RESULT%.
  pause
)
exit /b %TMB_RESULT%
