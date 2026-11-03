@echo off
setlocal EnableExtensions
rem One-click official Windows QA+GPU bake on AN-03 isolated Git worktree.
rem Never fetch, reset, checkout, clean or merge; no game/save state touched.
set "ROOT=%~dp0"
set "QA_EXIT=-1"
set "BAKE_EXIT=-1"
echo === AN03 18-BONE GUIDE: GODOT 4.7.2 QA + 46 FRAMES ===
call "%ROOT%tools\windows\run\Verify-AN03-ModularRig.cmd" /capture
set "QA_EXIT=%ERRORLEVEL%"
if "%QA_EXIT%"=="0" (
  echo [AN03] Visual QA finished; starting real GPU bake.
  call "%ROOT%MO_AN03_BAKE.cmd"
  set "BAKE_EXIT=%ERRORLEVEL%"
) else (
  echo [AN03] QA failed; skipping GPU bake to preserve failure evidence.
)
echo [AN03] Packaging available engine logs, snapshots and frames...
powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%tools\windows\run\Package-AN03-Evidence.ps1" -RepositoryRoot "%ROOT%" -QaExitCode %QA_EXIT% -BakeExitCode %BAKE_EXIT%
set "PACKAGE_EXIT=%ERRORLEVEL%"
if not "%PACKAGE_EXIT%"=="0" echo [AN03] Evidence packaging FAILED: %PACKAGE_EXIT%
echo [AN03] QA exit=%QA_EXIT%, bake exit=%BAKE_EXIT%, package exit=%PACKAGE_EXIT%
echo [AN03] Upload godot\outputs\an03_lab\AN03_EVIDENCE.zip for diagnosis.
if not "%QA_EXIT%"=="0" exit /b %QA_EXIT%
if not "%BAKE_EXIT%"=="0" exit /b %BAKE_EXIT%
if not "%PACKAGE_EXIT%"=="0" exit /b %PACKAGE_EXIT%
echo [AN03] TECHNICAL GUIDE PASS only; owner's high-quality Shadow mesh remains unavailable.
exit /b 0
