@echo off
chcp 65001 >nul
title Восстановление стандартных настроек Android (Rollback)
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0restore_defaults.ps1"
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Скрипт завершился с кодом: %ERRORLEVEL%
    pause
)
pause
