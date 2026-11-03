@echo off
setlocal
for %%I in ("%~dp0.") do set "ROOT=%%~fI"
if not defined TMB_GODOT set "TMB_GODOT=E:\Godot_v4.7.2-stable_win64.exe"
if not exist "%TMB_GODOT%" (
  echo Missing official Godot 4.7.2 GUI executable: "%TMB_GODOT%"
  pause
  exit /b 2
)
set "PROFILE=%ROOT%\godot\outputs\an03_lab\gui_profile"
if not exist "%PROFILE%\Roaming" mkdir "%PROFILE%\Roaming"
if not exist "%PROFILE%\Local" mkdir "%PROFILE%\Local"
set "APPDATA=%PROFILE%\Roaming"
set "LOCALAPPDATA=%PROFILE%\Local"
"%TMB_GODOT%" --path "%ROOT%\godot" --resolution 1280x720 res://scenes/labs/an03_modular_rig_lab.tscn
set "RESULT=%ERRORLEVEL%"
if not "%RESULT%"=="0" pause
exit /b %RESULT%
