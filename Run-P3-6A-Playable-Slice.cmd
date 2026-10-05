@echo off
setlocal EnableExtensions
cd /d "%~dp0"

echo ========================================================
echo   TONG MON BA DAO - P3.6A FAST CHECK + PREVIEW
echo ========================================================
echo.
echo Flow:
echo 1. Restore the canonical 42-PNG Stage A pack from tracked transport
echo 2. Run the P3.6A FAST gate only
echo 3. If PASS, open the real preview automatically
echo 4. If FAIL, stop without opening preview
echo.

set "P3_AUTO_PREVIEW=1"
set "STAGE_A_INSTALL_ONLY=1"
call "%~dp0Install-P3-2-Female-StageA.cmd"
set "STAGE_A_INSTALL_ONLY="
set "INSTALL_EXIT=%ERRORLEVEL%"

if not "%INSTALL_EXIT%"=="0" (
    set "P3_AUTO_PREVIEW="
    echo.
    echo [STOP] Stage A pack restore failed. Preview was not opened.
    exit /b %INSTALL_EXIT%
)

call "%~dp0Verify-P3-6A-Playable-Slice.cmd"
set "VERIFY_EXIT=%ERRORLEVEL%"

if not "%VERIFY_EXIT%"=="0" (
    set "P3_AUTO_PREVIEW="
    echo.
    echo [STOP] FAST gate failed. Preview was not opened.
    exit /b %VERIFY_EXIT%
)

echo.
echo [PASS] Canonical actor pack + FAST gate green. Opening preview...
echo.

set "P3_AUTO_PREVIEW="
call "%~dp0Preview-P3-6A-Playable-Slice.cmd"
exit /b %ERRORLEVEL%
