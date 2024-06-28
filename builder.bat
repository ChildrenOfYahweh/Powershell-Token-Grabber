@echo off
setlocal

cd /d %~dp0

python --version
if errorlevel 1 (
    echo Python not found
    pause
    exit /b 1
)

python -m pip install -r requirements.txt
if errorlevel 1 (
    echo Failed to install requirements
    pause
    exit /b 1
)
cls

python main.py
if errorlevel 1 (
    echo Failed to run main
    pause
    exit /b 1
)

pause
exit /b 0
