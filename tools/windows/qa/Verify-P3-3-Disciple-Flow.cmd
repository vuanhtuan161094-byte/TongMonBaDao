@echo off
for %%I in ("%~dp0..\..\..") do set "TMB_ROOT=%%~fI\"
setlocal
cd /d "%TMB_ROOT%"

echo ========================================================
echo   TONG MON BA DAO - P3.3 DISCIPLE OPERATIONAL FLOW
echo ========================================================
echo.
echo Checks:
echo - locked cumulative P3.2 camera + real disciple tabs baseline
echo - map disciple -> right operational summary
echo - quick orders use real WorkforceSystem
echo - Xem chi tiet -> real 6-tab deep screen
echo - roster switch + Back restore the correct map context
echo - direct bottom-nav deep entry returns to a clean map
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%TMB_ROOT%tools\godot\Verify-P3-3-Disciple-Flow.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if "%EXIT_CODE%"=="0" (
    echo P3.3 DISCIPLE OPERATIONAL FLOW: PASS
) else (
    echo P3.3 DISCIPLE OPERATIONAL FLOW: FAIL ^(exit %EXIT_CODE%^)
)

echo.
pause
exit /b %EXIT_CODE%
