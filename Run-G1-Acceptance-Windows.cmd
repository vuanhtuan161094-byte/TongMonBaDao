@echo off
setlocal
rem ONE-TIME G1.5-G1.8 OFFICIAL GODOT 4.7.2 ACCEPTANCE + PLAY.
rem Isolated TEMP clone and save. No CI, merge or modification to local game.
echo ================================================
echo TONG MON BA DAO - G1 ACCEPTANCE AND PLAY
echo 4 focused tests only; then 1280x720 game preview
echo ================================================
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\qa\Run-G1-PR20-Windows.ps1" -Acceptance -Play
set "RESULT=%ERRORLEVEL%"
echo.
echo Result: %RESULT%
echo Report: %USERPROFILE%\Downloads\TONG_MON_G1_PR20_QA_*.zip
echo Send only the ZIP if tests fail; screenshots for visual feedback.
pause
exit /b %RESULT%
