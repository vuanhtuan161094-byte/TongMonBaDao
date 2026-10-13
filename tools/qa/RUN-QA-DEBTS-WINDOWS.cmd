@echo off
setlocal EnableExtensions EnableDelayedExpansion
rem TONG MON BA DAO - one-file Windows QA debt collector.
rem Does NOT edit game source, sync Git, reset save, or claim Android/manual PASS.
rem Requires Godot 4.7.2 official and a local, correctly populated game checkout.

for %%I in ("%~dp0..\..") do set "ROOT=%%~fI"
set "PROJECT=%ROOT%\godot"
set "GODOT=%GODOT_BIN%"
if not defined GODOT set "GODOT=E:\Godot_v4.7.2-stable_win64_console.exe"

echo ===============================================
echo TONG MON BA DAO - WINDOWS QA DEBT COLLECTOR
echo ===============================================
echo Game root: "%ROOT%"
echo Godot:     "%GODOT%"
echo.

if not exist "%PROJECT%\project.godot" (
    echo [BLOCKED] Missing project.godot. Run from the GitHub game checkout.
    goto :early_stop
)
if not exist "%GODOT%" (
    echo [BLOCKED] Godot 4.7.2 console not found.
    echo Set GODOT_BIN to its exact path, or use the expected E: path.
    goto :early_stop
)
where powershell.exe >nul 2>nul
if errorlevel 1 (
    echo [BLOCKED] Windows PowerShell is required by the official FULL gate.
    goto :early_stop
)
where git.exe >nul 2>nul
if errorlevel 1 (
    echo [BLOCKED] Git not found. Cannot record a reproducible SHA.
    goto :early_stop
)

