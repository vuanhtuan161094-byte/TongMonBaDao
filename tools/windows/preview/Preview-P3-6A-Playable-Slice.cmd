@echo off
for %%I in ("%~dp0..\..\..") do set "TMB_ROOT=%%~fI\"
setlocal EnableExtensions
cd /d "%TMB_ROOT%"

echo ========================================================
echo   TONG MON BA DAO - P3.6A PLAYABLE SLICE PREVIEW
echo ========================================================
echo.
echo This preview is for the player-facing main scene after productization.
echo.
echo Check visually:
echo - no P3.x / debug / test wording is visible;
echo - no demo chapter checklist is shown;
echo - buildings are distinguishable by silhouette/function, not plain debug boxes;
echo - map remains the primary surface;
echo - disciple and building panels read like game UI;
echo - cues remain limited and useful;
echo - disciples visibly keep moving/working from real simulation state.
echo.

set "GODOT_PREVIEW="
if defined GODOT_BIN if exist "%GODOT_BIN%" set "GODOT_PREVIEW=%GODOT_BIN%"
if not defined GODOT_PREVIEW if exist "%~d0\Godot_v4.7.2-stable_win64.exe" set "GODOT_PREVIEW=%~d0\Godot_v4.7.2-stable_win64.exe"
if not defined GODOT_PREVIEW if exist "%~d0\Godot_v4.7.2-stable_win64_console.exe" set "GODOT_PREVIEW=%~d0\Godot_v4.7.2-stable_win64_console.exe"

if not defined GODOT_PREVIEW (
    echo [ERROR] Godot 4.7.2 was not found.
    pause
    exit /b 1
)

echo [Godot] %GODOT_PREVIEW%
echo [Scene] res://scenes/p3/p3_2_landscape_sect.tscn
echo.

"%GODOT_PREVIEW%" --path "%TMB_ROOT%godot" res://scenes/p3/p3_2_landscape_sect.tscn
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if not "%EXIT_CODE%"=="0" echo [ERROR] Preview exited with code %EXIT_CODE%.
pause
exit /b %EXIT_CODE%
