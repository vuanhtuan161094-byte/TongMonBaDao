@echo off
setlocal EnableExtensions
cd /d "%~dp0"

set "ASSET_DIR=%~dp0tools\assets"
set "TEMP_ZIP=%TEMP%\female_normal_v1_stageA_v2q_runtime_pack.zip"
set "EXPECTED_SHA256=6a4213b9129ffb3f438c21cbb5326672ddf8915323836bf80cb33b8e5fabfdca"

echo [1/3] Rebuilding tracked Stage A down/right/up runtime asset pack...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$files=@('%ASSET_DIR%\female_normal_v1_stageA_v2q_01.b64','%ASSET_DIR%\female_normal_v1_stageA_v2q_02.b64','%ASSET_DIR%\female_normal_v1_stageA_v2q_03.b64','%ASSET_DIR%\female_normal_v1_stageA_v2q_04.b64'); foreach($f in $files){if(-not (Test-Path -LiteralPath $f)){throw ('Missing Stage A asset part: '+$f)}}; $raw=($files | ForEach-Object {(Get-Content -Raw -LiteralPath $_).Trim()}) -join ''; [IO.File]::WriteAllBytes('%TEMP_ZIP%',[Convert]::FromBase64String($raw))"
if errorlevel 1 (
    echo [ERROR] Stage A asset pack rebuild failed.
    del /q "%TEMP_ZIP%" >nul 2>nul
    pause
    exit /b 1
)

echo [2/3] Verifying SHA-256 and installing 42 PNG assets...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$h=(Get-FileHash -Algorithm SHA256 -LiteralPath '%TEMP_ZIP%').Hash.ToLowerInvariant(); if($h -ne '%EXPECTED_SHA256%'){throw ('Stage A pack SHA256 mismatch. Expected %EXPECTED_SHA256%, got '+$h)}; Expand-Archive -LiteralPath '%TEMP_ZIP%' -DestinationPath '%~dp0' -Force"
if errorlevel 1 (
    echo [ERROR] Stage A asset verification/extraction failed.
    del /q "%TEMP_ZIP%" >nul 2>nul
    pause
    exit /b 1
)
del /q "%TEMP_ZIP%" >nul 2>nul

echo [3/3] Running FAST P3.2 Stage A three-direction verification...
call "%~dp0Verify-P3-2-Female-StageA.cmd"
exit /b %ERRORLEVEL%
