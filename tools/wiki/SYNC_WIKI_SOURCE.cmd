@echo off
setlocal
cd /d "%~dp0\..\.."
set "PYTHON_EXE="
for /d %%D in ("%LOCALAPPDATA%\Programs\Python\Python*") do if exist "%%~fD\python.exe" set "PYTHON_EXE=%%~fD\python.exe"
if defined PYTHON_EXE goto UsePython
for /f "delims=" %%P in ('where python.exe 2^>nul') do if not defined PYTHON_EXE set "PYTHON_EXE=%%~fP"
if defined PYTHON_EXE goto UsePython
echo Khong tim thay Python 3 chinh thuc.
pause
exit /b 2
:UsePython
"%PYTHON_EXE%" tools\wiki\build_wiki_catalog.py --write
exit /b %errorlevel%
