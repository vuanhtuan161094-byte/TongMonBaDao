@echo off
setlocal
call "%~dp0tools\windows\run\Verify-AN03-ModularRig.cmd" /capture
set "RESULT=%ERRORLEVEL%"
if not "%RESULT%"=="0" pause
exit /b %RESULT%
