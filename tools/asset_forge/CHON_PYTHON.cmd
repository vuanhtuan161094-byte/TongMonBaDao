@echo off
setlocal EnableExtensions
chcp 65001 >nul
cd /d "%~dp0"
powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File "%~dp0CHON_PYTHON.ps1"
if errorlevel 1 (
  echo [HELP] If Python is not installed, installing official Python 3.10+ may be necessary.
)
pause
