@echo off
setlocal
python "%~dp0tools\sourcea-spine-library\sourcea_library.py" --config "%~dp0library.local.json" %*
exit /b %errorlevel%

