@echo off
setlocal EnableExtensions
title Tong Mon Ba Dao - C4 PRES-01 Isolated Windows QA
cd /d "%~dp0"
echo ============================================================
echo TONG MON BA DAO - C4 PRES-01 / OFFICIAL GODOT 4.7.2
echo TEMP clone, isolated user data, focused tests + 6v5 GUI
echo No merge, no CI/FULL, no local source or saves modified
echo ============================================================
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Verify-C4-PRES01-Windows.ps1" -OpenVisual %*
set "QA_EXIT=%ERRORLEVEL%"
echo.
if "%QA_EXIT%"=="0" (
  echo All focused gate markers found. Visual OWNER acceptance is still PENDING.
) else (
  echo BLOCKED OR FAILED: inspect the printed TEMP folder.
)
echo.
pause
exit /b %QA_EXIT%
