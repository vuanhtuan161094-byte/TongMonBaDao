@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul
cd /d "%~dp0"
call "%~dp0FIND_PYTHON.cmd"
if errorlevel 1 goto :missing_python
if not defined TMB_ASSET_VAULT (
  if exist "E:\" (
    set "TMB_ASSET_VAULT=E:\TongMonBaDao_AssetVault"
  ) else (
    set "TMB_ASSET_VAULT=%~dp0AssetVault"
  )
)
echo [INFO] Selected Python: %TMB_PYTHON_EXE% %TMB_PYTHON_ARGS%
"%TMB_PYTHON_EXE%" %TMB_PYTHON_ARGS% studio.py init --vault "%TMB_ASSET_VAULT%"
if errorlevel 1 goto :failed
start "" powershell.exe -NoProfile -Command "Start-Sleep -Seconds 1; Start-Process 'http://127.0.0.1:8791'"
"%TMB_PYTHON_EXE%" %TMB_PYTHON_ARGS% studio.py serve --vault "%TMB_ASSET_VAULT%" --port 8791
if errorlevel 1 goto :failed
exit /b 0
:missing_python
echo [HELP] Run KIEM_TRA_PYTHON.cmd or set TMB_PYTHON_OVERRIDE to python.exe.
pause
exit /b 3
:failed
echo Studio gap loi. Xem thong bao phia tren.
pause
exit /b 2