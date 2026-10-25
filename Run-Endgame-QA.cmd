@echo off
setlocal
set "TMB_GODOT=E:\Godot_v4.7.2-stable_win64_console.exe"
set "TMB_PROJECT=%~dp0godot"
if not exist "%TMB_GODOT%" (
  echo Godot official 4.7.2 was not found at "%TMB_GODOT%".
  echo Edit TMB_GODOT in this file to the installed official 4.7.2 console binary.
  exit /b 2
)
rem Optional: Run-Endgame-QA.cmd --tmb-roster=200 (or 500).
rem Requires a separately generated endgame_qa_save_200/500.json first.
rem The normal no-argument launcher still opens the original mutable 130 save.
"%TMB_GODOT%" --path "%TMB_PROJECT%" --resolution 1280x720 --script res://tools/qa/endgame_live_launcher.gd -- %*
exit /b %errorlevel%
