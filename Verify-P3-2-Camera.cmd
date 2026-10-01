@echo off
setlocal
cd /d "%~dp0"

echo ================================================
echo   TONG MON BA DAO - P3.2 CAMERA VERIFICATION
echo ================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\godot\Verify-P3-2-Camera.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if "%EXIT_CODE%"=="0" (
    echo P3.2 CAMERA GATE: PASS
) else (
    echo P3.2 CAMERA GATE: FAIL ^(exit %EXIT_CODE%^)
)

echo.
pause
exit /b %EXIT_CODE%
