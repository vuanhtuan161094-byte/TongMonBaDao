@echo off
setlocal
set "TMB_GODOT=E:\Godot_v4.7.2-stable_win64.exe"
set "TMB_PROJECT=%~dp0godot"
set "APPDATA=%~dp0godot\outputs\pve_jx_world_20261026\userdata\R"
set "LOCALAPPDATA=%~dp0godot\outputs\pve_jx_world_20261026\userdata\L"
set "TMB_ENDGAME_PLAY_SAVE_PATH=outputs/pve_jx_world_20261026/userdata/pve_play_launcher/live_save_130.json"
set "TMB_PVE_PERF_LOG=0"
set "TMB_LOG=%~dp0godot\outputs\pve_jx_world_20261026\logs\pve_play_launcher_cache_optimized_20261026.godot.log"
if not exist "%APPDATA%" mkdir "%APPDATA%"
if not exist "%LOCALAPPDATA%" mkdir "%LOCALAPPDATA%"
if not exist "%TMB_GODOT%" (
  echo Official Godot 4.7.2 GUI was not found at "%TMB_GODOT%".
  exit /b 2
)
echo Opening the normal P3.2 game with an isolated 130-disciple QA save.
echo From the bottom bar choose "Săn quái / Thanh Trúc Lâm", select six eligible disciples, then enter.
echo This save is separate from the regular player save.
"%TMB_GODOT%" --path "%TMB_PROJECT%" --resolution 1280x720 --log-file "%TMB_LOG%" --script res://tools/qa/endgame_live_launcher.gd -- --tmb-roster=130
set "TMB_EXIT=%errorlevel%"
if not "%TMB_EXIT%"=="0" echo Godot exited with code %TMB_EXIT%. See "%TMB_LOG%".
exit /b %TMB_EXIT%
