@echo off
setlocal EnableExtensions
cd /d "%~dp0"

echo ========================================================
echo   TONG MON BA DAO - SYNC + P3.4A BUILDING PANEL
echo ========================================================
echo.

where git >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Git was not found in PATH.
    goto :fail
)

git rev-parse --is-inside-work-tree >nul 2>nul
if errorlevel 1 (
    echo [ERROR] This folder is not a Git repository.
    goto :fail
)

for /f "delims=" %%B in ('git branch --show-current') do set "BRANCH=%%B"
if /I not "%BRANCH%"=="main" (
    echo [ERROR] Current branch is "%BRANCH%". Expected "main".
    goto :fail
)

set "DIRTY="
for /f "delims=" %%S in ('git status --porcelain') do set "DIRTY=1"
if defined DIRTY (
    echo [STOP] Local changes detected. Sync was NOT performed to avoid overwriting your work.
    echo.
    git status --short
    goto :fail
)

echo [1/3] Fetching origin/main...
git fetch origin main
if errorlevel 1 goto :gitfail

echo [2/3] Updating local main with fast-forward only...
git pull --ff-only origin main
if errorlevel 1 goto :gitfail

echo [3/3] Running P3.4A building operation panel verification...
call "%~dp0Verify-P3-4A-Building-Panel.cmd"
set "VERIFY_EXIT=%ERRORLEVEL%"
if not "%VERIFY_EXIT%"=="0" exit /b %VERIFY_EXIT%

exit /b 0

:gitfail
echo.
echo [ERROR] Git sync failed. No forced reset or overwrite was attempted.
goto :fail

:fail
echo.
echo SYNC + P3.4A BUILDING PANEL: STOPPED
pause
exit /b 1