for /f "delims=" %%S in ('powershell.exe -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "STAMP=%%S"
if not defined STAMP (
    echo [BLOCKED] Cannot create a timestamp.
    goto :early_stop
)
set "OUT=%ROOT%\QA_DEBT_RESULTS\%STAMP%"
if not exist "%OUT%" mkdir "%OUT%"
if not exist "%OUT%" (
    echo [BLOCKED] Cannot create output folder.
    goto :early_stop
)
set "SUMMARY=%OUT%\SUMMARY.txt"
set /a PASSED=0
set /a FAILED=0
set /a BLOCKED=0

echo TONG MON BA DAO QA DEBT RUN > "%SUMMARY%"
echo. >> "%SUMMARY%"
echo Root: %ROOT% >> "%SUMMARY%"
echo Start: %STAMP% >> "%SUMMARY%"
echo Runner: tools/qa/RUN-QA-DEBTS-WINDOWS.cmd >> "%SUMMARY%"
echo. >> "%SUMMARY%"

for /f "delims=" %%B in ('git -C "%ROOT%" branch --show-current 2^>nul') do set "BRANCH=%%B"
for /f "delims=" %%H in ('git -C "%ROOT%" rev-parse HEAD 2^>nul') do set "HEADSHA=%%H"
if not defined HEADSHA (
    echo [BLOCKED] Not a Git repository.
    echo [BLOCKED] Not a Git repository. >> "%SUMMARY%"
    goto :finish
)
echo Branch: !BRANCH! >> "%SUMMARY%"
echo SHA: !HEADSHA! >> "%SUMMARY%"
git -C "%ROOT%" status --short > "%OUT%\git-status.txt" 2>&1
echo Branch: !BRANCH!   SHA: !HEADSHA!
if /I not "!BRANCH!"=="main" (
    echo [BLOCKED] Not on main. No tests launched.
    echo [BLOCKED] Not on main. >> "%SUMMARY%"
    goto :finish
)
"%GODOT%" --version > "%OUT%\godot-version.log" 2>&1
findstr /L /C:"4.7.2.stable.official" "%OUT%\godot-version.log" >nul
if errorlevel 1 (
    echo [BLOCKED] Godot official version 4.7.2 not confirmed.
    type "%OUT%\godot-version.log"
    echo [BLOCKED] Godot official version 4.7.2 not confirmed. >> "%SUMMARY%"
    goto :finish
)
type "%OUT%\godot-version.log"
type "%OUT%\godot-version.log" >> "%SUMMARY%"
echo.

echo [0] Import all game resources. See 00_import.log
"%GODOT%" --headless --path "%PROJECT%" --import > "%OUT%\00_import.log" 2>&1
set "IMPORT_EXIT=!ERRORLEVEL!"
if not "!IMPORT_EXIT!"=="0" (
    echo [BLOCKED] Project import failed with exit code !IMPORT_EXIT!.
    echo [BLOCKED] Import, exit=!IMPORT_EXIT! >> "%SUMMARY%"
    goto :finish
)
echo [PASS] Project import
echo [PASS] Project import >> "%SUMMARY%"

call :test "01_gp02c1_sim" "res://tests/simulation/gp_02c1_injury_settlement_test.gd" "GP-02C1 T01-T23 FOCUSED TERMINAL/RECOVERY/COMPATIBILITY PASS"
call :test "02_gp02c1_ui" "res://tests/presentation/gp_02c1_injury_presentation_test.gd" "GP-02C1 V2 REAL INJURY PRESENTATION PASS"
call :test "03_o6_m1" "res://tests/presentation/p3_o6_m1_release_rehearsal_test.gd" "P3 O6 M1 END-TO-END RELEASE REHEARSAL PASS"
call :test "04_o5_spend" "res://tests/presentation/p3_o5_real_consumption_loop_test.gd" "P3 O5 REAL PRODUCE-SPEND LOOP TEST PASS"

echo [5] FULL P3.7 cumulative chain...
set "FULLFILE=%ROOT%\tools\godot\Verify-P3-7C1-Foundation-Dan-Tien-Full.ps1"
if not exist "%FULLFILE%" (
    echo [BLOCKED] Missing FULL gate script.
    echo [BLOCKED] FULL gate script missing >> "%SUMMARY%"
    set /a BLOCKED+=1
) else (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%FULLFILE%" -GodotBin "%GODOT%" > "%OUT%\05_p37_full.log" 2>&1
    set "RC=!ERRORLEVEL!"
    if "!RC!"=="0" (
        findstr /L /C:"P3.7C1 FOUNDATION + DAN TIEN FULL GATE: PASS" "%OUT%\05_p37_full.log" >nul
        if !ERRORLEVEL! EQU 0 (
            echo [PASS] P3.7 FULL
            echo [PASS] P3.7 FULL >> "%SUMMARY%"
            set /a PASSED+=1
        ) else (
            echo [FAIL] P3.7 FULL: PASS marker not found
            echo [FAIL] P3.7 FULL, marker missing >> "%SUMMARY%"
            set /a FAILED+=1
        )
    ) else (
        echo [FAIL] P3.7 FULL exit=!RC!
        echo [FAIL] P3.7 FULL exit=!RC! >> "%SUMMARY%"
        set /a FAILED+=1
    )
)
goto :finish

:test
set "TESTID=%~1"
set "TARGET=%~2"
set "MARKER=%~3"
echo [TEST] !TESTID!
"%GODOT%" --headless --path "%PROJECT%" -s "!TARGET!" > "%OUT%\!TESTID!.log" 2>&1
set "RC=!ERRORLEVEL!"
if "!RC!"=="0" (
    findstr /L /C:"!MARKER!" "%OUT%\!TESTID!.log" >nul
    if !ERRORLEVEL! EQU 0 (
        echo [PASS] !TESTID!
        echo [PASS] !TESTID! >> "%SUMMARY%"
        set /a PASSED+=1
        exit /b 0
    )
)
echo [FAIL] !TESTID! exit=!RC! or PASS marker missing
echo [FAIL] !TESTID! exit=!RC! or PASS marker missing >> "%SUMMARY%"
set /a FAILED+=1
exit /b 1

:finish
echo. >> "%SUMMARY%"
echo PASSED=!PASSED! FAILED=!FAILED! BLOCKED=!BLOCKED! >> "%SUMMARY%"
echo. >> "%SUMMARY%"
echo STILL PENDING - NOT VERIFIED BY THIS PC RUN: >> "%SUMMARY%"
echo - Windows real GUI/visual screenshots and manual injury gamefeel >> "%SUMMARY%"
echo - Android real-device touch, offline, app kill, storage-full/power failure >> "%SUMMARY%"
echo - ENV02A lab requires owner ZIP/35 PNGs and manual Windows/Android visual tests >> "%SUMMARY%"
echo - 100/500/1000/3000-disciple scalability benchmark on target hardware >> "%SUMMARY%"
echo - P3.6A external screenshot artifact/quota delivery >> "%SUMMARY%"
echo - Baseline A/B investigation if O6 is still FAIL; never weaken the assertion >> "%SUMMARY%"
echo - Backend/occupation/production/economy redesign needs separate design approval >> "%SUMMARY%"
echo. 
echo ===============================================
echo WINDOWS QA: PASSED=!PASSED! FAILED=!FAILED! BLOCKED=!BLOCKED!
echo Evidence: "%OUT%"
echo ===============================================
type "%SUMMARY%"
echo.
if !FAILED! GTR 0 goto :failed
if !BLOCKED! GTR 0 goto :failed
echo Automated gates finished. Physical/manual/design debts remain PENDING.
pause
exit /b 0

:failed
echo [ACTION] Collect SUMMARY.txt plus failing *.log for next chat.
pause
exit /b 1

:early_stop
echo No tests were run. No PASS claim.
pause
exit /b 2
