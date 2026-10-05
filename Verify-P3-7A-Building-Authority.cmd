@echo off
setlocal
cd /d "%~dp0"

echo ========================================================
echo   TONG MON BA DAO - P3.7A BUILDING AUTHORITY + MINE
echo ========================================================
echo.
echo FAST backend checks:
echo - P2.12 remains P3.7-disabled
echo - BuildingState + BuildingSystem persistence/invariants
echo - real timed Mine upgrade and real resource costs
echo - Mine worker slots use existing workforce assignment
echo - travel ^> mining ^> haul/deposit cycle
echo - profession XP only on completed mining batch
echo - exact save/load + deterministic continuation
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\godot\Verify-P3-7A-Building-Authority.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if "%EXIT_CODE%"=="0" (
    echo P3.7A BUILDING AUTHORITY + MINE FAST: PASS
) else (
    echo P3.7A BUILDING AUTHORITY + MINE FAST: FAIL ^(exit %EXIT_CODE%^)
)

echo.
pause
exit /b %EXIT_CODE%
