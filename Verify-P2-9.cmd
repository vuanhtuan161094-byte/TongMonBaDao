@echo off
setlocal
cd /d "%~dp0"

echo ================================================
echo   TONG MON BA DAO - P2.9 VERIFICATION
echo ================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\godot\Verify-P2-9.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if "%EXIT_CODE%"=="0" (
    echo P2.9 GATE: PASS
) else (
    echo P2.9 GATE: FAIL ^(exit %EXIT_CODE%^)
)

echo.
pause
exit /b %EXIT_CODE%
