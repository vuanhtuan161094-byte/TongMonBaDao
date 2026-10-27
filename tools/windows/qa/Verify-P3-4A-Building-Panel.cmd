@echo off
for %%I in ("%~dp0..\..\..") do set "TMB_ROOT=%%~fI\"
setlocal
cd /d "%TMB_ROOT%"

echo ========================================================
echo   TONG MON BA DAO - P3.4A BUILDING OPERATION PANEL
echo ========================================================
echo.
echo Checks:
echo - cumulative P3.3 operational flow baseline
echo - 8 buildings open fixed right-side panel
echo - panel reads real SimulationState
echo - no dim/modal popup for routine building tap
echo - opening/reading building UI does not mutate simulation
echo - building -> disciple context switch remains clean
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%TMB_ROOT%tools\godot\Verify-P3-4A-Building-Panel.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if "%EXIT_CODE%"=="0" (
    echo P3.4A BUILDING OPERATION PANEL: PASS
) else (
    echo P3.4A BUILDING OPERATION PANEL: FAIL ^(exit %EXIT_CODE%^)
)

echo.
pause
exit /b %EXIT_CODE%
