@echo off
for %%I in ("%~dp0..\..\..") do set "TMB_ROOT=%%~fI\"
setlocal
cd /d "%TMB_ROOT%"

echo ========================================================
echo   TONG MON BA DAO - P3.6A PLAYABLE SLICE FAST
echo ========================================================
echo.
echo FAST checks only:
echo - parse current P3.6A presentation/test scripts
echo - P3.6A player-facing contract
echo - live main scene smoke
echo.
echo Locked P3.3-P3.5 baselines are NOT rerun here.
echo Use tools\windows\qa\Verify-P3-6A-Playable-Slice-Full.cmd only for final/cross-baseline regression.
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%TMB_ROOT%tools\godot\Verify-P3-6A-Playable-Slice.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if "%EXIT_CODE%"=="0" (
    echo P3.6A PLAYABLE VERTICAL SLICE FAST: PASS
) else (
    echo P3.6A PLAYABLE VERTICAL SLICE FAST: FAIL ^(exit %EXIT_CODE%^)
)

echo.
if /I not "%P3_AUTO_PREVIEW%"=="1" pause
exit /b %EXIT_CODE%
