@echo off
setlocal EnableExtensions DisableDelayedExpansion
cd /d "%~dp0"
if not defined TMB_GODOT set "TMB_GODOT=E:\Godot_v4.7.2-stable_win64_console.exe"
if not exist "%TMB_GODOT%" (
  echo PVE_SAVE_FORENSICS_BLOCKED: official Godot 4.7.2 binary not found at "%TMB_GODOT%"
  exit /b 3
)
set "OUT_DIR=%~dp0godot\outputs\qa_pve_save_forensics_20261027\logs"
if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss_fff"') do set "RUN_STAMP=%%i"
for /f %%i in ('git -C "%~dp0." rev-parse HEAD') do set "EXACT_SHA=%%i"
set "ENGINE_LOG=%OUT_DIR%\save_forensics_%RUN_STAMP%_%EXACT_SHA%.godot.log"
echo PVE_SAVE_FORENSICS_START SHA=%EXACT_SHA%
echo PVE_SAVE_FORENSICS_LOG=%ENGINE_LOG%
"%TMB_GODOT%" --headless --path "%~dp0godot" --log-file "%ENGINE_LOG%" --script res://tests/simulation/pve_aux01_save_stage_differential_test.gd
set "QA_EXIT=%ERRORLEVEL%"
echo PVE_SAVE_FORENSICS_FINISH SHA=%EXACT_SHA% EXIT=%QA_EXIT%
if "%QA_EXIT%"=="0" echo QA test PASS. This is NOT live player GUI acceptance.
if "%QA_EXIT%"=="2" echo Confirmed or still unresolved SaveService/clock fixture FAIL: examine case rows and A/B controls.
if "%QA_EXIT%"=="1" echo Safety/schema/fixture QA gate FAIL. Do not merge.
if "%QA_EXIT%"=="3" echo CRITICAL: a pre-existing last-good primary may be at risk OR launcher Godot binary is missing. Diagnose before retry.
exit /b %QA_EXIT%
