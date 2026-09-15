@echo off
chcp 65001 >nul
title Android Productivity Terminal - Phone Manager
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0phone_manager.ps1"
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] The script ended with exit code: %ERRORLEVEL%
    pause
)