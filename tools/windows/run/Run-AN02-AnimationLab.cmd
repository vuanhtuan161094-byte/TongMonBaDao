@echo off
setlocal EnableExtensions
rem Standalone VIEW-ONLY source sprite lab. Never launches the canonical game scene.
for %%I in ("%~dp0..\..\..") do set "TMB_ROOT=%%~fI\"
if not defined TMB_GODOT set "TMB_GODOT=E:\Godot_v4.7.2-stable_win64.exe"
set "TMB_PROJECT=%TMB_ROOT%godot"
set "TMB_SCENE=res://scenes/labs/an02_animation_lab.tscn"
set "TMB_PROFILE=%TMB_ROOT%godot\outputs\an02_lab\isolated_userdata"
set "TMB_LOG_DIR=%TMB_ROOT%godot\outputs\an02_lab\logs"
if not exist "%TMB_GODOT%" (
    echo [AN-02] Official Godot 4.7.2 executable not found: "%TMB_GODOT%"
    echo Set TMB_GODOT to official Godot 4.7.2 path.
    pause
    exit /b 2
)
if not exist "%TMB_PROJECT%\project.godot" (
    echo [AN-02] Expected Godot project missing: "%TMB_PROJECT%"
    pause
    exit /b 3
)
if not exist "%TMB_PROJECT%\scenes\labs\an02_animation_lab.tscn" (
    echo [AN-02] Lab scene missing. Check out feature/an01-an02-shadow-animation-lab-20261103.
    pause
    exit /b 4
)
if not exist "%TMB_PROFILE%\Roaming" mkdir "%TMB_PROFILE%\Roaming" >nul 2>&1
if not exist "%TMB_PROFILE%\Local" mkdir "%TMB_PROFILE%\Local" >nul 2>&1
if not exist "%TMB_LOG_DIR%" mkdir "%TMB_LOG_DIR%" >nul 2>&1
if not exist "%TMB_PROFILE%\Roaming" (
    echo [AN-02] Cannot create isolated user-data profile.
    pause
    exit /b 5
)
set "APPDATA=%TMB_PROFILE%\Roaming"
set "LOCALAPPDATA=%TMB_PROFILE%\Local"
set "TMB_LOG=%TMB_LOG_DIR%\an02_lab_%RANDOM%_%RANDOM%.log"
echo [AN-02] Standalone Source A Animation Lab + Shadow sample
echo [AN-02] Isolated userdata: "%TMB_PROFILE%"
echo [AN-02] Log: "%TMB_LOG%"
"%TMB_GODOT%" --path "%TMB_PROJECT%" --resolution 1280x720 --log-file "%TMB_LOG%" "%TMB_SCENE%"
set "TMB_EXIT=%ERRORLEVEL%"
if not "%TMB_EXIT%"=="0" (
    echo [AN-02] Godot failed: exit %TMB_EXIT%. Inspect "%TMB_LOG%".
    pause
)
exit /b %TMB_EXIT%
