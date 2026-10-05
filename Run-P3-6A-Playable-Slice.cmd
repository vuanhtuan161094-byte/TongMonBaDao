@echo off
setlocal
cd /d "%~dp0"

echo ========================================================
echo   TONG MON BA DAO - P3.6A FAST CHECK + PREVIEW
echo ========================================================
echo.
echo Flow:
echo 1. Run P3.6A FAST gate only
echo 2. If PASS, open the real preview automatically
echo 3. If FAIL, stop without opening preview
echo.

call "%~dp0Verify-P3-6A-Playable-Slice.cmd"
set "VERIFY_EXIT=%ERRORLEVEL%"

if not "%VERIFY_EXIT%"=="0" (
    echo.
    echo [STOP] FAST gate failed. Preview was not opened.
    exit /b %VERIFY_EXIT%
)

echo.
echo [PASS] FAST gate green. Opening preview...
echo.

call "%~dp0Preview-P3-6A-Playable-Slice.cmd"
exit /b %ERRORLEVEL%
