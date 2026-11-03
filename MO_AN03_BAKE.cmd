@echo off
setlocal EnableExtensions
rem Actual GPU sprite bake of procedural technical guide; not owner's Shadow art.
for %%I in ("%~dp0.") do set "ROOT=%%~fI"
if not defined TMB_GODOT set "TMB_GODOT=E:\Godot_v4.7.2-stable_win64_console.exe"
if not exist "%TMB_GODOT%" (
  echo AN03_BAKE_BLOCKED: official Godot 4.7.2 console exe not found.
  exit /b 2
)
set "OUT=%ROOT%\godot\outputs\an03_lab"
set "PROFILE=%OUT%\bake_profile"
if not exist "%OUT%" mkdir "%OUT%"
if not exist "%PROFILE%\Roaming" mkdir "%PROFILE%\Roaming"
if not exist "%PROFILE%\Local" mkdir "%PROFILE%\Local"
set "APPDATA=%PROFILE%\Roaming"
set "LOCALAPPDATA=%PROFILE%\Local"
set "VERSION=%OUT%\bake_engine_%RANDOM%.log"
"%TMB_GODOT%" --version > "%VERSION%" 2>&1
findstr /C:"4.7.2.stable.official" "%VERSION%" >nul
if errorlevel 1 (
  echo AN03_BAKE_BLOCKED: requires official Godot 4.7.2.
  type "%VERSION%"
  exit /b 8
)
set "LOG=%OUT%\bake_%RANDOM%_%RANDOM%.log"
echo [AN03] Actual renderer bake. Source = procedural GUIDE model, not Shadow GLB.
"%TMB_GODOT%" --path "%ROOT%\godot" --resolution 1280x720 --script res://tests/presentation/an03_modular_rig_bake.gd > "%LOG%" 2>&1
if errorlevel 1 (
  echo AN03_BAKE_FAIL, inspect "%LOG%"
  exit /b 11
)
findstr /R /C:"^SCRIPT ERROR:" /C:"^ERROR:" "%LOG%" | findstr /V /C:"ERROR: Failed to read the root certificate store." >nul
if not errorlevel 1 (
  echo AN03_BAKE_FAIL: Godot reported script/runtime errors. Log "%LOG%"
  exit /b 13
)
findstr /C:"AN03_BAKE_GUIDE PASS" "%LOG%" >nul
if errorlevel 1 (
  echo AN03_BAKE_FAIL: no explicit PASS marker. Log "%LOG%"
  exit /b 12
)
echo AN03 TECHNICAL GUIDE BAKE PASS. Open "%OUT%\bake"
echo This is a geometry guide; no actual owner's character mesh was exported.
exit /b 0
