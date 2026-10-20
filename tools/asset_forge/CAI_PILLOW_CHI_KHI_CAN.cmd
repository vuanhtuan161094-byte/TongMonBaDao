@echo off
setlocal EnableExtensions
cd /d "%~dp0"
call "%~dp0FIND_PYTHON.cmd"
if errorlevel 1 goto :missing
"%TMB_PYTHON_EXE%" %TMB_PYTHON_ARGS% -m pip install Pillow
set "RESULT=%ERRORLEVEL%"
echo Pillow chi can cho preview PNG, khong can de doc MAP hoac copy raw.
pause
exit /b %RESULT%
:missing
pause
exit /b 3