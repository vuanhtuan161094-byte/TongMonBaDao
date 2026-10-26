@echo off
setlocal
set "TMB_GODOT=E:\Godot_v4.7.2-stable_win64.exe"
set "TMB_GODOT_CONSOLE=E:\Godot_v4.7.2-stable_win64_console.exe"
set "TMB_PROJECT=%~dp0godot"
set "TMB_SOURCE=E:\codex\work\jxqy2_slice\source"
set "TMB_DATA=%TMB_PROJECT%\outputs\pve_jx_world_20261026\userdata\launcher"
set "TMB_LOGS=%TMB_PROJECT%\outputs\pve_jx_world_20261026\logs"
set "TMB_LOG=%TMB_LOGS%\windows_launcher.log"
if not exist "%TMB_GODOT%" (
  echo Godot 4.7.2 GUI executable not found: %TMB_GODOT%
  pause
  exit /b 2
)
if not exist "%TMB_GODOT_CONSOLE%" (
  echo Godot 4.7.2 console executable not found: %TMB_GODOT_CONSOLE%
  pause
  exit /b 2
)
if not exist "%TMB_SOURCE%" (
  echo Pinned local JXQY2 source library missing: %TMB_SOURCE%
  echo The project will not substitute mock terrain or placeholder actors.
  pause
  exit /b 3
)
if not exist "%TMB_LOGS%" mkdir "%TMB_LOGS%"
if not exist "%TMB_DATA%\Roaming" mkdir "%TMB_DATA%\Roaming"
if not exist "%TMB_DATA%\Local" mkdir "%TMB_DATA%\Local"
if not exist "%TMB_DATA%\Roaming\Godot\app_userdata\Tong Mon Ba Dao\logs" mkdir "%TMB_DATA%\Roaming\Godot\app_userdata\Tong Mon Ba Dao\logs"
set "APPDATA=%TMB_DATA%\Roaming"
set "LOCALAPPDATA=%TMB_DATA%\Local"
set "TMB_JXQY2_ASSET_ROOT=%TMB_SOURCE%"
echo Launching P3.2 continuous JXQY2 world at 1280x720.
echo Save is isolated under %TMB_DATA%.
echo Log: %TMB_LOG%
start "" /D "%TMB_PROJECT%" "%TMB_GODOT%" --path "%TMB_PROJECT%" --resolution 1280x720 res://tools/qa/pve_open_world_live_launcher.tscn --log-file "%TMB_LOG%"
exit /b 0
