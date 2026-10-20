@echo off
setlocal EnableExtensions
cd /d "%~dp0"
call "%~dp0FIND_PYTHON.cmd"
if errorlevel 1 goto :missing
"%TMB_PYTHON_EXE%" %TMB_PYTHON_ARGS% -m unittest discover -p "test_*.py" -v
set "RESULT=%ERRORLEVEL%"
pause
exit /b %RESULT%
:missing
pause
exit /b 3