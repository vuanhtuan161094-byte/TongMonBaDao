@echo off
setlocal EnableExtensions
cd /d "%~dp0"

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

set "DIRTY="
for /f "delims=" %%S in ('git status --porcelain') do set "DIRTY=1"
if defined DIRTY (
    echo [STOP] Local changes detected. Sync was NOT performed to avoid overwriting your work.
    echo.
    git status --short
    goto :fail
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
if not exist "%~dp0%TARGET%" (
    echo.
    echo [ERROR] Requested launcher not found after sync:
    echo   %TARGET%
    goto :fail
)

echo.
echo Running:
echo   %TARGET%
echo.
call "%~dp0%TARGET%"
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
