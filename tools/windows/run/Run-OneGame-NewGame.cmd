@echo off
setlocal
for %%I in ("%~dp0..\..\..") do set "TMB_ROOT=%%~fI\"
if not defined TMB_GODOT set "TMB_GODOT=E:\Godot_v4.7.2-stable_win64.exe"
set "TMB_PROJECT=%TMB_ROOT%godot"
set "TMB_SESSION_PARENT=%TMB_ROOT%godot\outputs\one_game_newgame\sessions"
if not exist "%TMB_GODOT%" (
  echo Official Godot 4.7.2 GUI was not found at "%TMB_GODOT%".
  echo Set TMB_GODOT to the Godot 4.7.2 executable and run this launcher again.
  exit /b 2
)
if not exist "%TMB_PROJECT%\project.godot" (
  echo One Game project was not found at "%TMB_PROJECT%".
  exit /b 3
)
:choose_session
set "TMB_RUN_ID=%RANDOM%_%RANDOM%_%RANDOM%_%RANDOM%"
set "TMB_SESSION_ROOT=%TMB_SESSION_PARENT%\%TMB_RUN_ID%"
if exist "%TMB_SESSION_ROOT%" goto choose_session
set "APPDATA=%TMB_SESSION_ROOT%\Roaming"
set "LOCALAPPDATA=%TMB_SESSION_ROOT%\Local"
set "TMB_LOG=%TMB_SESSION_ROOT%\logs\new_game.log"
set "TMB_PVE_PERF_LOG=0"
mkdir "%APPDATA%" >nul 2>&1
if errorlevel 1 (
  echo Could not create isolated New Game profile at "%APPDATA%".
  exit /b 4
)
mkdir "%LOCALAPPDATA%" >nul 2>&1
if errorlevel 1 (
  echo Could not create isolated local profile at "%LOCALAPPDATA%".
  exit /b 4
)
mkdir "%TMB_SESSION_ROOT%\logs" >nul 2>&1
if errorlevel 1 (
  echo Could not create isolated log folder under "%TMB_SESSION_ROOT%".
  exit /b 4
)
echo Starting P3.2 through the project main scene with a new empty Godot user profile.
echo The canonical LiveGameRuntimeV2 will initialize P37Factory and SaveService.
echo This is a fresh run, separate from Run-PVE-Play.cmd and its seeded QA save.
echo Session profile: "%TMB_SESSION_ROOT%"
echo Save: user://tong_mon_ba_dao_live_v2.json under this isolated profile.
"%TMB_GODOT%" --path "%TMB_PROJECT%" --resolution 1280x720 --log-file "%TMB_LOG%"
set "TMB_EXIT=%errorlevel%"
if not "%TMB_EXIT%"=="0" echo Godot exited with code %TMB_EXIT%. See "%TMB_LOG%".
exit /b %TMB_EXIT%
