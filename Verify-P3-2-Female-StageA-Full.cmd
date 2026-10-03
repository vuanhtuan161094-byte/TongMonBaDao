@echo off
setlocal
cd /d "%~dp0"

echo ========================================================
echo   TONG MON BA DAO - FEMALE STAGE A FULL GATE
echo ========================================================
echo.
echo FINAL ACCEPTANCE ONLY.
echo This reruns the complete cumulative chain before Stage A.
echo Use Verify-P3-2-Female-StageA.cmd for normal art/pivot iteration.
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\godot\Verify-P3-2-Female-StageA-Full.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if "%EXIT_CODE%"=="0" (
    echo FEMALE STAGE A DOWN FULL CUMULATIVE GATE: PASS
) else (
    echo FEMALE STAGE A DOWN FULL CUMULATIVE GATE: FAIL ^(exit %EXIT_CODE%^)
)

echo.
pause
exit /b %EXIT_CODE%
