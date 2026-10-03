@echo off
setlocal
cd /d "%~dp0"

echo ========================================================
echo   TONG MON BA DAO - FEMALE STAGE A FAST CHECK
echo ========================================================
echo.
echo FAST P3.2 check only:
echo - import changed Stage A assets
echo - Character Creator shared-rig contract
echo - Stage A asset contract
echo - Stage A sandbox smoke
echo.
echo It does NOT rerun P0-P2.12 on every art/pivot iteration.
echo Full cumulative verification is a separate final gate.
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\godot\Verify-P3-2-Female-StageA.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if "%EXIT_CODE%"=="0" (
    echo FEMALE STAGE A DOWN FAST CHECK: PASS
) else (
    echo FEMALE STAGE A DOWN FAST CHECK: FAIL ^(exit %EXIT_CODE%^)
)

echo.
pause
exit /b %EXIT_CODE%
