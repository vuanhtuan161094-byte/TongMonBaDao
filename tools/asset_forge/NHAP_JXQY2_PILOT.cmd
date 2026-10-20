@echo off
setlocal EnableExtensions
chcp 65001 >nul
cd /d "%~dp0"
set "JXQY_ROOT=E:\codex\work\jxqy2_slice\source"
if not exist "%JXQY_ROOT%\save\rpg0\player.ini" (
  echo Khong tim thay JXQY2 source tai %JXQY_ROOT%
  set /p "JXQY_ROOT=Nhap duong dan thu muc JXQY2 raw: "
)
if not exist "%JXQY_ROOT%\save\rpg0\player.ini" (
  echo ERROR: source khong dung, can file save\rpg0\player.ini
  pause
  exit /b 2
)
if not defined TMB_ASSET_VAULT (
  if exist "E:\" (set "TMB_ASSET_VAULT=E:\TongMonBaDao_AssetVault") else (set "TMB_ASSET_VAULT=%~dp0AssetVault")
)
where py >nul 2>nul
if not errorlevel 1 (set "PY=py -3") else (set "PY=python")
%PY% studio.py stage-jxqy-pilot --vault "%TMB_ASSET_VAULT%" --from-root "%JXQY_ROOT%" --tile-dir "mpc/map/矿山"
if errorlevel 1 (echo Import PENDING. Kiem thong bao ben tren.) else (echo Import staging DONE. Mo MO_ASSET_FORGE_STUDIO.cmd de xem.)
pause