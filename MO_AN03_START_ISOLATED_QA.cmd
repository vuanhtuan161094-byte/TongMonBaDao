@echo off
setlocal
rem Start from any checkout; create NEW separate E:\ QA worktree and execute.
rem Existing worktree or game save is never overwritten.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\windows\run\Start-AN03-IsolatedQA.ps1"
set "CODE=%ERRORLEVEL%"
if not "%CODE%"=="0" (
  echo AN03 QA blocked or failed with exit %CODE%.
  echo Review output; never delete an existing worktree just to rerun.
)
pause
exit /b %CODE%
