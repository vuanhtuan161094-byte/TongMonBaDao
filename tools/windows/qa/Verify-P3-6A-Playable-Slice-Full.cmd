@echo off
for %%I in ("%~dp0..\..\..") do set "TMB_ROOT=%%~fI\"
setlocal
cd /d "%TMB_ROOT%"

echo ========================================================
echo   TONG MON BA DAO - P3.6A PLAYABLE VERTICAL SLICE - FULL
echo ========================================================
echo.
echo Checks:
echo - cumulative P3.5 / P3.4 / P3.3 runtime baseline
echo - old demo task rail is removed from normal play
echo - bottom bar exposes only real usable entries
echo - 8 buildings have player-readable map tokens and real hit targets
echo - no P3/P2/P1/internal debug wording leaks into player-facing surfaces
echo - all building panels use player-facing copy
echo - disciple summary/deep tabs use player-facing copy
echo - a real Sect Master order advances simulation and moves visible destination
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%TMB_ROOT%tools\godot\Verify-P3-6A-Playable-Slice-Full.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if "%EXIT_CODE%"=="0" (
    echo P3.6A PLAYABLE VERTICAL SLICE FULL: PASS
) else (
    echo P3.6A PLAYABLE VERTICAL SLICE FULL: FAIL ^(exit %EXIT_CODE%^)
)

echo.
pause
exit /b %EXIT_CODE%
