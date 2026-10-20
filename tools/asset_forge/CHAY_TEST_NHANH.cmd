@echo off
cd /d "%~dp0"
where py >nul 2>nul
if not errorlevel 1 (py -3 -m unittest discover -p "test_*.py" -v) else (python -m unittest discover -p "test_*.py" -v)
pause