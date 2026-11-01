@echo off
setlocal EnableExtensions
for %%I in ("%~dp0..\..\..") do set "TMB_ROOT=%%~fI\"
set "TMB_GODOT=E:\TongMonBaDaoWorkspace\04_Tools\Godot\Godot_v4.7.2-stable_win64.exe"
set "TMB_PROJECT=%TMB_ROOT%godot"
set "TMB_PROFILE_ROOT=%TMB_ROOT%godot\outputs\dan_tien_owner_playtest_profile"
if not exist "%TMB_GODOT%" (
  echo Official Godot 4.7.2 was not found at "%TMB_GODOT%".
  exit /b 2
)
if not exist "%TMB_PROJECT%\project.godot" (
  echo ONE GAME project was not found at "%TMB_PROJECT%\project.godot".
  exit /b 3
)
if not exist "%TMB_PROFILE_ROOT%\Roaming" mkdir "%TMB_PROFILE_ROOT%\Roaming" >nul 2>&1
if errorlevel 1 exit /b 4
if not exist "%TMB_PROFILE_ROOT%\Local" mkdir "%TMB_PROFILE_ROOT%\Local" >nul 2>&1
if errorlevel 1 exit /b 4
if not exist "%TMB_PROFILE_ROOT%\logs" mkdir "%TMB_PROFILE_ROOT%\logs" >nul 2>&1
if errorlevel 1 exit /b 4
set "APPDATA=%TMB_PROFILE_ROOT%\Roaming"
set "LOCALAPPDATA=%TMB_PROFILE_ROOT%\Local"
set "TMB_PVE_PERF_LOG=0"
set "TMB_LOG=%TMB_PROFILE_ROOT%\logs\game.log"
echo ONE GAME Dẫn Tiên RC — Godot 4.7.2 — 1280x720
echo Isolated playtest profile: "%TMB_PROFILE_ROOT%"
echo This profile starts fresh once and then keeps its own save.
echo Game log: "%TMB_LOG%"
"%TMB_GODOT%" --path "%TMB_PROJECT%" --resolution 1280x720 --log-file "%TMB_LOG%"
set "TMB_EXIT=%ERRORLEVEL%"
if not "%TMB_EXIT%"=="0" echo Godot exited with code %TMB_EXIT%.
exit /b %TMB_EXIT%
