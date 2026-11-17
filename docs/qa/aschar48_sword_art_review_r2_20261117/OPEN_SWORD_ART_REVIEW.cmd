@echo off
setlocal
set "GODOT=E:\Godot_v4.7.2-stable_win64.exe"
if not exist "%GODOT%" (
  echo Godot 4.7.2 official was not found at %GODOT%
  pause
  exit /b 1
)
start "" "%GODOT%" --path "%~dp0" --resolution 1280x720
exit /b 0
