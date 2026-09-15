@echo off
chcp 65001 >nul
title Автоматическая трансформация в минималистичный терминал
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0apply_minimalism.ps1"
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Скрипт завершился с кодом: %ERRORLEVEL%
    pause
)
pause
