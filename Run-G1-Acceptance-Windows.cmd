@echo off
setlocal
rem ONE-TIME G1.5-G1.8 OFFICIAL GODOT 4.7.2 ACCEPTANCE + PLAY.
rem Isolated TEMP clone and save. No CI, merge or modification to local game.
echo ================================================
echo TONG MON BA DAO - G1 ACCEPTANCE AND PLAY
echo 4 focused tests only; then 1280x720 game preview
echo Save 3 real Mine / Forest / Field screenshots in the QA report folder.
echo ================================================
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\qa\Run-G1-PR20-Windows.ps1" -Acceptance -Play
set "RESULT=%ERRORLEVEL%"
echo.
echo Result: %RESULT%
echo Report: %USERPROFILE%\Downloads\TONG_MON_G1_PR20_QA_*.zip
echo Send the QA ZIP on PASS, PENDING or FAIL. Include three real G1 screenshots.
echo Owner visual acceptance stays PENDING until screenshots are reviewed.
pause
exit /b %RESULT%
