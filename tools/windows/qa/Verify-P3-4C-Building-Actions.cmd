@echo off
for %%I in ("%~dp0..\..\..") do set "TMB_ROOT=%%~fI\"
setlocal
cd /d "%TMB_ROOT%"

echo ========================================================
echo   TONG MON BA DAO - P3.4C BUILDING SYSTEM ACTIONS
echo ========================================================
echo.
echo Checks:
echo - cumulative P3.4B people-management baseline
echo - Main Hall mutates real workforce/needs/equipment policies
echo - Residence expansion consumes real supplies and raises capacity
echo - Medicine Hall mutates real needs priority
echo - Forge consumes real materials/support and creates real storage item
echo - missing-material craft fails without creating an item
echo - Warehouse remains read-only in P3.4C baseline
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%TMB_ROOT%tools\godot\Verify-P3-4C-Building-Actions.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if "%EXIT_CODE%"=="0" (
    echo P3.4C BUILDING SYSTEM ACTIONS: PASS
) else (
    echo P3.4C BUILDING SYSTEM ACTIONS: FAIL ^(exit %EXIT_CODE%^)
)

echo.
pause
exit /b %EXIT_CODE%
