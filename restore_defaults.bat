@echo off
chcp 65001 >nul
title Restore Android Stock Settings (Rollback)
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0restore_defaults.ps1"
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] The script ended with exit code: %ERRORLEVEL%
    pause
)
pause
