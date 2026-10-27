@echo off
for %%I in ("%~dp0..\..\..") do set "TMB_ROOT=%%~fI\"
setlocal
cd /d "%TMB_ROOT%"

echo ========================================================
echo   TONG MON BA DAO - P3.7A1 BUILDING AUTHORITY FAST
echo ========================================================
echo.
echo Focused backend checks only. No presentation gate.
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%TMB_ROOT%tools\godot\Verify-P3-7A1-Building-Authority.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if "%EXIT_CODE%"=="0" (
    echo P3.7A1 BUILDING AUTHORITY FAST: PASS
) else (
    echo P3.7A1 BUILDING AUTHORITY FAST: FAIL ^(exit %EXIT_CODE%^)
)
echo.
pause
exit /b %EXIT_CODE%
