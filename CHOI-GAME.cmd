@echo off
setlocal EnableExtensions DisableDelayedExpansion
set "GAME_ROOT=%~dp0"
rem A trailing backslash before a closing quote is consumed by Windows argument parsing.
rem This checkout is always a directory, so trim exactly that final separator.
if "%GAME_ROOT:~-1%"=="\" set "GAME_ROOT=%GAME_ROOT:~0,-1%"
set "PROJECT=%GAME_ROOT%\godot"
set "GODOT=E:\TongMonBaDaoWorkspace\04_Tools\Godot\Godot_v4.7.2-stable_win64.exe"
set "GIT=C:\Program Files\Git\cmd\git.exe"
set "VERIFY=%GAME_ROOT%\tools\windows\run\Verify-TRI03Source.ps1"
set "STARTER=%GAME_ROOT%\tools\windows\run\Start-TRI03Game.ps1"
set "PROFILE=E:\TongMonBaDaoWorkspace\03_QA_Logs\TRI03_OWNER_FINAL_20261103\one_game_playtest_profile"
if defined TMB_TRI03_PLAY_PROFILE set "PROFILE=%TMB_TRI03_PLAY_PROFILE%"
set "IMPORT_STAMP=%PROFILE%\last_import_fingerprint.txt"
set "IMPORT_LOG=%PROFILE%\Logs\godot_import.log"
set "PLAY_LOG=%PROFILE%\Logs\godot_play.log"

if not exist "%GODOT%" (
  echo Official Godot 4.7.2 was not found: "%GODOT%"
  pause
  exit /b 2
)
if not exist "%PROJECT%\project.godot" (
  echo TONG MON BA DAO project was not found: "%PROJECT%"
  pause
  exit /b 3
)
if not exist "%GIT%" (
  echo Git required to verify the PR 67 source is missing: "%GIT%"
  pause
  exit /b 4
)
if not exist "%VERIFY%" (
  echo PR 67 source verifier is missing: "%VERIFY%"
  pause
  exit /b 5
)
if not exist "%STARTER%" (
  echo PR 67 verified game starter is missing: "%STARTER%"
  pause
  exit /b 5
)

if not exist "%PROFILE%\AppData\Roaming" mkdir "%PROFILE%\AppData\Roaming"
if not exist "%PROFILE%\AppData\Local" mkdir "%PROFILE%\AppData\Local"
if not exist "%PROFILE%\Logs" mkdir "%PROFILE%\Logs"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%VERIFY%" -GameRoot "%GAME_ROOT%" -ProfileRoot "%PROFILE%"
if errorlevel 1 (
  echo Source verification failed. No game was launched.
  pause
  exit /b 6
)

for /f "usebackq delims=" %%V in (`"%GODOT%" --version`) do set "GODOT_VERSION=%%V"
if /I not "%GODOT_VERSION%"=="4.7.2.stable.official.ed1daf0bf" (
  echo Unexpected Godot binary: %GODOT_VERSION%
  pause
  exit /b 7
)

set "APPDATA=%PROFILE%\AppData\Roaming"
set "LOCALAPPDATA=%PROFILE%\AppData\Local"
set "SOURCE_FINGERPRINT="
set "CHECKOUT_HEAD="
set "PR_SOURCE_SHA="
for /f "usebackq tokens=2 delims==" %%F in (`findstr /B /C:"source_fingerprint=" "%PROFILE%\Logs\source_verify.txt"`) do set "SOURCE_FINGERPRINT=%%F"
for /f "usebackq tokens=2 delims==" %%H in (`findstr /B /C:"checkout_head=" "%PROFILE%\Logs\source_verify.txt"`) do set "CHECKOUT_HEAD=%%H"
for /f "usebackq tokens=2 delims==" %%P in (`findstr /B /C:"upstream_pr_source=" "%PROFILE%\Logs\source_verify.txt"`) do set "PR_SOURCE_SHA=%%P"
if not defined SOURCE_FINGERPRINT (
  echo Source verifier did not produce a runtime fingerprint.
  pause
  exit /b 8
)
if not defined CHECKOUT_HEAD set "CHECKOUT_HEAD=unavailable"
if not defined PR_SOURCE_SHA set "PR_SOURCE_SHA=unavailable"
if /I "%TMB_VERIFY_ONLY%"=="1" (
  echo Source verification passed.
  echo Local Git checkout HEAD: %CHECKOUT_HEAD%
  echo Verified PR 67 source parent: %PR_SOURCE_SHA%
  echo Runtime fingerprint: %SOURCE_FINGERPRINT%
  echo Official Godot: %GODOT_VERSION%
  >>"%PROFILE%\Logs\launcher.log" echo [%date% %time%] preflight_only=1 checkout_head=%CHECKOUT_HEAD% pr_source_parent=%PR_SOURCE_SHA% fingerprint=%SOURCE_FINGERPRINT% godot=%GODOT_VERSION%
  exit /b 0
)
set "IMPORTED_FINGERPRINT="
if exist "%IMPORT_STAMP%" set /p IMPORTED_FINGERPRINT=<"%IMPORT_STAMP%"
if /I not "%IMPORTED_FINGERPRINT%"=="%SOURCE_FINGERPRINT%" (
  echo Importing verified PR 67 source fingerprint %SOURCE_FINGERPRINT%...
  "%GODOT%" --headless --editor --path "%PROJECT%" --import --quit --verbose --log-file "%IMPORT_LOG%"
  if errorlevel 1 (
    echo Godot import failed. See "%IMPORT_LOG%"
    pause
    exit /b 9
  )
  findstr /I /C:"SCRIPT ERROR:" /C:"Parse Error:" "%IMPORT_LOG%" >nul
  if not errorlevel 1 (
    echo Godot reported a script/parse error. See "%IMPORT_LOG%"
    pause
    exit /b 10
  )
  >"%IMPORT_STAMP%" echo %SOURCE_FINGERPRINT%
)

echo Starting TONG MON BA DAO PR 67 source-verified game at 1280x720.
echo Local Git checkout HEAD: %CHECKOUT_HEAD% (see source verifier for pinned runtime identity)
echo Verified PR 67 source parent: %PR_SOURCE_SHA%
echo Source fingerprint: %SOURCE_FINGERPRINT%
echo Godot: %GODOT_VERSION%
echo Isolated QA save profile: %APPDATA%\Godot\app_userdata\Tong Mon Ba Dao
>>"%PROFILE%\Logs\launcher.log" echo [%date% %time%] checkout_head=%CHECKOUT_HEAD% pr_source_parent=%PR_SOURCE_SHA% fingerprint=%SOURCE_FINGERPRINT% godot=%GODOT_VERSION%
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%STARTER%" -GodotPath "%GODOT%" -ProjectPath "%PROJECT%" -PlayLog "%PLAY_LOG%" -LauncherLog "%PROFILE%\Logs\launcher.log" -TimeoutSeconds 90
if errorlevel 1 (
  echo Game process did not become ready. See "%PLAY_LOG%" and "%PROFILE%\Logs\launcher.log"
  pause
  exit /b 11
)
exit /b 0
