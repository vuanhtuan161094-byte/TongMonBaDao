@echo off
setlocal
cd /d "%~dp0"

echo ================================================
echo   TONG MON BA DAO - P2.12 VERIFICATION
echo ================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\godot\Verify-P2-12.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if "%EXIT_CODE%"=="0" (
    echo P2.12 GATE: PASS
) else (
    echo P2.12 GATE: FAIL ^(exit %EXIT_CODE%^)
)

echo.
pause
exit /b %EXIT_CODE%
