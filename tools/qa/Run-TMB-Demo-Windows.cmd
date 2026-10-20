@echo off
setlocal
set "MODE=Play"
if /I "%~1"=="-Focused" set "MODE=Focused"
if /I "%~1"=="Focused" set "MODE=Focused"
if /I "%~1"=="-ResetDemo" set "MODE=ResetDemo"
if /I "%~1"=="ResetDemo" set "MODE=ResetDemo"
if not "%~1"=="" if /I not "%~1"=="-Focused" if /I not "%~1"=="Focused" if /I not "%~1"=="-ResetDemo" if /I not "%~1"=="ResetDemo" (
    echo Dung: Run-TMB-Demo-Windows.cmd [-Focused ^| -ResetDemo]
    exit /b 2
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Run-TMB-Demo-Windows.ps1" -Mode "%MODE%"
exit /b %ERRORLEVEL%
