@echo off
setlocal EnableExtensions
cd /d "%~dp0"

set "PACK_NAME=female_normal_v1_stageA_runtime_pack_v2_quant.zip"
set "EXPECTED_SHA256=6a4213b9129ffb3f438c21cbb5326672ddf8915323836bf80cb33b8e5fabfdca"
set "TEMP_ZIP=%TEMP%\%PACK_NAME%"

echo [1/2] Restoring and verifying the Stage A 42-PNG pack...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop';" ^
  "$expected='%EXPECTED_SHA256%';" ^
  "$repo='%~dp0';" ^
  "$temp='%TEMP_ZIP%';" ^
  "$transport=Join-Path $repo '.github\assets\p3\female_stage_a';" ^
  "$parts=@('part01.b64','part02.b64','part03.b64','part04.b64','part05.b64','part06.b64','part07.b64','part08.b64','part09.b64','part10.b64','part11.b64','part12.b64','part13.b64','part14.b64','part15a.b64','part15b.b64','part16.b64','part17.b64','part18.b64','part19.b64','part20.b64');" ^
  "$transportReady=$true; foreach($name in $parts){if(-not (Test-Path -LiteralPath (Join-Path $transport $name) -PathType Leaf)){$transportReady=$false;break}};" ^
  "$selected=$null;" ^
  "if($transportReady){" ^
  "  Write-Host '[Stage A pack] Rebuilding from tracked CI transport...';" ^
  "  $raw=($parts | ForEach-Object {(Get-Content -Raw -LiteralPath (Join-Path $transport $_)).Trim()}) -join '';" ^
  "  [IO.File]::WriteAllBytes($temp,[Convert]::FromBase64String($raw));" ^
  "  $h=(Get-FileHash -Algorithm SHA256 -LiteralPath $temp).Hash.ToLowerInvariant();" ^
  "  Write-Host ('[Stage A pack] transport SHA256='+$h);" ^
  "  if($h -ne $expected){throw ('Tracked Stage A transport checksum mismatch. Expected '+$expected+', got '+$h)};" ^
  "  $selected=$temp;" ^
  "} else {" ^
  "  Write-Host '[Stage A pack] Tracked transport unavailable; checking external ZIP fallback...';" ^
  "  $candidates=New-Object 'System.Collections.Generic.List[string]';" ^
  "  if($env:STAGE_A_PACK -and (Test-Path -LiteralPath $env:STAGE_A_PACK -PathType Leaf)){$candidates.Add((Resolve-Path -LiteralPath $env:STAGE_A_PACK).Path)};" ^
  "  $exact=@((Join-Path $repo '%PACK_NAME%'),(Join-Path $env:USERPROFILE 'Downloads\%PACK_NAME%'),(Join-Path $env:USERPROFILE 'Desktop\%PACK_NAME%'));" ^
  "  foreach($p in $exact){if(Test-Path -LiteralPath $p -PathType Leaf){$r=(Resolve-Path -LiteralPath $p).Path;if(-not $candidates.Contains($r)){$candidates.Add($r)}}};" ^
  "  foreach($root in @((Join-Path $env:USERPROFILE 'Downloads'),(Join-Path $env:USERPROFILE 'Desktop'))){if(Test-Path -LiteralPath $root){$found=@(Get-ChildItem -LiteralPath $root -Filter 'female_normal_v1_stageA_runtime_pack_v2_quant*.zip' -File -ErrorAction SilentlyContinue);foreach($f in $found){if(-not $candidates.Contains($f.FullName)){$candidates.Add($f.FullName)}}}};" ^
  "  foreach($p in $candidates){try{$h=(Get-FileHash -Algorithm SHA256 -LiteralPath $p).Hash.ToLowerInvariant();Write-Host ('[Stage A pack] '+$p+' SHA256='+$h);if($h -eq $expected){$selected=$p;break}}catch{}};" ^
  "  if(-not $selected){throw ('Validated Stage A pack not found. Expected SHA256: '+$expected)};" ^
  "};" ^
  "Expand-Archive -LiteralPath $selected -DestinationPath $repo -Force;" ^
  "$assetRoot=Join-Path $repo 'godot\assets\p3\character_creator\parts\female_normal_v1';" ^
  "$count=@(Get-ChildItem -LiteralPath $assetRoot -Recurse -File -Filter '*.png').Count;" ^
  "if($count -ne 42){throw ('Stage A extraction produced '+$count+' PNGs; expected 42')};" ^
  "Write-Host '[Stage A pack] 42 canonical PNG assets installed.';" ^
  "if(Test-Path -LiteralPath $temp){Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue}"
if errorlevel 1 (
    echo [ERROR] Stage A asset restoration failed.
    echo [INFO] No Git reset or clean was attempted.
    if /I not "%P3_AUTO_PREVIEW%"=="1" pause
    exit /b 1
)

if /I "%STAGE_A_INSTALL_ONLY%"=="1" (
    echo [2/2] Install-only mode: PASS
    exit /b 0
)

echo [2/2] Running FAST P3.2 Stage A three-direction verification...
call "%~dp0Verify-P3-2-Female-StageA.cmd"
exit /b %ERRORLEVEL%
