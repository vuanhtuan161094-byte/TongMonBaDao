@echo off
for %%I in ("%~dp0..\..\..") do set "TMB_ROOT=%%~fI\"
setlocal
set "TMB_GODOT=E:\Godot_v4.7.2-stable_win64_console.exe"
set "TMB_PROJECT=%TMB_ROOT%godot"
set "APPDATA=%TMB_ROOT%outputs\endgame_qa_20261026\userdata\launcher\Roaming"
set "LOCALAPPDATA=%TMB_ROOT%outputs\endgame_qa_20261026\userdata\launcher\Local"
if not exist "%APPDATA%" mkdir "%APPDATA%"
if not exist "%LOCALAPPDATA%" mkdir "%LOCALAPPDATA%"
if not exist "%TMB_GODOT%" (
  echo Godot official 4.7.2 was not found at "%TMB_GODOT%".
  echo Edit TMB_GODOT in this file to the installed official 4.7.2 console binary.
  exit /b 2
)
rem Optional: tools\windows\run\Run-Endgame-QA.cmd --tmb-roster=200 (or 500).
rem Requires a separately generated endgame_qa_save_200/500.json first.
rem The read-only 130 seed is cloned into a new, isolated writable QA save.
"%TMB_GODOT%" --path "%TMB_PROJECT%" --resolution 1280x720 --script res://tools/qa/endgame_live_launcher.gd -- %*
exit /b %errorlevel%
