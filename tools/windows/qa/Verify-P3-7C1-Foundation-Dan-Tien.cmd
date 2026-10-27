@echo off
for %%I in ("%~dp0..\..\..") do set "TMB_ROOT=%%~fI\"
setlocal
cd /d "%TMB_ROOT%"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%TMB_ROOT%tools\godot\Verify-P3-7C1-Foundation-Dan-Tien.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"
echo.
if "%EXIT_CODE%"=="0" (
    echo P3.7C1 FOUNDATION + DAN TIEN FAST: PASS
) else (
    echo P3.7C1 FOUNDATION + DAN TIEN FAST: FAIL ^(exit %EXIT_CODE%^)
)
echo.
pause
exit /b %EXIT_CODE%
