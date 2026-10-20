@echo off
setlocal EnableExtensions
chcp 65001 >nul
cd /d "%~dp0"
if not defined TMB_ASSET_VAULT (
  if exist "E:\" (
    set "TMB_ASSET_VAULT=E:\TongMonBaDao_AssetVault"
  ) else (
    set "TMB_ASSET_VAULT=%~dp0AssetVault"
  )
)
where py >nul 2>nul
if not errorlevel 1 (
  set "PY=py -3"
) else (
  where python >nul 2>nul
  if errorlevel 1 (
    echo [ERROR] Python 3.10+ chua co tren PATH. Cai Python hoac chay bang Python portable.
    pause
    exit /b 2
  )
  set "PY=python"
)
%PY% studio.py init --vault "%TMB_ASSET_VAULT%"
if errorlevel 1 goto :failed
start "" powershell.exe -NoProfile -Command "Start-Sleep -Seconds 1; Start-Process 'http://127.0.0.1:8791'"
%PY% studio.py serve --vault "%TMB_ASSET_VAULT%" --port 8791
if errorlevel 1 goto :failed
exit /b 0
:failed
echo Studio gap loi. Xem thong bao phia tren.
pause
exit /b 2