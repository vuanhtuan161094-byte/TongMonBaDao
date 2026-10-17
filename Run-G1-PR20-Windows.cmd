@echo off
setlocal
rem TONG MON BA DAO G1 PR20 - one-click official Windows QA.
rem Fetches isolated GitHub draft branch into TEMP. Does not alter local game.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\qa\Run-G1-PR20-Windows.ps1" %*
set "RESULT=%ERRORLEVEL%"
echo.
echo QA finished with code %RESULT%. Check Downloads for TONG_MON_G1_PR20_QA_*.zip
pause
exit /b %RESULT%
