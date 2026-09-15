@echo off
chcp 65001 >nul
title Automated Minimalism Terminal Transformation
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0apply_minimalism.ps1"
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] The script ended with exit code: %ERRORLEVEL%
    pause
)
pause
