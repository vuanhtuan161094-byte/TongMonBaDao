@echo off
for %%I in ("%~dp0..\..\..") do set "TMB_ROOT=%%~fI\"
setlocal
cd /d "%TMB_ROOT%"

echo ========================================================
echo   TONG MON BA DAO - P3.7A1 BUILDING AUTHORITY FULL
echo ========================================================
echo.
echo Full P0-P2.12 regression, then P3.7A1 backend contracts.
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%TMB_ROOT%tools\godot\Verify-P3-7A1-Building-Authority-Full.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if "%EXIT_CODE%"=="0" (
    echo P3.7A1 BUILDING AUTHORITY FULL: PASS
) else (
    echo P3.7A1 BUILDING AUTHORITY FULL: FAIL ^(exit %EXIT_CODE%^)
)
echo.
pause
exit /b %EXIT_CODE%
