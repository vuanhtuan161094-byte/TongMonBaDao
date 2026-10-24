@echo off
setlocal
set "PACKAGE_DIR=%~dp0"
set "GODOT_EXE=%PACKAGE_DIR%Godot_v4.7.2-stable_win64.exe"
set "PROJECT_DIR=%PACKAGE_DIR%godot"
set "SAVE_ROOT=%PACKAGE_DIR%userdata"
if not exist "%GODOT_EXE%" (
  echo Missing portable Godot 4.7.2 executable.
  pause
  exit /b 2
)
if not exist "%PROJECT_DIR%\project.godot" (
  echo Missing Godot project.
  pause
  exit /b 3
)
if not exist "%SAVE_ROOT%\Roaming" mkdir "%SAVE_ROOT%\Roaming"
if not exist "%SAVE_ROOT%\Local" mkdir "%SAVE_ROOT%\Local"
set "APPDATA=%SAVE_ROOT%\Roaming"
set "LOCALAPPDATA=%SAVE_ROOT%\Local"
echo Launching the real P3.2 sect screen at the project-configured 1280x720 viewport.
echo Save data is isolated under: %SAVE_ROOT%
start "TMB MAP-D1B Option B" "%GODOT_EXE%" --path "%PROJECT_DIR%"
exit /b 0