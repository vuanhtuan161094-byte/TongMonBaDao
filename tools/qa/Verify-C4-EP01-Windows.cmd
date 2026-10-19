@echo off
setlocal EnableExtensions DisableDelayedExpansion
echo TONG MON BA DAO - C4-EP01 FOCUSED QA - TEMP CLONE / ISOLATED SAVE
echo No MAIN sync. No CI/FULL/MERGE. No changes to your live game folder.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Verify-C4-EP01-Windows.ps1" %*
set "QA_EXIT=%ERRORLEVEL%"
echo.
if not "%QA_EXIT%"=="0" (
  echo QA NOT PASSED. See C4_EP01_QA_... logs under your TEMP folder.
) else (
  echo Focused test launcher completed. Visual/manual review and Android remain separate.
)
echo Exit code: %QA_EXIT%
pause
exit /b %QA_EXIT%
