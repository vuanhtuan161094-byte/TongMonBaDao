@echo off
setlocal
cd /d "%~dp0"

echo ========================================================
echo   TONG MON BA DAO - FEMALE STAGE A + MOTION FAST CHECK
echo ========================================================
echo.
echo FAST P3.2 check only:
echo - import changed Stage A assets
echo - Character Creator shared-rig contract
echo - down/front regression contract
echo - authored DOWN / RIGHT / UP asset contract
echo - authored direction sandbox smoke
echo - shared IDLE/WALK motion contract
echo - shared motion sandbox smoke
echo - live modular female map integration
echo.
echo It does NOT rerun P0-P2.12 on every art/pivot iteration.
echo Full cumulative verification is a separate final gate.
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\godot\Verify-P3-2-Female-StageA.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if "%EXIT_CODE%"=="0" (
    echo FEMALE STAGE A + SHARED MOTION FAST CHECK: PASS
) else (
    echo FEMALE STAGE A + SHARED MOTION FAST CHECK: FAIL ^(exit %EXIT_CODE%^)
)

echo.
pause
exit /b %EXIT_CODE%
