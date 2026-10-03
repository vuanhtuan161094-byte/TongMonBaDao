@echo off
setlocal EnableExtensions
cd /d "%~dp0"

set "PACK_B64=%~dp0tools\assets\female_normal_v1_stageA_runtime_pack.zip.b64"
set "TEMP_ZIP=%TEMP%\female_normal_v1_stageA_runtime_pack.zip"
set "EXPECTED_SHA256=0c23ed5ee12cf5ec838e0a87b00f33122f6a196bd3812ecf96de2d99086fcc7c"

if not exist "%PACK_B64%" (
    echo [ERROR] Tracked Stage A Base64 asset pack not found:
    echo %PACK_B64%
    echo.
    echo Run git pull on main, then try this installer again.
    pause
    exit /b 1
)

echo [1/3] Decoding tracked Stage A runtime asset pack...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$raw=(Get-Content -Raw -LiteralPath '%PACK_B64%').Trim(); [IO.File]::WriteAllBytes('%TEMP_ZIP%',[Convert]::FromBase64String($raw))"
if errorlevel 1 (
    echo [ERROR] Base64 decode failed.
    pause
    exit /b 1
)

echo [2/3] Verifying checksum and installing 14 PNG assets...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$h=(Get-FileHash -Algorithm SHA256 -LiteralPath '%TEMP_ZIP%').Hash.ToLowerInvariant(); if($h -ne '%EXPECTED_SHA256%'){ throw ('Stage A pack SHA256 mismatch: '+$h) }; Expand-Archive -LiteralPath '%TEMP_ZIP%' -DestinationPath '%~dp0' -Force"
if errorlevel 1 (
    echo [ERROR] Asset verification/extraction failed.
    del /q "%TEMP_ZIP%" >nul 2>nul
    pause
    exit /b 1
)
del /q "%TEMP_ZIP%" >nul 2>nul

echo [3/3] Running fast Stage A P3.2 verification...
call "%~dp0Verify-P3-2-Female-StageA.cmd"
exit /b %ERRORLEVEL%
