@echo off
chcp 65001 >nul
title Android Screen Mirroring (scrcpy)
cd /d "%~dp0"

where scrcpy >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Launching scrcpy from system PATH...
    start "" scrcpy --window-title "Android Screen Mirror"
    goto :done
)

if exist "%~dp0scrcpy.exe" (
    echo Launching scrcpy from current directory...
    start "" "%~dp0scrcpy.exe" --window-title "Android Screen Mirror"
    goto :done
)

echo [!] scrcpy was not found in PATH or the current folder.
echo To mirror your phone screen, download scrcpy:
echo https://github.com/Genymobile/scrcpy/releases
echo and extract scrcpy.exe into this folder or add it to system PATH.
echo.
pause

:done
