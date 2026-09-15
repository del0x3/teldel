@echo off
chcp 65001 >nul
title Трансляция экрана телефона (scrcpy)
cd /d "%~dp0"

where scrcpy >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Запуск scrcpy из PATH...
    start "" scrcpy --window-title "Android Screen Mirror"
    goto :done
)

if exist "%~dp0scrcpy.exe" (
    echo Запуск scrcpy из текущей папки...
    start "" "%~dp0scrcpy.exe" --window-title "Android Screen Mirror"
    goto :done
)

echo [!] scrcpy не обнаружен в PATH или в папке со скриптом.
echo Для трансляции экрана скачайте scrcpy:
echo https://github.com/Genymobile/scrcpy/releases
echo и распакуйте в эту папку либо добавьте в системный PATH.
echo.
pause

:done
