# ==============================================================================
# Android Productivity Terminal & Dopamine Detox - Phone Manager
# ==============================================================================

function Resolve-Adb {
    # 1. Check system PATH
    $cmd = Get-Command "adb.exe" -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    # 2. Check local platform-tools relative to script
    $localAdb = Join-Path $PSScriptRoot "platform-tools\adb.exe"
    if (Test-Path $localAdb) { return $localAdb }

    # 3. Check Android SDK in user AppData
    if ($env:LOCALAPPDATA) {
        $appDataAdb = Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"
        if (Test-Path $appDataAdb) { return $appDataAdb }
    }

    # 4. Check common installation directories
    $candidates = @(
        "C:\platform-tools\adb.exe",
        "$env:ProgramFiles\Android\platform-tools\adb.exe",
        "${env:ProgramFiles(x86)}\Android\android-sdk\platform-tools\adb.exe"
    )
    foreach ($path in $candidates) {
        if (Test-Path $path) { return $path }
    }

    return $null
}

$ADB = Resolve-Adb
if ($ADB) {
    # Pre-warm ADB daemon so commands execute instantaneously without cold-start lag
    & $ADB start-server 2>$null | Out-Null
}

function Show-Header {
    Clear-Host
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "       ANDROID PRODUCTIVITY TERMINAL - PHONE MANAGER" -ForegroundColor Yellow
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [1] Temporarily ENABLE Google Play Store  (for app updates)" -ForegroundColor Green
    Write-Host "  [2] DISABLE Google Play Store          (restore lockdown)" -ForegroundColor Red
    Write-Host ""
    Write-Host "  [3] Mirror Phone Screen to PC          (scrcpy stream)" -ForegroundColor Cyan
    Write-Host "  [4] Toggle Display Mode: B/W <--> COLOR (quick toggle)" -ForegroundColor Magenta
    Write-Host "  [5] Express Battery, RAM & Security Perimeter Audit" -ForegroundColor White
    Write-Host ""
    Write-Host "  [6] Apply Full Minimalism Transformation (18-step setup)" -ForegroundColor DarkCyan
    Write-Host "  [7] Collect Usage Statistics & Dopamine Addiction Audit" -ForegroundColor Yellow
    Write-Host "  [8] Open Interactive HTML Reports & Dashboard" -ForegroundColor Blue
    Write-Host "  [9] Restore Default Stock Android Settings (Rollback)" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "  [0] Exit" -ForegroundColor Gray
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Cyan
}

function Test-DeviceConnection {
    $devsText = (& $ADB devices | Out-String)
    if ($devsText -notmatch "\tdevice") {
        Write-Host "`n[WARNING] Device not detected via ADB!" -ForegroundColor Yellow
        Write-Host "1. Connect your phone to PC using a USB cable." -ForegroundColor DarkGray
        Write-Host "2. Enable 'USB Debugging' in Developer Options." -ForegroundColor DarkGray
        Write-Host "3. Authorize 'Allow USB Debugging' on your phone screen.`n" -ForegroundColor DarkGray
        return $false
    }
    return $true
}

if (-not $ADB) {
    Write-Host "[ERROR] adb.exe was not found in PATH or standard Android SDK directories!" -ForegroundColor Red
    Write-Host "Download platform-tools: https://developer.android.com/tools/releases/platform-tools" -ForegroundColor Yellow
    Write-Host "Or place adb.exe inside a 'platform-tools' folder next to this script." -ForegroundColor Cyan
    Read-Host "`nPress Enter to exit..."
    exit 1
}

