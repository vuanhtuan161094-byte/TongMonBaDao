@echo off
setlocal
cd /d "%~dp0"

echo ========================================================
echo   TONG MON BA DAO - CHARACTER CREATOR V1 VERIFY
echo ========================================================
echo.

echo This verifier runs the existing cumulative P3.2 camera/UI gate first.
echo It does NOT replace Sync-P3-2-Camera.cmd as the first Windows gate.
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\godot\Verify-P3-2-Character-Creator.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if "%EXIT_CODE%"=="0" (
    echo CHARACTER CREATOR V1 SCAFFOLD GATE: PASS
) else (
    echo CHARACTER CREATOR V1 SCAFFOLD GATE: FAIL ^(exit %EXIT_CODE%^)
)

echo.
pause
exit /b %EXIT_CODE%
