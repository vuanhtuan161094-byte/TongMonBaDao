@echo off
setlocal
cd /d "%~dp0"

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
echo Use Verify-P3-6A-Playable-Slice-Full.cmd only for final/cross-baseline regression.
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\godot\Verify-P3-6A-Playable-Slice.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if "%EXIT_CODE%"=="0" (
    echo P3.6A PLAYABLE VERTICAL SLICE FAST: PASS
) else (
    echo P3.6A PLAYABLE VERTICAL SLICE FAST: FAIL ^(exit %EXIT_CODE%^)
)

echo.
pause
exit /b %EXIT_CODE%
