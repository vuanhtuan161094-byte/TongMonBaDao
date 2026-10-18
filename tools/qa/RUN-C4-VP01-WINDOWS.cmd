@echo off
setlocal EnableExtensions
title Tong Mon Ba Dao - C4-VP01 Isolated Windows QA
cd /d "%~dp0"
echo ============================================================
echo TONG MON BA DAO - C4-VP01 / OFFICIAL GODOT 4.7.2
echo Fresh TEMP clone, isolated user data, focused tests only
echo No merge, no CI/FULL, no local source or save changes
echo ============================================================
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Run-C4-VP01-Windows.ps1" %*
set "QA_EXIT=%ERRORLEVEL%"
echo.
if "%QA_EXIT%"=="0" (
    echo Focused QA completed. Visual owner acceptance is still PENDING.
) else (
    echo BLOCKED OR FAILED. Inspect the TEMP evidence path shown above.
)
echo.
pause
exit /b %QA_EXIT%
