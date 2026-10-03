@echo off
setlocal EnableExtensions
cd /d "%~dp0"

set "PACK=%~dp0female_normal_v1_stageA_repo_pack.zip"

if not exist "%PACK%" (
    echo [ERROR] Asset pack not found:
    echo %PACK%
    echo.
    echo Put female_normal_v1_stageA_repo_pack.zip in this repository root, then run this file again.
    pause
    exit /b 1
)

echo [1/2] Installing Stage A down/front PNG assets...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -LiteralPath '%PACK%' -DestinationPath '%~dp0' -Force"
if errorlevel 1 (
    echo [ERROR] Asset extraction failed.
    pause
    exit /b 1
)

echo [2/2] Running isolated Stage A verification...
call "%~dp0Verify-P3-2-Female-StageA.cmd"
exit /b %ERRORLEVEL%
