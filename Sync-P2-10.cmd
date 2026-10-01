@echo off
setlocal EnableExtensions
cd /d "%~dp0"

echo ================================================
echo   TONG MON BA DAO - SYNC + P2.10 VERIFY
echo ================================================
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
    echo Switch to main before using this verifier.
    goto :fail
)

for /f "delims=" %%R in ('git remote get-url origin 2^>nul') do set "ORIGIN_URL=%%R"
if not defined ORIGIN_URL (
    echo [ERROR] Git remote "origin" is missing.
    goto :fail
)

echo [Repo] %CD%
echo [Branch] %BRANCH%
echo [Origin] %ORIGIN_URL%
for /f "delims=" %%H in ('git rev-parse --short HEAD') do set "OLD_HEAD=%%H"
echo [Before] %OLD_HEAD%
echo.

set "DIRTY="
for /f "delims=" %%S in ('git status --porcelain') do set "DIRTY=1"
if defined DIRTY (
    echo [STOP] Local changes detected. Sync was NOT performed to avoid overwriting your work.
    echo.
    git status --short
    echo.
    echo Commit, discard, or stash those changes, then run Sync-P2-10.cmd again.
    goto :fail
)

echo [1/3] Fetching origin/main...
git fetch origin main
if errorlevel 1 goto :gitfail

echo [2/3] Updating local main with fast-forward only...
git pull --ff-only origin main
if errorlevel 1 goto :gitfail

for /f "delims=" %%H in ('git rev-parse --short HEAD') do set "NEW_HEAD=%%H"
echo [After] %NEW_HEAD%
echo.

echo [3/3] Running P0 through P2.9 regressions and P2.10 verification...
call "%~dp0Verify-P2-10.cmd"
set "VERIFY_EXIT=%ERRORLEVEL%"
if not "%VERIFY_EXIT%"=="0" exit /b %VERIFY_EXIT%

exit /b 0

:gitfail
echo.
echo [ERROR] Git sync failed. No forced reset or overwrite was attempted.
goto :fail

:fail
echo.
echo SYNC + P2.10: STOPPED
pause
exit /b 1
