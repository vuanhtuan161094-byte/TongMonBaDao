@echo off
setlocal
rem Actual P3.2 GUI profiler. Pass /log to enable P3.2's detailed 3 s logger.
rem The passive JSONL frame probe runs in both modes to compare its overhead.
if not defined TMB_GODOT set "TMB_GODOT=E:\Godot_v4.7.2-stable_win64_console.exe"
set "TMB_PROJECT=%~dp0godot"
set "TMB_PROFILE=%~dp0godot\outputs\pve_perf_qa_20261026\userdata\profile"
set "TMB_LOG_DIR=%~dp0godot\outputs\pve_perf_qa_20261026\logs"
set "TMB_PVE_PERF_LOG=0"
if /I "%~1"=="/log" set "TMB_PVE_PERF_LOG=1"
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss_fff"') do set "TMB_RUN_STAMP=%%i"
for /f %%i in ('git -C "%~dp0." rev-parse HEAD') do set "TMB_PVE_EXACT_SHA=%%i"
set "TMB_LOG=%TMB_LOG_DIR%\normal_gui_%TMB_RUN_STAMP%_%TMB_PVE_PERF_LOG%.godot.log"
if not exist "%TMB_GODOT%" (
  echo TMB_PVE_PERF_LAUNCH_FAIL: official Godot 4.7.2 console binary not found: %TMB_GODOT%
  echo Set TMB_GODOT to the installed Godot_v4.7.2-stable_win64_console.exe path.
  pause
  exit /b 2
)
if not exist "%TMB_PROFILE%\Roaming" mkdir "%TMB_PROFILE%\Roaming"
if not exist "%TMB_PROFILE%\Local" mkdir "%TMB_PROFILE%\Local"
if not exist "%TMB_LOG_DIR%" mkdir "%TMB_LOG_DIR%"
set "APPDATA=%TMB_PROFILE%\Roaming"
set "LOCALAPPDATA=%TMB_PROFILE%\Local"
if "%TMB_PVE_PERF_LOG%"=="1" (
  echo Starting normal P3.2 GUI with detailed P3.2 profiler logging ON.
) else (
  echo Starting normal P3.2 GUI with detailed P3.2 profiler logging OFF.
)
echo In both runs, JSONL records monotonic 3 second frame samples and P50/P95/P99/1%% low.
echo Play 15 seconds in Sect, then 30 to 60 seconds in Thanh Truc Lam, Save and Return.
echo Use real mouse input. Do not use MovieWriter for FPS measurement.
"%TMB_GODOT%" --path "%TMB_PROJECT%" --resolution 1280x720 --log-file "%TMB_LOG_DIR%\normal_gui_%TMB_PVE_PERF_LOG%.godot.log" --script res://tools/qa/pve_playable_perf_launcher.gd
set "TMB_RESULT=%errorlevel%"
if not "%TMB_RESULT%"=="0" echo TMB_PVE_PERF: Godot exited with code %TMB_RESULT%.
exit /b %TMB_RESULT%
