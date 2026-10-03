@echo off
setlocal EnableExtensions
cd /d "%~dp0"

set "PACK=%~dp0tools\assets\female_normal_v1_stageA_repo_pack.zip"

if not exist "%PACK%" (
    echo [ERROR] Tracked Stage A asset pack not found:
    echo %PACK%
    echo.
    echo Run git pull on main, then try this installer again.
    pause
    exit /b 1
)

echo [1/2] Installing Stage A down/front PNG assets from tracked pack...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -LiteralPath '%PACK%' -DestinationPath '%~dp0' -Force"
if errorlevel 1 (
    echo [ERROR] Asset extraction failed.
    pause
    exit /b 1
)

echo [2/2] Running isolated Stage A verification...
call "%~dp0Verify-P3-2-Female-StageA.cmd"
exit /b %ERRORLEVEL%
