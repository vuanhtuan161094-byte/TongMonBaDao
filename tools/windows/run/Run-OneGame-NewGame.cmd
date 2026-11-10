@echo off
setlocal
for %%I in ("%~dp0..\..\..") do set "TMB_ROOT=%%~fI\"
if not defined TMB_GODOT set "TMB_GODOT=E:\Godot_v4.7.2-stable_win64.exe"
set "TMB_PROJECT=%TMB_ROOT%godot"
if not defined TMB_PROFILE_ROOT set "TMB_PROFILE_ROOT=%TMB_ROOT%godot\outputs\one_game_newgame\owner_playtest_profile"
if not defined TMB_SESSION_PARENT set "TMB_SESSION_PARENT=%TMB_ROOT%godot\outputs\one_game_newgame\sessions"
if not exist "%TMB_GODOT%" (
  echo Official Godot 4.7.2 GUI was not found at "%TMB_GODOT%".
  echo Set TMB_GODOT to the Godot 4.7.2 executable and run this launcher again.
  exit /b 2
)
if not exist "%TMB_PROJECT%\project.godot" (
  echo One Game project was not found at "%TMB_PROJECT%\project.godot".
  exit /b 3
)
if not exist "%TMB_PROFILE_ROOT%\Roaming" mkdir "%TMB_PROFILE_ROOT%\Roaming" >nul 2>&1
if errorlevel 1 (
  echo Could not create the isolated persistent play profile at "%TMB_PROFILE_ROOT%\Roaming".
  exit /b 4
)
if not exist "%TMB_PROFILE_ROOT%\Local" mkdir "%TMB_PROFILE_ROOT%\Local" >nul 2>&1
if errorlevel 1 (
  echo Could not create the isolated local profile at "%TMB_PROFILE_ROOT%\Local".
  exit /b 4
)
:choose_session
set "TMB_RUN_ID=%RANDOM%_%RANDOM%_%RANDOM%_%RANDOM%"
set "TMB_SESSION_ROOT=%TMB_SESSION_PARENT%\%TMB_RUN_ID%"
if exist "%TMB_SESSION_ROOT%" goto choose_session
set "APPDATA=%TMB_PROFILE_ROOT%\Roaming"
set "LOCALAPPDATA=%TMB_PROFILE_ROOT%\Local"
set "TMB_LOG=%TMB_SESSION_ROOT%\logs\game.log"
set "TMB_PVE_PERF_LOG=0"
mkdir "%TMB_SESSION_ROOT%\logs" >nul 2>&1
if errorlevel 1 (
  echo Could not create the per-run log folder under "%TMB_SESSION_ROOT%".
  exit /b 4
)
set "TMB_SAVE=%APPDATA%\Godot\app_userdata\Tong Mon Ba Dao\tong_mon_ba_dao_live_v2.json"
if exist "%TMB_SAVE%" (
  echo Starting ONE GAME P3.2 and reusing this isolated playtest profile.
  echo Existing save will be loaded when the canonical runtime starts.
) else (
  echo Starting a fresh ONE GAME P3.2 profile; later launches will reuse its save.
)
echo Godot user data: "%TMB_PROFILE_ROOT%"
echo Per-run log: "%TMB_LOG%"
echo Save path: user://tong_mon_ba_dao_live_v2.json under the isolated playtest profile.
"%TMB_GODOT%" --path "%TMB_PROJECT%" --resolution 1280x720 --log-file "%TMB_LOG%"
set "TMB_EXIT=%errorlevel%"
if not "%TMB_EXIT%"=="0" echo Godot exited with code %TMB_EXIT%. See "%TMB_LOG%".
exit /b %TMB_EXIT%
