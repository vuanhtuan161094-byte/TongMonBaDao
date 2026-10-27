@echo off
for %%I in ("%~dp0..\..\..") do set "TMB_ROOT=%%~fI\"
setlocal EnableExtensions
cd /d "%TMB_ROOT%"

echo ========================================================
echo   TONG MON BA DAO - FEMALE STAGE A DIRECTION PREVIEW
echo ========================================================
echo.
echo Shows authored DOWN, RIGHT and UP at 0.75x and 1.35x.
echo LEFT is intentionally not authored yet; it will mirror RIGHT when safe.
echo.
echo Check visually:
echo - same character identity/proportions across front, side and back;
echo - head, horns and hair keep consistent size and root position;
echo - shoulders, hips and feet do not jump between directions;
echo - RIGHT still reads as a side view, not a different character;
echo - UP has no front-face leak through the hair;
echo - all feet share the same ground registration;
echo - silhouettes remain readable at 0.75x.
echo.

set "GODOT_PREVIEW="

if defined GODOT_BIN if exist "%GODOT_BIN%" set "GODOT_PREVIEW=%GODOT_BIN%"

if not defined GODOT_PREVIEW if exist "%~d0\Godot_v4.7.2-stable_win64.exe" set "GODOT_PREVIEW=%~d0\Godot_v4.7.2-stable_win64.exe"
if not defined GODOT_PREVIEW if exist "%~d0\Godot_v4.7.2-stable_win64_console.exe" set "GODOT_PREVIEW=%~d0\Godot_v4.7.2-stable_win64_console.exe"

if not defined GODOT_PREVIEW (
    echo [ERROR] Godot 4.7.2 was not found beside the repository drive root.
    echo Expected one of:
    echo   %~d0\Godot_v4.7.2-stable_win64.exe
    echo   %~d0\Godot_v4.7.2-stable_win64_console.exe
    echo Or set GODOT_BIN to the full executable path.
    echo.
    pause
    exit /b 1
)

echo [Godot] %GODOT_PREVIEW%
echo [Scene] res://scenes/p3/p3_2_female_stage_a_directions_sandbox.tscn
echo.

"%GODOT_PREVIEW%" --path "%TMB_ROOT%godot" res://scenes/p3/p3_2_female_stage_a_directions_sandbox.tscn
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if not "%EXIT_CODE%"=="0" echo [ERROR] Preview exited with code %EXIT_CODE%.
pause
exit /b %EXIT_CODE%
