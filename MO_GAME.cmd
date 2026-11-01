@echo off
setlocal EnableExtensions
chcp 65001 >nul
set "TMB_ROOT=%~dp0"
set "TMB_RC_ANCESTOR=0d3952dd11f85bebbde60176deafc4f19afc8a6f"
echo ===================================================
echo          TONG MON BA DAO - MO GAME
echo ===================================================
where git >nul 2>nul
if errorlevel 1 goto :missing_git
for /f "delims=" %%H in ('git -C "%TMB_ROOT%." rev-parse HEAD 2^>nul') do set "TMB_LOCAL_SHA=%%H"
if not defined TMB_LOCAL_SHA goto :invalid_checkout
git -C "%TMB_ROOT%." merge-base --is-ancestor "%TMB_RC_ANCESTOR%" HEAD >nul 2>nul
if errorlevel 1 goto :old_version
echo [OK] Git HEAD: %TMB_LOCAL_SHA%
set "TMB_GODOT=E:\TongMonBaDaoWorkspace\04_Tools\Godot\Godot_v4.7.2-stable_win64.exe"
if not exist "%TMB_GODOT%" set "TMB_GODOT=E:\Godot_v4.7.2-stable_win64.exe"
if not exist "%TMB_GODOT%" goto :missing_godot
if not exist "%TMB_ROOT%godot\project.godot" goto :missing_project
if not exist "%TMB_ROOT%godot\assets\p3\character_creator\parts\female_normal_v1\hair\hair_01\hair_01_down_back.png" (
  echo [INFO] Dang cai 42 anh Female Stage A, kiem tra SHA-256...
  set "STAGE_A_INSTALL_ONLY=1"
  call "%TMB_ROOT%tools\windows\bootstrap\Install-P3-2-Female-StageA.cmd"
  if errorlevel 1 goto :asset_failed
)
echo [OK] Godot: %TMB_GODOT%
echo [INFO] Dang mo game ONE GAME P3.2 1280x720 voi profile save moi rieng.
call "%TMB_ROOT%tools\windows\run\Run-OneGame-NewGame.cmd"
set "TMB_EXIT=%ERRORLEVEL%"
if not "%TMB_EXIT%"=="0" goto :game_error
exit /b 0
:missing_git
echo [LOI] Chua co Git. Nho Codex tao checkout sach tren o E.
goto :stop
:invalid_checkout
echo [LOI] Thu muc hien tai khong phai Git checkout hop le.
goto :stop
:old_version
echo [LOI] Thu muc nay chua chua PvE RC da kiem thu. Khong tu dong pull/reset.
echo [INFO] Nho Codex dong bo checkout game chinh tren o E.
goto :stop
:missing_godot
echo [LOI] Khong tim thay Godot 4.7.2 tren o E.
goto :stop
:missing_project
echo [LOI] Thieu godot\project.godot.
goto :stop
:asset_failed
echo [LOI] Khong the khoi phuc Female Stage A; checksum van bat buoc.
goto :stop
:game_error
echo [LOI] Game exit code %TMB_EXIT%. Can doc log.
:stop
echo.
echo Chup anh cua so nay gui Codex neu can.
pause
exit /b 1
