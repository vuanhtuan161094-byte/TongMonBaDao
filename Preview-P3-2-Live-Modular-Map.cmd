@echo off
setlocal EnableExtensions
cd /d "%~dp0"

echo ========================================================
echo   TONG MON BA DAO - LIVE MODULAR MAP PREVIEW
echo ========================================================
echo.
echo Opens the real P3.2 sect map.
echo Female disciples use the accepted Stage A modular actor when the local asset pack is installed.
echo Other actors fall back safely.
echo.
echo Check:
echo - female actor walks between real simulation destinations;
echo - direction art changes DOWN/RIGHT/UP/LEFT correctly;
echo - idle resumes after movement;
echo - tapping actor still focuses/opens disciple UI;
echo - zoom/pan and building taps still work.
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
"%GODOT_PREVIEW%" --path "%~dp0godot" res://scenes/p3/p3_2_landscape_sect.tscn
set "EXIT_CODE=%ERRORLEVEL%"
echo.
if not "%EXIT_CODE%"=="0" echo [ERROR] Preview exited with code %EXIT_CODE%.
pause
exit /b %EXIT_CODE%
