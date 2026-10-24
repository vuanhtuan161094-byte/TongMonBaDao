@echo off
setlocal
set "ROOT=%~dp0"
set "GODOT=%ROOT%engine\Godot_v4.7.2-stable_win64.exe"
if not exist "%GODOT%" if defined TMB_GODOT_EXE set "GODOT=%TMB_GODOT_EXE%"
if not exist "%GODOT%" set "GODOT=E:\Godot_v4.7.2-stable_win64.exe"
if not exist "%GODOT%" (
  echo Godot 4.7.2 was not found.
  echo Place it at E:\Godot_v4.7.2-stable_win64.exe or set TMB_GODOT_EXE.
  pause
  exit /b 2
)
if not exist "%ROOT%userdata\appdata" mkdir "%ROOT%userdata\appdata"
if not exist "%ROOT%userdata\localappdata" mkdir "%ROOT%userdata\localappdata"
if not exist "%ROOT%userdata\temp" mkdir "%ROOT%userdata\temp"
if not exist "%ROOT%logs" mkdir "%ROOT%logs"
set "APPDATA=%ROOT%userdata\appdata"
set "LOCALAPPDATA=%ROOT%userdata\localappdata"
set "TEMP=%ROOT%userdata\temp"
set "TMP=%TEMP%"
start "T?ng M?n B? ??o ? Packet B" "%GODOT%" --path "%ROOT%godot" --resolution 1280x720 --windowed --log-file "%ROOT%logs\playable.log" %*
