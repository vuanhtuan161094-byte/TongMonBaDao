@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\godot\Verify-P3-7A2-Spirit-Field-Full.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"
echo.
if "%EXIT_CODE%"=="0" (
    echo P3.7A2 SPIRIT FIELD FULL: PASS
) else (
    echo P3.7A2 SPIRIT FIELD FULL: FAIL ^(exit %EXIT_CODE%^)
)
echo.
pause
exit /b %EXIT_CODE%
