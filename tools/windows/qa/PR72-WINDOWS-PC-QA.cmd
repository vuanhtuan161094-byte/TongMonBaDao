@echo off
setlocal EnableExtensions
for %%I in ("%~dp0..\..\..") do set "TMB_QA_ROOT=%%~fI"
echo PR72 real Windows PC QA via canonical MO_GAME.cmd, isolated Save.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Run-PR72-Owner-PC-QA.ps1" %*
set "QA_RC=%ERRORLEVEL%"
echo QA exit=%QA_RC%. Evidence: E:\TongMonBaDaoWorkspace\03_QA_Logs\PR72_PC_QA
pause
exit /b %QA_RC%
