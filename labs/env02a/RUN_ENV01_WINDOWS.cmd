@echo off
setlocal EnableExtensions DisableDelayedExpansion
title TMB ENV-01 - Windows QA
set "PROJECT=%~dp0"
set "RESULTS=%PROJECT%ENV01_TEST_RESULTS"
set "GODOT=E:\Godot_v4.7.2-stable_win64_console.exe"
if not "%~1"=="" set "GODOT=%~1"
set "RC=0"

echo.
echo ================================================================
echo  TONG MON BA DAO - ENV-01 Windows QA - fixed launcher
echo ================================================================
echo Project: "%PROJECT%"
echo Godot:   "%GODOT%"
echo.

if not exist "%PROJECT%project.godot" (
    echo [FAIL] project.godot is missing in this directory.
    set "RC=2"
    goto :finish
)
if not exist "%RESULTS%\" mkdir "%RESULTS%"
if not exist "%RESULTS%\" (
    echo [FAIL] Cannot create ENV01_TEST_RESULTS; check write permission.
    set "RC=2"
    goto :finish
)

> "%RESULTS%\launcher.log" echo ENV-01 Windows diagnostic launcher
>>"%RESULTS%\launcher.log" echo Project: "%PROJECT%"
>>"%RESULTS%\launcher.log" echo Godot: "%GODOT%"

if not exist "%GODOT%" (
    echo [BLOCKED] Godot executable not found at:
    echo    "%GODOT%"
    echo Use Godot 4.7.2 console executable, or run this CMD with its path
    echo as the first argument. No project data was changed.
    >>"%RESULTS%\launcher.log" echo BLOCKED: GODOT_NOT_FOUND
    set "RC=2"
    goto :finish
)

"%GODOT%" --version > "%RESULTS%\godot_version.log" 2>&1
if errorlevel 1 (
    echo [FAIL] Godot could not start. Check godot_version.log.
    type "%RESULTS%\godot_version.log"
    >>"%RESULTS%\launcher.log" echo FAIL: GODOT_START_FAILED
    set "RC=2"
    goto :finish
)
findstr /C:"4.7.2" "%RESULTS%\godot_version.log" >nul
if errorlevel 1 (
    echo [BLOCKED] This QA requires Godot 4.7.2. Detected:
    type "%RESULTS%\godot_version.log"
    >>"%RESULTS%\launcher.log" echo BLOCKED: GODOT_WRONG_VERSION
    set "RC=2"
    goto :finish
)

echo [1/3] Import resources. Please check import.log on error...
"%GODOT%" --headless --path "%PROJECT%." --editor --import > "%RESULTS%\import.log" 2>&1
set "STEP_RC=%ERRORLEVEL%"
>>"%RESULTS%\launcher.log" echo IMPORT_EXIT=%STEP_RC%
if not "%STEP_RC%"=="0" (
    echo [FAIL] Import exited with code %STEP_RC%.
    type "%RESULTS%\import.log"
    set "RC=3"
    goto :finish
)
findstr /i /C:"SCRIPT ERROR" /C:"Parse Error" /C:"ERROR: " "%RESULTS%\import.log" >nul
if not errorlevel 1 (
    echo [FAIL] Godot import reports errors despite exit code 0.
    type "%RESULTS%\import.log"
    >>"%RESULTS%\launcher.log" echo FAIL: IMPORT_LOG_ERRORS
    set "RC=3"
    goto :finish
)
echo [PASS] Resource import.

echo [2/3] Validate ENV-01 structure...
"%GODOT%" --headless --path "%PROJECT%." -- --env01-verify > "%RESULTS%\env01_structure.log" 2>&1
set "STEP_RC=%ERRORLEVEL%"
>>"%RESULTS%\launcher.log" echo STRUCTURE_EXIT=%STEP_RC%
if not "%STEP_RC%"=="0" (
    echo [FAIL] Structure check exited with code %STEP_RC%.
    type "%RESULTS%\env01_structure.log"
    set "RC=4"
    goto :finish
)
findstr /C:"ENV01_RESULT PASS_STRUCTURE" "%RESULTS%\env01_structure.log" >nul
if errorlevel 1 (
    echo [FAIL] PASS_STRUCTURE marker was not found.
    type "%RESULTS%\env01_structure.log"
    >>"%RESULTS%\launcher.log" echo FAIL: STRUCTURE_MARKER_MISSING
    set "RC=5"
    goto :finish
)
findstr /i /C:"SCRIPT ERROR" /C:"Parse Error" /C:"ERROR: " "%RESULTS%\env01_structure.log" >nul
if not errorlevel 1 (
    echo [FAIL] Errors were detected in structure log.
    type "%RESULTS%\env01_structure.log"
    >>"%RESULTS%\launcher.log" echo FAIL: STRUCTURE_LOG_ERRORS
    set "RC=5"
    goto :finish
)
echo [PASS_STRUCTURE] Imported assets and model checks passed.

echo [3/3] Opening Godot scene (1280 x 720)...
echo After inspecting the scene, close the Godot window to return here.
"%GODOT%" --path "%PROJECT%." > "%RESULTS%\interactive.log" 2>&1
set "STEP_RC=%ERRORLEVEL%"
>>"%RESULTS%\launcher.log" echo INTERACTIVE_EXIT=%STEP_RC%
if not "%STEP_RC%"=="0" (
    echo [FAIL] GUI exited with code %STEP_RC%.
    type "%RESULTS%\interactive.log"
    set "RC=6"
    goto :finish
)
findstr /i /C:"SCRIPT ERROR" /C:"Parse Error" /C:"ERROR: " "%RESULTS%\interactive.log" >nul
if not errorlevel 1 (
    echo [FAIL] GUI log reports errors.
    type "%RESULTS%\interactive.log"
    >>"%RESULTS%\launcher.log" echo FAIL: GUI_LOG_ERRORS
    set "RC=6"
    goto :finish
)

echo [PASS] No launcher/runtime error reported. Visual QA still needs
echo a genuine screenshot and owner inspection; not OWNER VISUAL PASS.
>>"%RESULTS%\launcher.log" echo RUN_COMPLETED; VISUAL_ACCEPTANCE=PENDING

:finish
echo.
echo ================================================================
echo Exit code: %RC%
if exist "%RESULTS%\" echo Logs: "%RESULTS%"
echo ================================================================
if not "%RC%"=="0" (
    echo If it fails, send launcher.log, import.log and env01_structure.log
    echo that exist under ENV01_TEST_RESULTS.
) else (
    echo Send import.log, env01_structure.log and a real Godot screenshot.
)
echo Press any key to CLOSE THIS CONSOLE.
pause >nul
exit /b %RC%