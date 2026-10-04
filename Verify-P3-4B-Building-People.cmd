@echo off
setlocal
cd /d "%~dp0"

echo ========================================================
echo   TONG MON BA DAO - P3.4B BUILDING PEOPLE MANAGEMENT
echo ========================================================
echo.
echo Checks:
echo - cumulative P3.4A building panel baseline
echo - Mine/Forge long-term group assignment uses WorkforceSystem
echo - Mine/Forge immediate work orders use real direct commands
echo - Cultivation/Residence/Gate use real direct commands
echo - presentation does not directly mutate current_action or region_id
echo - Medicine Hall does not expose a fake HEAL command
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\godot\Verify-P3-4B-Building-People.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if "%EXIT_CODE%"=="0" (
    echo P3.4B BUILDING PEOPLE MANAGEMENT: PASS
) else (
    echo P3.4B BUILDING PEOPLE MANAGEMENT: FAIL ^(exit %EXIT_CODE%^)
)

echo.
pause
exit /b %EXIT_CODE%
