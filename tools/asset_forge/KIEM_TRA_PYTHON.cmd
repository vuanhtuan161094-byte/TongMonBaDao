@echo off
setlocal EnableExtensions
chcp 65001 >nul
cd /d "%~dp0"
echo ==== AF-04 PYTHON DIAGNOSTICS ====
call "%~dp0FIND_PYTHON.cmd"
if errorlevel 1 goto :missing
echo [PASS] Python located: %TMB_PYTHON_EXE% %TMB_PYTHON_ARGS%
"%TMB_PYTHON_EXE%" %TMB_PYTHON_ARGS% -c "import sys; print('Executable:',sys.executable); print('Version:',sys.version.split()[0])"
echo [INFO] Ready to run MO_ASSET_FORGE_STUDIO.cmd
pause
exit /b 0
:missing
echo [INFO] Available registered Python versions (if launcher installed):
py -0p 2>nul
echo [INFO] Registry / other-drive Python candidates (no full-disk scan):
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%~dp0FIND_PYTHON.ps1" -Report
echo [INFO] python.exe candidates in PATH:
where.exe python.exe 2>nul
echo [NEXT] If you have Python elsewhere: run CHON_PYTHON.cmd, browse to python.exe.
pause
exit /b 3