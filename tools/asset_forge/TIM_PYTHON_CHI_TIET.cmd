@echo off
setlocal EnableExtensions
chcp 65001 >nul
cd /d "%~dp0"
echo ==== AF-04 FULL LOCAL PYTHON DISCOVERY ====
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%~dp0FIND_PYTHON.ps1" -Report
echo.
echo [INFO] If no PASS, run CHON_PYTHON.cmd to select the exact python.exe.
pause
