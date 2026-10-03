@echo off
setlocal EnableExtensions

rem Bootstrap through a temporary copy so git pull can safely update this launcher
rem without changing the batch file that cmd.exe is currently reading.
if /I "%~1"=="--temp-runner" goto :runner

set "TEMP_RUNNER=%TEMP%\TongMonBaDao_Sync_P3_2_Female_StageA_%RANDOM%_%RANDOM%.cmd"
copy /y "%~f0" "%TEMP_RUNNER%" >nul
if errorlevel 1 (
    echo [ERROR] Could not create temporary sync runner.
    pause
    exit /b 1
)

call "%TEMP_RUNNER%" --temp-runner "%~dp0"
set "EXIT_CODE=%ERRORLEVEL%"
del /q "%TEMP_RUNNER%" >nul 2>nul
exit /b %EXIT_CODE%

:runner
set "REPO_ROOT=%~2"
if not defined REPO_ROOT (
    echo [ERROR] Repository root was not passed to temporary sync runner.
    goto :fail
)
cd /d "%REPO_ROOT%"
if errorlevel 1 (
    echo [ERROR] Could not enter repository root: %REPO_ROOT%
    goto :fail
)

echo ========================================================
echo   TONG MON BA DAO - SYNC + FEMALE STAGE A FAST CHECK
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

rem Stage A proof PNGs and their Godot .png.import sidecars are generated locally
rem from the tracked verified Base64 pack. They are safe to overwrite/rebuild and
rem must not deadlock sync before a newer .gitignore is pulled. Every other
rem tracked/untracked change still blocks sync.
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "$lines=@(& git status --porcelain=v1 --untracked-files=all);" ^
  "$allowed='^\?\? godot/assets/p3/character_creator/parts/female_normal_v1/(body/body_01/body_01_(down|right|up)_.+\.png(?:\.import)?|face/face_01/face_01_(down|right|up)\.png(?:\.import)?|hair/hair_01/hair_01_(down|right|up)_(back|front)\.png(?:\.import)?|outfit/outfit_01/outfit_01_(down|right|up)_.+\.png(?:\.import)?|head_accessory/horn_01/horn_01_(down|right|up)\.png(?:\.import)?)$';" ^
  "$dirty=@($lines | Where-Object { $_ -notmatch $allowed });" ^
  "if($dirty.Count -gt 0){Write-Host '[STOP] Local changes detected. Sync was NOT performed to avoid overwriting your work.'; Write-Host ''; $dirty | ForEach-Object { Write-Host $_ }; exit 2}; exit 0"
set "DIRTY_EXIT=%ERRORLEVEL%"
if not "%DIRTY_EXIT%"=="0" goto :fail

echo [1/3] Fetching origin/main...
git fetch origin main
if errorlevel 1 goto :gitfail

echo [2/3] Updating local main with fast-forward only...
git pull --ff-only origin main
if errorlevel 1 goto :gitfail

echo [3/3] Installing Stage A assets and running FAST P3.2 verification...
call "%REPO_ROOT%Install-P3-2-Female-StageA.cmd"
exit /b %ERRORLEVEL%

:gitfail
echo.
echo [ERROR] Git sync failed. No forced reset or overwrite was attempted.
goto :fail

:fail
echo.
echo SYNC + FEMALE STAGE A: STOPPED
pause
exit /b 1
