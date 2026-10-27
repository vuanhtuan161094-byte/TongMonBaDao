@echo off
for %%I in ("%~dp0..\..\..") do set "TMB_ROOT=%%~fI\"
setlocal EnableExtensions
cd /d "%TMB_ROOT%"

echo ================================================
echo   TONG MON BA DAO - SYNC MAIN
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
    goto :fail
)

git diff --quiet
if errorlevel 1 (
    echo [STOP] Tracked local changes detected. Sync was NOT performed to avoid overwriting your work.
    echo.
    git status --short --untracked-files=no
    goto :fail
)

git diff --cached --quiet
if errorlevel 1 (
    echo [STOP] Staged local changes detected. Sync was NOT performed to avoid overwriting your work.
    echo.
    git status --short --untracked-files=no
    goto :fail
)

set "UNTRACKED="
for /f "delims=" %%S in ('git ls-files --others --exclude-standard') do set "UNTRACKED=1"
if defined UNTRACKED (
    echo [WARN] Untracked local files exist. They will not be deleted or overwritten by this launcher.
    git status --short
    echo.
)

echo [1/2] Fetching origin/main...
git fetch origin main
if errorlevel 1 goto :gitfail

echo [2/2] Updating local main with fast-forward only...
git pull --ff-only origin main
if errorlevel 1 goto :gitfail

echo.
echo SYNC MAIN: PASS

if "%~1"=="" exit /b 0

set "TARGET=%~1"
if not exist "%TMB_ROOT%%TARGET%" (
    echo.
    echo [ERROR] Requested launcher not found after sync:
    echo   %TARGET%
    goto :fail
)

echo.
echo Running:
echo   %TARGET%
echo.
call "%TMB_ROOT%%TARGET%"
exit /b %ERRORLEVEL%

:gitfail
echo.
echo [ERROR] Git sync failed. No forced reset or overwrite was attempted.
goto :fail

:fail
echo.
echo SYNC MAIN: STOPPED
pause
exit /b 1
