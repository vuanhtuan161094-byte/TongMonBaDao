@echo off
setlocal EnableExtensions
rem AN-02.1 QA only, isolated APPDATA. /capture requires real Windows GUI.
for %%I in ("%~dp0..\..\..") do set "ROOT=%%~fI\"
if not defined TMB_GODOT set "TMB_GODOT=E:\Godot_v4.7.2-stable_win64_console.exe"
set "PROJECT=%ROOT%godot"
set "QA=%PROJECT%\outputs\an02_lab"
set "PROFILE=%QA%\qa_userdata"
set "LOGS=%QA%\qa_logs"
if not exist "%TMB_GODOT%" (
  echo AN02_QA_BLOCKED: official Godot 4.7.2 missing: "%TMB_GODOT%"
  exit /b 2
)
if not exist "%PROJECT%\project.godot" (
  echo AN02_QA_BLOCKED: project missing
  exit /b 3
)
where git >nul 2>nul
if errorlevel 1 (
  echo AN02_QA_BLOCKED: git missing
  exit /b 4
)
for /f %%I in ('git -C "%ROOT%." rev-parse HEAD') do set "EXACT_SHA=%%I"
if not defined EXACT_SHA (
  echo AN02_QA_BLOCKED: exact HEAD missing
  exit /b 5
)
if not exist "%PROFILE%\Roaming" mkdir "%PROFILE%\Roaming"
if not exist "%PROFILE%\Local" mkdir "%PROFILE%\Local"
if not exist "%LOGS%" mkdir "%LOGS%"
if not exist "%LOGS%" exit /b 6
set "APPDATA=%PROFILE%\Roaming"
set "LOCALAPPDATA=%PROFILE%\Local"
set "TAG=%RANDOM%_%RANDOM%"
set "IMPORT_LOG=%LOGS%\import_%TAG%.log"
set "FOCUSED_LOG=%LOGS%\focused_%TAG%.log"
set "GUI_LOG=%LOGS%\gui_%TAG%.log"
echo [AN02] Git exact SHA: %EXACT_SHA%
echo [AN02] Engine version:
"%TMB_GODOT%" --version
if errorlevel 1 exit /b 7
echo [AN02] Official engine import:
"%TMB_GODOT%" --headless --path "%PROJECT%" --editor --import > "%IMPORT_LOG%" 2>&1
if errorlevel 1 (
  echo AN02_IMPORT_FAIL: "%IMPORT_LOG%"
  exit /b 10
)
echo [AN02] Focused lab test:
"%TMB_GODOT%" --headless --path "%PROJECT%" --script res://tests/presentation/an02_animation_lab_contract_test.gd > "%FOCUSED_LOG%" 2>&1
if errorlevel 1 (
  echo AN02_FOCUSED_FAIL: "%FOCUSED_LOG%"
  exit /b 11
)
findstr /C:"AN02_ANIMATION_LAB_FOCUSED PASS" "%FOCUSED_LOG%" >nul
if errorlevel 1 (
  echo AN02_FOCUSED_FAIL: explicit PASS marker missing
  exit /b 12
)
echo [AN02] Official import + focused test PASS; SHA %EXACT_SHA%
if /I not "%~1"=="/capture" (
  echo [AN02] GUI capture not requested; use /capture.
  exit /b 0
)
echo [AN02] Capturing actual 1280x720 GUI:
"%TMB_GODOT%" --path "%PROJECT%" --resolution 1280x720 --script res://tests/presentation/an02_animation_gui_capture.gd > "%GUI_LOG%" 2>&1
if errorlevel 1 (
  echo AN02_GUI_FAIL: "%GUI_LOG%"
  exit /b 13
)
findstr /C:"AN02_GUI_CAPTURE PASS" "%GUI_LOG%" >nul
if errorlevel 1 (
  echo AN02_GUI_FAIL: explicit PASS marker missing
  exit /b 14
)
echo [AN02] Real screenshots: "%QA%\captures"
echo [AN02] ALL REQUESTED TESTS PASS on %EXACT_SHA%
exit /b 0
