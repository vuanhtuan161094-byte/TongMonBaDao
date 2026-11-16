@echo off
setlocal
set "TMB_PACKAGE_DIR=%~dp0"
set "TMB_SMOKE_ARG="
if /I "%~1"=="--smoke" set "TMB_SMOKE_ARG=-PackageSmoke"
powershell.exe -NoLogo -NoProfile -STA -ExecutionPolicy Bypass -File "%TMB_PACKAGE_DIR%Start-Test.ps1" -PackageRoot "%TMB_PACKAGE_DIR%." %TMB_SMOKE_ARG%
set "TMB_EXIT=%ERRORLEVEL%"
if not "%TMB_EXIT%"=="0" (
  echo.
  echo QA49 could not start. Review the latest log under LocalAppDataTMBQA49.
  pause
)
exit /b %TMB_EXIT%

