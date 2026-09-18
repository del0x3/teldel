@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0scripts\wifi_guardian.ps1" -Action disconnect
pause
