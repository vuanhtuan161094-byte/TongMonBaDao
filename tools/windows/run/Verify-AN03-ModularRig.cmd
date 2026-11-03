@echo off
setlocal EnableExtensions
rem Isolated technical AN-03 Skeleton3D / weapon-socket QA. Never runs main game.
for %%I in ("%~dp0..\..\..") do set "ROOT=%%~fI\"
if not defined TMB_GODOT set "TMB_GODOT=E:\Godot_v4.7.2-stable_win64_console.exe"
set "PROJECT=%ROOT%godot"
set "QA=%PROJECT%\outputs\an03_lab"
set "PROFILE=%QA%\isolated_profile"
set "LOGS=%QA%\qa_logs"
if not exist "%TMB_GODOT%" (
  echo AN03_BLOCKED: official Godot 4.7.2 executable missing: "%TMB_GODOT%"
  exit /b 2
)
if not exist "%PROJECT%\project.godot" (
  echo AN03_BLOCKED: project.godot missing
  exit /b 3
)
where git >nul 2>nul
if errorlevel 1 (
  echo AN03_BLOCKED: git missing
  exit /b 4
)
for /f %%I in ('git -C "%ROOT%." rev-parse HEAD') do set "HEAD=%%I"
if not defined HEAD exit /b 5
if not exist "%PROFILE%\Roaming" mkdir "%PROFILE%\Roaming"
if not exist "%PROFILE%\Local" mkdir "%PROFILE%\Local"
if not exist "%LOGS%" mkdir "%LOGS%"
if not exist "%LOGS%" exit /b 6
set "APPDATA=%PROFILE%\Roaming"
set "LOCALAPPDATA=%PROFILE%\Local"
set "TAG=%RANDOM%_%RANDOM%"
set "VERSION_LOG=%LOGS%\engine_%TAG%.log"
set "IMPORT_LOG=%LOGS%\import_%TAG%.log"
set "FOCUSED_LOG=%LOGS%\focused_%TAG%.log"
set "GUI_LOG=%LOGS%\gui_%TAG%.log"
echo [AN03] Source SHA: %HEAD%
"%TMB_GODOT%" --version > "%VERSION_LOG%" 2>&1
if errorlevel 1 exit /b 7
type "%VERSION_LOG%"
findstr /C:"4.7.2.stable.official" "%VERSION_LOG%" >nul
if errorlevel 1 (
  echo AN03_BLOCKED: require exact Godot 4.7.2 stable official
  exit /b 8
)
echo [AN03] IMPORT / PARSE
"%TMB_GODOT%" --headless --path "%PROJECT%" --editor --import > "%IMPORT_LOG%" 2>&1
if errorlevel 1 (
  echo AN03_IMPORT_FAIL -- see "%IMPORT_LOG%"
  exit /b 10
)
findstr /R /C:"^SCRIPT ERROR:" /C:"^ERROR:" "%IMPORT_LOG%" | findstr /V /C:"ERROR: Failed to read the root certificate store." >nul
if not errorlevel 1 (
  echo AN03_IMPORT_LOG_ERRORS: Godot reported script/import errors despite exit 0
  echo Inspect "%IMPORT_LOG%"
  exit /b 15
)
echo [AN03] FOCUSED SKELETON / MOTION / WEAPON SOCKET
"%TMB_GODOT%" --headless --path "%PROJECT%" --script res://tests/presentation/an03_modular_rig_contract_test.gd > "%FOCUSED_LOG%" 2>&1
if errorlevel 1 (
  echo AN03_FOCUSED_FAIL -- see "%FOCUSED_LOG%"
  exit /b 11
)
findstr /C:"AN03_MODULAR_RIG_FOCUSED PASS" "%FOCUSED_LOG%" >nul
if errorlevel 1 (
  echo AN03_FOCUSED_FAIL: explicit PASS marker missing -- "%FOCUSED_LOG%"
  exit /b 12
)
findstr /R /C:"^SCRIPT ERROR:" /C:"^ERROR:" "%FOCUSED_LOG%" | findstr /V /C:"ERROR: Failed to read the root certificate store." >nul
if not errorlevel 1 (
  echo AN03_FOCUSED_LOG_ERRORS -- inspect "%FOCUSED_LOG%"
  exit /b 16
)
echo [AN03] Official import + focused PASS for procedural guide at %HEAD%
if /I not "%~1"=="/capture" (
  echo [AN03] GUI capture PENDING. Use /capture in actual Windows desktop session.
  exit /b 0
)
echo [AN03] Genuine 1280x720 framebuffer capture:
"%TMB_GODOT%" --path "%PROJECT%" --resolution 1280x720 --script res://tests/presentation/an03_modular_rig_gui_capture.gd > "%GUI_LOG%" 2>&1
if errorlevel 1 (
  echo AN03_GUI_FAIL -- see "%GUI_LOG%"
  exit /b 13
)
findstr /C:"AN03_GUI_CAPTURE PASS" "%GUI_LOG%" >nul
if errorlevel 1 (
  echo AN03_GUI_FAIL: explicit PASS marker missing -- "%GUI_LOG%"
  exit /b 14
)
findstr /R /C:"^SCRIPT ERROR:" /C:"^ERROR:" "%GUI_LOG%" | findstr /V /C:"ERROR: Failed to read the root certificate store." >nul
if not errorlevel 1 (
  echo AN03_GUI_LOG_ERRORS -- inspect "%GUI_LOG%"
  exit /b 17
)
echo [AN03] GUI screenshots: "%QA%\captures"
echo [AN03] TECHNICAL PROTOTYPE PASS at %HEAD%. Owner Shadow art remains BLOCKED_BY_MODEL.
exit /b 0
