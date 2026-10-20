@echo off
setlocal
where py >nul 2>nul
if not errorlevel 1 (py -3 -m pip install Pillow) else (python -m pip install Pillow)
echo Pillow chi dung cho preview PNG, khong can de doc MAP hoac copy raw.
pause