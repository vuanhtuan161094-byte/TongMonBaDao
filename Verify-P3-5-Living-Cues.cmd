@echo off
setlocal
cd /d "%~dp0"

echo ========================================================
echo   TONG MON BA DAO - P3.5 LIVING SECT CUES
echo ========================================================
echo.
echo Checks:
echo - cumulative full P3.4 building-management baseline
echo - resolver is read-only and uses real thresholds/state
echo - max 3 deterministic primary cues
echo - critical/actionable/operational ordering
echo - transient work/breakthrough/heal events do not spam
echo - hidden identity does not affect cue output
echo - live cue layer follows map targets
echo - cue tap routes to real P3.3/P3.4 context only
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\godot\Verify-P3-5-Living-Cues.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if "%EXIT_CODE%"=="0" (
    echo P3.5 LIVING SECT CUES: PASS
) else (
    echo P3.5 LIVING SECT CUES: FAIL ^(exit %EXIT_CODE%^)
)

echo.
pause
exit /b %EXIT_CODE%
