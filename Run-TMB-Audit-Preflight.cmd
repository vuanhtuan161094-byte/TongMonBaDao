@echo off
setlocal EnableExtensions DisableDelayedExpansion
cd /d "%~dp0"
echo ===== TONG MON BA DAO — READ-ONLY PRE-FLIGHT =====
echo Project directory: %CD%
where git >nul 2>nul
if errorlevel 1 (
  echo BLOCKED: git.exe is unavailable.
  exit /b 2
)
git rev-parse --show-toplevel
if errorlevel 1 (
  echo BLOCKED: current folder is not a Git repository.
  exit /b 2
)
for /f %%i in ('git rev-parse HEAD') do set "TMB_CHECKOUT_SHA=%%i"
if not defined TMB_CHECKOUT_SHA (
  echo BLOCKED: cannot prove exact checkout SHA.
  exit /b 3
)
echo Exact checkout SHA: %TMB_CHECKOUT_SHA%
echo.
echo Local branches and registered worktrees; DO NOT delete or reset:
git worktree list --porcelain
echo.
echo Tracked or untracked changes; DO NOT clean/reset:
git status --short
echo.
echo Git remote configuration; this does NOT fetch or change HEAD:
git remote -v
echo.
if not defined TMB_GODOT set "TMB_GODOT=E:\Godot_v4.7.2-stable_win64_console.exe"
if not exist "%TMB_GODOT%" (
  echo BLOCKED: cannot find official Godot at "%TMB_GODOT%"
  echo Override TMB_GODOT with the installed Godot 4.7.2 console executable.
  echo No player save or project source was modified by this script.
  exit /b 4
)
echo Godot binary: %TMB_GODOT%
"%TMB_GODOT%" --version
if errorlevel 1 (
  echo BLOCKED: Godot executable did not return a version.
  exit /b 4
)
echo.
echo PRE-FLIGHT COMPLETED: evidence only; no game QA or manual GUI accepted.
echo Follow docs/operations/TMB_2026-10-27_ONE_SESSION_WINDOWS_EXECUTION.md
echo Do NOT mass-merge Draft PRs, overwrite saves, or launch parallel GUI tests.
exit /b 0
