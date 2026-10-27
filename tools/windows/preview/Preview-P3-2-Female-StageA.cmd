@echo off
for %%I in ("%~dp0..\..\..") do set "TMB_ROOT=%%~fI\"
setlocal EnableExtensions
cd /d "%TMB_ROOT%"

echo ========================================================
echo   TONG MON BA DAO - FEMALE STAGE A VISUAL PREVIEW
echo ========================================================
echo.
echo This opens the already FAST-green Stage A sandbox visually.
echo Compare the same down/front actor at 0.75x, 1.00x and 1.35x.
echo.
echo Check visually:
echo - face, hair and horns stay registered as one head;
echo - shoulders and arms do not split away from the torso;
echo - skirt/outfit does not expose broken seams;
echo - both legs/feet stay coherent and meet the same ground level;
echo - silhouette still reads clearly at 0.75x.
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
echo [Scene] res://scenes/p3/p3_2_female_stage_a_down_sandbox.tscn
echo.

"%GODOT_PREVIEW%" --path "%TMB_ROOT%godot" res://scenes/p3/p3_2_female_stage_a_down_sandbox.tscn
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if not "%EXIT_CODE%"=="0" echo [ERROR] Preview exited with code %EXIT_CODE%.
pause
exit /b %EXIT_CODE%
