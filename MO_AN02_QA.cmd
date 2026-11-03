@echo off
setlocal
call "%~dp0tools\windows\run\Verify-AN02-AnimationLab.cmd" /capture
set "RESULT=%ERRORLEVEL%"
if not "%RESULT%"=="0" pause
exit /b %RESULT%
