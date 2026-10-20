@echo off
setlocal EnableExtensions
chcp 65001 >nul
cd /d "%~dp0"
echo ==============================================================
echo  TONG MON BA DAO - JX1 SOURCE COMBAT INTAKE (READ ONLY)
echo ==============================================================
echo [SOURCE] E:\Source
echo [TOOLS ] E:\Tool JX
echo [OUTPUT] E:\TongMonBaDao_AssetVault\06_reports\JX1_Combat_Intake
if not exist "E:\Source\" (
  echo [ERROR] Folder E:\Source does not exist.
  pause
  exit /b 2
)
if not exist "E:\Tool JX\" (
  echo [ERROR] Folder E:\Tool JX does not exist.
  pause
  exit /b 2
)
call "%~dp0FIND_PYTHON.cmd"
if errorlevel 1 (
  echo [ERROR] No valid Python 3.10+. Run KIEM_TRA_PYTHON.cmd.
  pause
  exit /b 3
)
"%TMB_PYTHON_EXE%" %TMB_PYTHON_ARGS% "%~dp0jx_combat_intake.py" --source "E:\Source" --tool "E:\Tool JX" --out "E:\TongMonBaDao_AssetVault\06_reports\JX1_Combat_Intake"
set "CODE=%ERRORLEVEL%"
if not "%CODE%"=="0" (echo [ERROR] Inventory failed with code %CODE%) else (
  echo [DONE] JX1_COMBAT_SUMMARY.md and JX1_COMBAT_SOURCE_MANIFEST.json created.
  echo [FOLDER] E:\TongMonBaDao_AssetVault\06_reports\JX1_Combat_Intake
)
pause
exit /b %CODE%
