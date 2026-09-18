@echo off
chcp 65001 >nul
title Collect Usage Statistics & Dopamine Audit
cd /d "%~dp0"

echo ================================================================
echo    COLLECTING ANDROID USAGE & DOPAMINE STATS VIA ADB
echo ================================================================
echo.

where python >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [!] Python was not found in system PATH.
    echo Please install Python 3 or run via phone_manager.bat.
    pause
    exit /b 1
)

python "%~dp0collect_stats.py"
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Script ended with error code %ERRORLEVEL%.
    pause
    exit /b %ERRORLEVEL%
)
pause
