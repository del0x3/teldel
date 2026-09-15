@echo off
chcp 65001 >nul
title Collect Usage Statistics via ADB
cd /d "%~dp0"
echo ================================================================
echo    COLLECTING ANDROID USAGE & DOPAMINE STATS VIA ADB
echo ================================================================
echo.

where adb >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    set ADB=adb
    goto :run_adb
)
if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" (
    set "ADB=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"
    goto :run_adb
)
if exist "%~dp0platform-tools\adb.exe" (
    set "ADB=%~dp0platform-tools\adb.exe"
    goto :run_adb
)

echo [!] ADB not found in PATH or standard directories.
echo Please install Android platform-tools.
pause
exit /b 1

:run_adb
echo [*] Pulling dumpsys usagestats from connected phone...
"%ADB%" shell dumpsys usagestats > full_usagestats.txt
if %ERRORLEVEL% NEQ 0 (
    echo [!] Failed to dump usagestats. Ensure phone is connected with USB debugging.
    pause
    exit /b 1
)

echo [*] Pulling notification event dump...
"%ADB%" shell dumpsys notification > notif_dump.txt

echo.
echo [*] Parsing collected statistics with Python...
python parse_usage.py
python parse_multi.py
python deep_dopamine_miner.py

echo.
echo [+] Collection and parsing complete!
echo Parsed analytics saved to: data/parsed_stats.json, data/multi_interval_stats.json, data/deep_dopamine_analysis.json.
pause
