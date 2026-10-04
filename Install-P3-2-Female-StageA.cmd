@echo off
setlocal EnableExtensions
cd /d "%~dp0"

set "PACK_NAME=female_normal_v1_stageA_runtime_pack_v2_quant.zip"
set "EXPECTED_SHA256=6a4213b9129ffb3f438c21cbb5326672ddf8915323836bf80cb33b8e5fabfdca"

echo [1/2] Locating, verifying and installing the Stage A 42-PNG pack...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "$expected='%EXPECTED_SHA256%';" ^
  "$repo='%~dp0';" ^
  "$candidates=New-Object 'System.Collections.Generic.List[string]';" ^
  "if($env:STAGE_A_PACK -and (Test-Path -LiteralPath $env:STAGE_A_PACK -PathType Leaf)){$candidates.Add((Resolve-Path -LiteralPath $env:STAGE_A_PACK).Path)};" ^
  "$exact=@((Join-Path $repo '%PACK_NAME%'),(Join-Path $env:USERPROFILE 'Downloads\%PACK_NAME%'),(Join-Path $env:USERPROFILE 'Desktop\%PACK_NAME%'));" ^
  "foreach($p in $exact){if(Test-Path -LiteralPath $p -PathType Leaf){$r=(Resolve-Path -LiteralPath $p).Path;if(-not $candidates.Contains($r)){$candidates.Add($r)}}};" ^
  "foreach($root in @((Join-Path $env:USERPROFILE 'Downloads'),(Join-Path $env:USERPROFILE 'Desktop'))){if(Test-Path -LiteralPath $root){$found=@(Get-ChildItem -LiteralPath $root -Filter 'female_normal_v1_stageA_runtime_pack_v2_quant*.zip' -File -ErrorAction SilentlyContinue);foreach($f in $found){if(-not $candidates.Contains($f.FullName)){$candidates.Add($f.FullName)}}}};" ^
  "$selected=$null;" ^
  "foreach($p in $candidates){try{$h=(Get-FileHash -Algorithm SHA256 -LiteralPath $p).Hash.ToLowerInvariant();Write-Host ('[Stage A pack] '+$p+' SHA256='+$h);if($h -eq $expected){$selected=$p;break}}catch{}};" ^
  "if(-not $selected){throw ('Validated Stage A pack not found. Download %PACK_NAME% and leave it in Downloads, Desktop, or the repo root. Expected SHA256: '+$expected)};" ^
  "Expand-Archive -LiteralPath $selected -DestinationPath $repo -Force;" ^
  "Write-Host '[Stage A pack] 42 PNG assets installed from validated ZIP.'"
if errorlevel 1 (
    echo [ERROR] Stage A asset installation failed.
    echo [INFO] No generated PNG was deleted and no Git reset/clean was attempted.
    pause
    exit /b 1
)

echo [2/2] Running FAST P3.2 Stage A three-direction verification...
call "%~dp0Verify-P3-2-Female-StageA.cmd"
exit /b %ERRORLEVEL%
