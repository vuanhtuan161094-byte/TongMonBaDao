@echo off
setlocal EnableExtensions DisableDelayedExpansion
title TMB ENV-02A - Windows QA
set "PROJECT_ROOT=%~dp0"
set "PROJECT_GODOT=%~dp0."
set "RESULTS=%PROJECT_ROOT%ENV02A_TEST_RESULTS"
set "GODOT=E:\Godot_v4.7.2-stable_win64_console.exe"
if not "%~1"=="" set "GODOT=%~1"
set "RC=0"

echo.
echo ===============================================================
echo TONG MON BA DAO - ENV-02A 192x192 isolated Windows QA
echo ===============================================================
echo Project: "%PROJECT_GODOT%"
echo Godot:   "%GODOT%"
echo.
if not exist "%PROJECT_ROOT%project.godot" (
 echo [FAIL] Missing project.godot. Extract the complete ZIP first.
 set "RC=2"
 goto :finish
)
if not exist "%RESULTS%\" mkdir "%RESULTS%"
if not exist "%RESULTS%\" (
 echo [FAIL] Cannot make test output folder.
 set "RC=2"
 goto :finish
)
> "%RESULTS%\launcher.log" echo ENV02A Windows launcher diagnostic
>>"%RESULTS%\launcher.log" echo Project="%PROJECT_GODOT%"
>>"%RESULTS%\launcher.log" echo Godot="%GODOT%"
if not exist "%GODOT%" (
 echo [BLOCKED] Godot exe not found at "%GODOT%"
 echo You can drag your Godot console exe onto this CMD as an argument.
 >>"%RESULTS%\launcher.log" echo BLOCKED GODOT_MISSING
 set "RC=2"
 goto :finish
)
"%GODOT%" --version > "%RESULTS%\godot_version.log" 2>&1
if errorlevel 1 (
 echo [FAIL] Cannot start Godot. See godot_version.log
 set "RC=2"
 goto :finish
)
findstr /C:"4.7.2" "%RESULTS%\godot_version.log" >nul
if errorlevel 1 (
 echo [BLOCKED] Godot 4.7.2 is required.
 type "%RESULTS%\godot_version.log"
 set "RC=2"
 goto :finish
)

echo [1/4] Importing resources...
"%GODOT%" --headless --path "%PROJECT_GODOT%" --editor --import > "%RESULTS%\import.log" 2>&1
set "STEP_RC=%ERRORLEVEL%"
>>"%RESULTS%\launcher.log" echo IMPORT_EXIT=%STEP_RC%
if not "%STEP_RC%"=="0" (
 echo [FAIL] Import process exit %STEP_RC%.
 type "%RESULTS%\import.log"
 set "RC=3"
 goto :finish
)
findstr /i /C:"SCRIPT ERROR" /C:"Parse Error" /C:"ERROR: " "%RESULTS%\import.log" >nul
if not errorlevel 1 (
 echo [FAIL] Godot import errors. See import.log.
 type "%RESULTS%\import.log"
 set "RC=3"
 goto :finish
)
echo [PASS] Resource import.

echo [2/4] ENV-01 legacy 20x13 regression scene...
"%GODOT%" --headless --path "%PROJECT_GODOT%" "res://scenes/pv01_three_buildings.tscn" -- --env01-verify > "%RESULTS%\env01_regression.log" 2>&1
set "STEP_RC=%ERRORLEVEL%"
>>"%RESULTS%\launcher.log" echo LEGACY_EXIT=%STEP_RC%
if not "%STEP_RC%"=="0" (
 echo [FAIL] Legacy regression exit %STEP_RC%.
 type "%RESULTS%\env01_regression.log"
 set "RC=4"
 goto :finish
)
findstr /C:"ENV01_RESULT PASS_STRUCTURE" "%RESULTS%\env01_regression.log" >nul
if errorlevel 1 (
 echo [FAIL] Missing ENV01_RESULT PASS_STRUCTURE marker.
 type "%RESULTS%\env01_regression.log"
 set "RC=4"
 goto :finish
)
findstr /i /C:"SCRIPT ERROR" /C:"Parse Error" /C:"ERROR: " "%RESULTS%\env01_regression.log" >nul
if not errorlevel 1 (
 echo [FAIL] Legacy scene logged errors.
 type "%RESULTS%\env01_regression.log"
 set "RC=4"
 goto :finish
)
echo [PASS] Legacy ENV-01.

echo [3/4] Large-world model, camera, chunk, roads, assets...
"%GODOT%" --headless --path "%PROJECT_GODOT%" "res://scenes/env02a_large_world.tscn" -- --env02-verify > "%RESULTS%\env02_structure.log" 2>&1
set "STEP_RC=%ERRORLEVEL%"
>>"%RESULTS%\launcher.log" echo ENV02_EXIT=%STEP_RC%
if not "%STEP_RC%"=="0" (
 echo [FAIL] ENV02 verification exit %STEP_RC%.
 type "%RESULTS%\env02_structure.log"
 set "RC=5"
 goto :finish
)
findstr /C:"ENV02A_RESULT PASS_STRUCTURE" "%RESULTS%\env02_structure.log" >nul
if errorlevel 1 (
 echo [FAIL] Missing ENV02A_RESULT PASS_STRUCTURE marker.
 type "%RESULTS%\env02_structure.log"
 set "RC=5"
 goto :finish
)
findstr /i /C:"SCRIPT ERROR" /C:"Parse Error" /C:"ERROR: " "%RESULTS%\env02_structure.log" >nul
if not errorlevel 1 (
 echo [FAIL] ENV02 verification logged errors.
 type "%RESULTS%\env02_structure.log"
 set "RC=5"
 goto :finish
)
echo [PASS] ENV-02A structural test.

echo [4/4] Opening real 1280x720 Godot Windows map...
echo Right-drag/wheel on PC, swipe/pinch on Android after APK test.
echo Take screenshots at center, far corner and zoomed map.
echo Close the Godot window when finished to see final CMD result.
"%GODOT%" --path "%PROJECT_GODOT%" "res://scenes/env02a_large_world.tscn" > "%RESULTS%\interactive.log" 2>&1
set "STEP_RC=%ERRORLEVEL%"
>>"%RESULTS%\launcher.log" echo INTERACTIVE_EXIT=%STEP_RC%
if not "%STEP_RC%"=="0" (
 echo [FAIL] Interactive scene exit %STEP_RC%.
 type "%RESULTS%\interactive.log"
 set "RC=6"
 goto :finish
)
findstr /i /C:"SCRIPT ERROR" /C:"Parse Error" /C:"ERROR: " "%RESULTS%\interactive.log" >nul
if not errorlevel 1 (
 echo [FAIL] Interactive scene logged errors.
 type "%RESULTS%\interactive.log"
 set "RC=6"
 goto :finish
)
echo [PASS] Windows launch logs clean, visual/user acceptance PENDING.
>>"%RESULTS%\launcher.log" echo WINDOWS_LOGS_CLEAN; VISUAL_APPROVAL=PENDING; ANDROID=PENDING
:finish
echo.
echo ===============================================================
echo Exit code: %RC%
if exist "%RESULTS%\" echo Logs: "%RESULTS%"
echo ===============================================================
echo Send import.log, env01_regression.log, env02_structure.log,
echo interactive.log, and two real Windows screenshots to ChatGPT.
echo Press any key to CLOSE this window.
pause >nul
exit /b %RC%