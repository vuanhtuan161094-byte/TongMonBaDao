@echo off
rem AF-04 Python bootstrap. Intended for CALL from other CMD launchers.
rem Return 0 with TMB_PYTHON_EXE and optional TMB_PYTHON_ARGS, or return 3.
rem Do not SETLOCAL here: selected variables must survive in the caller.
set "TMB_PYTHON_EXE="
set "TMB_PYTHON_ARGS="

rem A one-time local selection persists between launches without changing PATH.
if exist "%~dp0python.local.txt" (
  for /f "usebackq delims=" %%P in ("%~dp0python.local.txt") do (
    call :check_exe "%%P"
    if not errorlevel 1 exit /b 0
  )
)

rem A user can select the exact installed interpreter without changing PATH.
if defined TMB_PYTHON_OVERRIDE (
  call :check_exe "%TMB_PYTHON_OVERRIDE%"
  if not errorlevel 1 exit /b 0
  echo [WARN] TMB_PYTHON_OVERRIDE does not point to a working Python 3.10+ interpreter.
)

rem The registered py launcher is the most reliable option on Windows.
where.exe py.exe >nul 2>nul
if not errorlevel 1 (
  py -3 -c "import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)" >nul 2>nul
  if not errorlevel 1 (
    set "TMB_PYTHON_EXE=py"
    set "TMB_PYTHON_ARGS=-3"
    exit /b 0
  )
)

rem Honor the active virtual environment/Conda before searching PATH.
if defined VIRTUAL_ENV (
  call :check_exe "%VIRTUAL_ENV%\Scripts\python.exe"
  if not errorlevel 1 exit /b 0
)
if defined CONDA_PREFIX (
  call :check_exe "%CONDA_PREFIX%\python.exe"
  if not errorlevel 1 exit /b 0
)
call :check_exe "%~dp0.venv\Scripts\python.exe"
if not errorlevel 1 exit /b 0

rem A WindowsApps execution alias can pass WHERE but is not a real Python.
for /f "delims=" %%P in ('where.exe python.exe 2^>nul') do (
  call :check_exe "%%~P"
  if not errorlevel 1 exit /b 0
)
for /f "delims=" %%P in ('where.exe python3.exe 2^>nul') do (
  call :check_exe "%%~P"
  if not errorlevel 1 exit /b 0
)

rem Probe standard installations even when PATH / py launcher is missing.
for /d %%D in ("%LOCALAPPDATA%\Programs\Python\Python3*" "%ProgramFiles%\Python3*" "%SystemDrive%\Python3*") do (
  if exist "%%~fD\python.exe" (
    call :check_exe "%%~fD\python.exe"
    if not errorlevel 1 exit /b 0
  )
)
for %%P in (
  "%USERPROFILE%\miniconda3\python.exe"
  "%USERPROFILE%\anaconda3\python.exe"
  "%LOCALAPPDATA%\miniconda3\python.exe"
  "%LOCALAPPDATA%\anaconda3\python.exe"
  "%ProgramData%\miniconda3\python.exe"
  "%ProgramData%\anaconda3\python.exe"
) do (
  if exist "%%~P" (
    call :check_exe "%%~P"
    if not errorlevel 1 exit /b 0
  )
)

rem Registry / environment / user-local / other drive discovery via bundled PowerShell.
if exist "%~dp0FIND_PYTHON.ps1" (
  for /f "usebackq delims=" %%P in (`powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%~dp0FIND_PYTHON.ps1"`) do (
    call :check_exe "%%P"
    if not errorlevel 1 exit /b 0
  )
)

echo [ERROR] Cannot find a runnable Python 3.10+ interpreter.
echo [INFO] A Microsoft Store execution alias is not a Python installation.
echo [INFO] In PowerShell, run: py -0p
echo [INFO] Also run: where.exe python
echo [INFO] Run TIM_PYTHON_CHI_TIET.cmd for Registry and other drives.
echo [INFO] If installed elsewhere, run CHON_PYTHON.cmd to save the exact python.exe path.
echo [INFO] Or set TMB_PYTHON_OVERRIDE to python.exe.
exit /b 3

:check_exe
if "%~1"=="" exit /b 1
if not exist "%~1" exit /b 1
rem Skip the Microsoft Store alias without executing it.
echo(%~1 | findstr.exe /I /L /C:"\Microsoft\WindowsApps" >nul
if not errorlevel 1 exit /b 1
"%~1" -c "import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)" >nul 2>nul
if errorlevel 1 exit /b 1
set "TMB_PYTHON_EXE=%~1"
set "TMB_PYTHON_ARGS="
exit /b 0