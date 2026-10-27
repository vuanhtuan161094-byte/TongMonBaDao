@echo off
for %%I in ("%~dp0..\..\..") do set "TMB_ROOT=%%~fI\"
setlocal
cd /d "%TMB_ROOT%"

echo ================================================
echo   TONG MON BA DAO - P2.10 VERIFICATION
echo ================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%TMB_ROOT%tools\godot\Verify-P2-10.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if "%EXIT_CODE%"=="0" (
    echo P2.10 GATE: PASS
) else (
    echo P2.10 GATE: FAIL ^(exit %EXIT_CODE%^)
)

echo.
pause
exit /b %EXIT_CODE%
