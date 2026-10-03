@echo off
setlocal
cd /d "%~dp0"

echo ========================================================
echo   TONG MON BA DAO - FEMALE STAGE A VERIFY
echo ========================================================
echo.

echo This verifier reruns the Character Creator cumulative chain first.
echo Stage A remains isolated from the live sect map.
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\godot\Verify-P3-2-Female-StageA.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if "%EXIT_CODE%"=="0" (
    echo FEMALE STAGE A DOWN PIVOT-LOCK GATE: PASS
) else (
    echo FEMALE STAGE A DOWN PIVOT-LOCK GATE: FAIL ^(exit %EXIT_CODE%^)
)

echo.
pause
exit /b %EXIT_CODE%
