@echo off
setlocal EnableExtensions
chcp 65001 >nul
cd /d "%~dp0"
for %%I in ("%~dp0..\..") do set "TMB_REPO=%%~fI"
if not exist "%TMB_REPO%\godot\assets\actors\1113028_1\asset.json" (
  echo Tool khong nam trong repo game. Nhap path checkout TONG MON BA DAO:
  set /p "TMB_REPO=Duong dan: "
)
if not exist "%TMB_REPO%\godot\assets\actors\1113028_1\asset.json" (
  echo ERROR: checkout nay khong co Source A rigs can thiet
  pause
  exit /b 2
)
if not defined TMB_ASSET_VAULT (
  if exist "E:\" (set "TMB_ASSET_VAULT=E:\TongMonBaDao_AssetVault") else (set "TMB_ASSET_VAULT=%~dp0AssetVault")
)
call "%~dp0FIND_PYTHON.cmd"
if errorlevel 1 goto :missing_python
"%TMB_PYTHON_EXE%" %TMB_PYTHON_ARGS% studio.py stage --vault "%TMB_ASSET_VAULT%" --source-id SOURCE_A --from-root "%TMB_REPO%" ^
 --path godot/assets/actors/1113028_1/actor.tscn ^
 --path godot/assets/actors/1113028_1/animations.tres ^
 --path godot/assets/actors/1113028_1/asset.json ^
 --path godot/assets/actors/1113028_1/atlas_000.webp ^
 --path godot/assets/actors/1113028_1/atlas_001.webp ^
 --path godot/assets/actors/body_1110201/actor.tscn ^
 --path godot/assets/actors/body_1110201/animations.tres ^
 --path godot/assets/actors/body_1110201/asset.json ^
 --path godot/assets/actors/body_1110201/atlas_000.webp ^
 --path godot/assets/actors/body_1120402/actor.tscn ^
 --path godot/assets/actors/body_1120402/animations.tres ^
 --path godot/assets/actors/body_1120402/asset.json ^
 --path godot/assets/actors/body_1120402/atlas_000.webp
if errorlevel 1 (echo STAGE PENDING. Xem log phia tren.) else (echo STAGE DONE: 13 file asset Godot Source A vao 01_raw\SOURCE_A)
pause
exit /b 0
:missing_python
pause
exit /b 3