@echo off
setlocal EnableExtensions
cd /d "%~dp0"

echo ========================================================
echo   TONG MON BA DAO - P3.6 SECT MASTER LOOP PLAYTEST
echo ========================================================
echo.
echo This is a REAL 5-10 minute product-loop playtest.
echo Do not treat this as a headless PASS.
echo.
echo PLAYTEST ORDER
echo --------------------------------------------------------
echo 1. First 10-20 seconds: DO NOT CLICK.
echo    Check whether you can tell if the sect is stable or has a problem.
echo    There should be at most 3 important world cues.
echo.
echo 2. Follow ONE important cue.
echo    Cue -^> target panel -^> useful action should take about 2-3 taps.
echo.
echo 3. Leave the game alone for 1-2 minutes.
echo    Disciples should continue to work/cultivate/rest/hunt/return sensibly.
echo    You should NOT need to command each disciple.
echo.
echo 4. Make ONE strategic change.
echo    Example: Main Hall policy OR Mine/Forge long-term assignment.
echo    Then watch for a visible consequence on the map/state.
echo.
echo 5. Make ONE real investment if resources allow.
echo    Example: craft equipment OR expand lodging.
echo    It must consume real resources and change real state.
echo.
echo 6. Try to stay on the map for about 5 minutes.
echo    Deep disciple inspection is optional, never required for routine control.
echo.
echo FAIL SIGNALS
echo --------------------------------------------------------
echo - more than 3 attention cues competing at once
echo - must click every building to collect/maintain normal operation
echo - must command every disciple repeatedly
echo - policy/order has no visible consequence
echo - routine action needs too many screens/taps
echo - map becomes secondary to menus
echo - session feels like clearing notifications instead of managing a sect
echo.
echo AFTER CLOSING THE GAME, report:
echo A. 10-second readability: PASS/FAIL + why
echo B. Cue-to-action in <=3 taps: PASS/FAIL
echo C. 1-2 minute autonomous operation: PASS/FAIL
echo D. Strategic change produced visible consequence: PASS/FAIL + what changed
echo E. Any repetitive chore/dead button/confusing feedback
echo F. Overall: does it feel like managing a living sect? YES/NO + short reason
echo.

set "GODOT_PREVIEW="

if defined GODOT_BIN if exist "%GODOT_BIN%" set "GODOT_PREVIEW=%GODOT_BIN%"
if not defined GODOT_PREVIEW if exist "%~d0\Godot_v4.7.2-stable_win64.exe" set "GODOT_PREVIEW=%~d0\Godot_v4.7.2-stable_win64.exe"
if not defined GODOT_PREVIEW if exist "%~d0\Godot_v4.7.2-stable_win64_console.exe" set "GODOT_PREVIEW=%~d0\Godot_v4.7.2-stable_win64_console.exe"

if not defined GODOT_PREVIEW (
    echo [ERROR] Godot 4.7.2 was not found.
    echo Set GODOT_BIN or place the Godot executable at the drive root.
    echo.
    pause
    exit /b 1
)

echo [Godot] %GODOT_PREVIEW%
echo [Scene] res://scenes/p3/p3_2_landscape_sect.tscn
echo.
echo Launching real main scene...
echo.

"%GODOT_PREVIEW%" --path "%~dp0godot" res://scenes/p3/p3_2_landscape_sect.tscn
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if not "%EXIT_CODE%"=="0" (
    echo [ERROR] Playtest scene exited with code %EXIT_CODE%.
) else (
    echo P3.6 PLAYTEST SESSION CLOSED NORMALLY
)
echo.
pause
exit /b %EXIT_CODE%
