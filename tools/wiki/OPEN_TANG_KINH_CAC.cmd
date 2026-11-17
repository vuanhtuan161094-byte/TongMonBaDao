@echo off
setlocal
cd /d "%~dp0\..\.."
set "PYTHON_EXE="
for /d %%D in ("%LOCALAPPDATA%\Programs\Python\Python*") do if exist "%%~fD\python.exe" set "PYTHON_EXE=%%~fD\python.exe"
if defined PYTHON_EXE goto UsePython
for /f "delims=" %%P in ('where python.exe 2^>nul') do if not defined PYTHON_EXE set "PYTHON_EXE=%%~fP"
if defined PYTHON_EXE goto UsePython
echo Khong tim thay Python 3.
pause
exit /b 2
:UsePython
"%PYTHON_EXE%" -c "import sys; sys.exit(0 if sys.version_info >= (3,10) else 1)"
if errorlevel 1 (
  echo Wiki can Python 3.10 tro len.
  pause
  exit /b 2
)
call tools\wiki\SYNC_WIKI_SOURCE.cmd
set "SYNC_EXIT=%errorlevel%"
if not "%SYNC_EXIT%"=="0" (
  echo Source sync that bai. Wiki chua duoc mo.
  pause
  exit /b %SYNC_EXIT%
)
"%PYTHON_EXE%" tools\wiki\serve_wiki.py
exit /b %errorlevel%