$running = $true
while ($running) {
    Show-Header
    $rawChoice = Read-Host "Select option [0-9]"
    
    if ($null -eq $rawChoice) {
        break
    }
    
    $choice = $rawChoice.Trim().ToLower()
    if ($choice -eq "") {
        continue
    }
    
    switch ($choice) {
        "1" {
            Clear-Host
            Write-Host "=== Enabling Google Play Store ===" -ForegroundColor Green
            if (Test-DeviceConnection) {
                & $ADB shell pm enable com.android.vending
                Write-Host "`n[+] SUCCESS! Google Play Store is enabled on device." -ForegroundColor Green
                Write-Host "Update required apps, then return here and choose [2] to lock it down again.`n" -ForegroundColor Yellow
            }
            Read-Host "Press Enter to return to menu..."
        }
        "2" {
            Clear-Host
            Write-Host "=== Freezing Google Play Store ===" -ForegroundColor Red
            if (Test-DeviceConnection) {
                & $ADB shell pm disable-user --user 0 com.android.vending
                Write-Host "`n[+] SUCCESS! Google Play Store is locked down." -ForegroundColor Green
                Write-Host "Perimeter sealed.`n" -ForegroundColor Cyan
            }
            Read-Host "Press Enter to return to menu..."
        }
        "3" {
            Clear-Host
            Write-Host "=== Launching Phone Screen Mirror (scrcpy) ===" -ForegroundColor Cyan
            $scrcpyCmd = Get-Command "scrcpy.exe" -ErrorAction SilentlyContinue
            $localScrcpy = Join-Path $PSScriptRoot "scrcpy.exe"
            
            if ($scrcpyCmd) {
                Start-Process "scrcpy.exe" -ArgumentList "--window-title", "Android Productivity Terminal"
                Write-Host "`n[+] Mirroring window launched via system scrcpy!`n" -ForegroundColor Green
            } elseif (Test-Path $localScrcpy) {
                Start-Process $localScrcpy -ArgumentList "--window-title", "Android Productivity Terminal"
                Write-Host "`n[+] Mirroring window launched via local scrcpy!`n" -ForegroundColor Green
            } else {
                Write-Host "[!] scrcpy executable was not found." -ForegroundColor Yellow
                Write-Host "Download scrcpy: https://github.com/Genymobile/scrcpy/releases" -ForegroundColor Cyan
                Write-Host "Place scrcpy.exe in this folder or add it to system PATH." -ForegroundColor Yellow
            }
            Read-Host "Press Enter to return to menu..."
        }
        "4" {
            Clear-Host
            Write-Host "=== Toggling Screen Color Mode ===" -ForegroundColor Magenta
            if (Test-DeviceConnection) {
                $toggleCmd = @'
cur=$(settings get system greyscale_mode)
if [ "$cur" = "1" ]; then
    settings put system greyscale_mode 0
    settings put secure accessibility_display_daltonizer_enabled 0
    settings put secure accessibility_display_daltonizer 0
    settings put secure reduce_bright_colors_activated 0
    echo "COLOR"
else
    settings put system greyscale_mode 1
    settings put secure accessibility_display_daltonizer 0
    settings put secure accessibility_display_daltonizer_enabled 1
    settings put secure reduce_bright_colors_activated 1
    echo "MONOCHROME"
fi
'@
                $mode = ($toggleCmd | & $ADB shell).Trim()
                if ($mode -match "COLOR") {
                    Write-Host "`n[+] Screen restored to FULL COLOR mode!`n" -ForegroundColor Green
                } else {
                    Write-Host "`n[+] Screen switched to strict MONOCHROME ('Gray Stone') mode!`n" -ForegroundColor Green
                }
            }
            Read-Host "Press Enter to return to menu..."
        }
        "5" {
            Clear-Host
            Write-Host "================= EXPRESS PERIMETER & SECURITY AUDIT =================" -ForegroundColor Cyan
            if (Test-DeviceConnection) {
                $auditScript = @'
echo "--- BATTERY & MEMORY METRICS ---"
dumpsys battery | grep -E 'level|temperature|status'
cat /proc/meminfo | head -n 2

echo "--- BROWSER RESOLVER PERIMETER ---"
cmd package resolve-activity http://google.com

echo "--- PRIVATE DNS (DoT) STATUS ---"
echo "DNS Mode: $(settings get global private_dns_mode) | Host: $(settings get global private_dns_specifier)"

echo "--- LOCKED VECTORS CHECK ---"
echo "Android Profiles / Users: $(pm list users)"
echo "VPN Consent Dialog: $(pm list packages -d --user 0 | grep vpndialogs)"
echo "Install unknown APKs (0=blocked): $(settings get secure install_non_market_apps)"
'@
                $auditOut = ($auditScript | & $ADB shell | Out-String)
                Write-Host $auditOut -ForegroundColor Green
                Write-Host "==========================================================================" -ForegroundColor Cyan
            }
            Read-Host "Press Enter to return to menu..."
        }
        "6" {
            Clear-Host
            Write-Host "=== Applying Full Minimalism Transformation ===" -ForegroundColor Cyan
            if (Test-DeviceConnection) {
                $applyScript = Join-Path $PSScriptRoot "scripts\apply_minimalism.ps1"
                if (Test-Path $applyScript) {
                    & $applyScript -AdbPath $ADB
                } else {
                    Write-Host "[!] apply_minimalism.ps1 not found at $applyScript" -ForegroundColor Red
                }
            }
            Read-Host "`nPress Enter to return to menu..."
        }
        "7" {
            Clear-Host
            Write-Host "=== Collecting Usage Statistics & Dopamine Analysis ===" -ForegroundColor Yellow
            $statsScript = Join-Path $PSScriptRoot "scripts\collect_stats.py"
            if (Test-Path $statsScript) {
                python $statsScript
            } else {
                Write-Host "[!] collect_stats.py not found at $statsScript" -ForegroundColor Red
            }
            Read-Host "`nPress Enter to return to menu..."
        }
        "8" {
            Clear-Host
            Write-Host "=== Opening Interactive Reports & Dashboards ===" -ForegroundColor Cyan
            $reportPath = Join-Path $PSScriptRoot "docs\index.html"
            if (-not (Test-Path $reportPath)) {
                $reportPath = Join-Path $PSScriptRoot "docs\step_by_step_transformation.html"
            }
            if (Test-Path $reportPath) {
                Start-Process $reportPath
                Write-Host "`n[+] Portal opened in your default web browser!" -ForegroundColor Green
            } else {
                Write-Host "[!] Report file not found: $reportPath" -ForegroundColor Yellow
            }
            Read-Host "`nPress Enter to return to menu..."
        }
        "9" {
            Clear-Host
            Write-Host "=== Restore Stock Default Settings (Rollback) ===" -ForegroundColor DarkYellow
            Write-Host "Are you sure you want to restore all stock settings, apps, colors, and DNS? (Y/N)" -ForegroundColor Yellow
            $ans = Read-Host
            if ($ans -match "^[yY]") {
                if (Test-DeviceConnection) {
                    $restoreScript = Join-Path $PSScriptRoot "scripts\restore_defaults.ps1"
                    if (Test-Path $restoreScript) {
                        & $restoreScript -AdbPath $ADB
                    } else {
                        Write-Host "[!] restore_defaults.ps1 not found at $restoreScript" -ForegroundColor Red
                    }
                }
            } else {
                Write-Host "`nOperation cancelled." -ForegroundColor Gray
            }
            Read-Host "`nPress Enter to return to menu..."
        }
        { $_ -in "0", "q", "exit" } {
            $running = $false
            Write-Host "Goodbye!" -ForegroundColor Green
        }
        default {
            Write-Host "Invalid option. Enter a number from 0 to 9." -ForegroundColor Red
            Start-Sleep -Milliseconds 800
        }
    }
}