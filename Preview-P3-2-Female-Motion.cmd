@echo off
setlocal EnableExtensions
cd /d "%~dp0"

echo ========================================================
echo   TONG MON BA DAO - FEMALE SHARED MOTION PREVIEW
echo ========================================================
echo.
echo Shows IDLE and WALK for DOWN / RIGHT / UP / LEFT.
echo LEFT must mirror RIGHT. All actors use one shared AnimationLibrary.
echo.
echo Visual check:
echo - feet do not slide or float excessively;
echo - breathing stays subtle in IDLE;
echo - walk reads clearly without tearing shoulders/hips;
echo - hair/horns stay attached to the head;
echo - front/side/back remain the same character;
echo - LEFT is a clean mirror of RIGHT.
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
"%GODOT_PREVIEW%" --path "%~dp0godot" res://scenes/p3/p3_2_female_motion_sandbox.tscn
set "EXIT_CODE=%ERRORLEVEL%"
echo.
if not "%EXIT_CODE%"=="0" echo [ERROR] Preview exited with code %EXIT_CODE%.
pause
exit /b %EXIT_CODE%
