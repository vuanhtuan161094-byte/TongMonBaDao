@echo off
setlocal
cd /d "%~dp0"

echo ================================================
echo   TONG MON BA DAO - P1.2 VERIFICATION
echo ================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\godot\Verify-P1-2.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if "%EXIT_CODE%"=="0" (
    echo P1.2 GATE: PASS
) else (
    echo P1.2 GATE: FAIL ^(exit %EXIT_CODE%^)
)

echo.
pause
exit /b %EXIT_CODE%
