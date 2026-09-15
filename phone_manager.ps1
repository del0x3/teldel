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
    Write-Host "  [4] Toggle Display Mode: B/W <--> COLOR (quick color toggle)" -ForegroundColor Magenta
    Write-Host "  [5] Express Battery, RAM & Security Perimeter Audit" -ForegroundColor White
    Write-Host ""
    Write-Host "  [6] Full Lockdown (Zero-Browser + YouTube + Play Store + DoT)" -ForegroundColor Red
    Write-Host "  [7] Open Interactive HTML Reports & Dopamine Dashboard" -ForegroundColor Blue
    Write-Host "  [8] Restore Default Stock Android Settings (Rollback)" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "  [9] Exit" -ForegroundColor Gray
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
    $rawChoice = Read-Host "Select option [1-9]"
    
    if ($null -eq $rawChoice) {
        break
    }
    
    $choice = $rawChoice.Trim()
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
                $status = (& $ADB shell settings get secure accessibility_display_daltonizer_enabled)
                if ($status) { $status = $status.Trim() }
                if ($status -eq "1") {
                    Write-Host "Current mode: MONOCHROME. Switching to FULL COLOR..." -ForegroundColor Yellow
                    & $ADB shell settings put secure accessibility_display_daltonizer_enabled 0
                    Write-Host "`n[+] Screen restored to FULL COLOR mode!`n" -ForegroundColor Green
                } else {
                    Write-Host "Current mode: FULL COLOR. Switching to MONOCHROME..." -ForegroundColor Yellow
                    & $ADB shell settings put secure accessibility_display_daltonizer 0
                    & $ADB shell settings put secure accessibility_display_daltonizer_enabled 1
                    Write-Host "`n[+] Screen switched to strict MONOCHROME ('Gray Stone') mode!`n" -ForegroundColor Green
                }
            }
            Read-Host "Press Enter to return to menu..."
        }
        "5" {
            Clear-Host
            Write-Host "================= EXPRESS PERIMETER & SECURITY AUDIT =================" -ForegroundColor Cyan
            if (Test-DeviceConnection) {
                Write-Host "`n--- BATTERY & MEMORY METRICS ---" -ForegroundColor Yellow
                & $ADB shell "dumpsys battery | grep -E 'level|temperature|status'"
                & $ADB shell "cat /proc/meminfo | head -n 2"
                
                Write-Host "`n--- BROWSER RESOLVER PERIMETER ---" -ForegroundColor Yellow
                $br = (& $ADB shell cmd package resolve-activity http://google.com)
                if ($br) { $br = $br.Trim() }
                Write-Host "HTTP Resolver Output: $br" -ForegroundColor Green

                Write-Host "`n--- PRIVATE DNS (DoT) STATUS ---" -ForegroundColor Yellow
                $dnsMode = (& $ADB shell settings get global private_dns_mode).Trim()
                $dnsHost = (& $ADB shell settings get global private_dns_specifier).Trim()
                Write-Host "DNS Mode: $dnsMode | Host: $dnsHost" -ForegroundColor Green

                Write-Host "`n--- LOCKED VECTORS CHECK ---" -ForegroundColor Yellow
                $users = (& $ADB shell pm list users)
                Write-Host "Android Profiles / Users: $users" -ForegroundColor Cyan
                $vpn = (& $ADB shell pm list packages -d --user 0 | Select-String "vpndialogs")
                Write-Host "VPN Consent Dialog: $vpn" -ForegroundColor Cyan
                $inst = (& $ADB shell settings get secure install_non_market_apps).Trim()
                Write-Host "Install unknown APKs (0=blocked): $inst" -ForegroundColor Cyan
                Write-Host "`n==========================================================================" -ForegroundColor Cyan
            }
            Read-Host "Press Enter to return to menu..."
        }
        "6" {
            Clear-Host
            Write-Host "=== Total Lockdown & Vector Sealing ===" -ForegroundColor Red
            if (Test-DeviceConnection) {
                Write-Host "[1/7] Disabling browsers and YouTube..." -ForegroundColor Yellow
                & $ADB shell pm disable-user --user 0 com.android.chrome
                & $ADB shell pm uninstall -k --user 0 com.android.chrome
                & $ADB shell pm uninstall -k --user 0 com.google.android.youtube
                & $ADB shell pm disable-user --user 0 com.samsung.android.video
                & $ADB shell pm disable-user --user 0 com.android.htmlviewer

                Write-Host "[2/7] Freezing application stores..." -ForegroundColor Yellow
                & $ADB shell pm uninstall -k --user 0 com.android.vending
                & $ADB shell pm uninstall -k --user 0 com.sec.android.app.samsungapps

                Write-Host "[3/7] Removing Termux backdoor..." -ForegroundColor Yellow
                & $ADB shell pm uninstall -k --user 0 com.termux

                Write-Host "[4/7] Purging Knox Secure Folder (User 150)..." -ForegroundColor Yellow
                & $ADB shell pm remove-user 150
                & $ADB shell pm disable-user --user 0 com.samsung.knox.securefolder

                Write-Host "[5/7] Locking VPN dialog tunnels..." -ForegroundColor Yellow
                & $ADB shell pm disable-user --user 0 com.android.vpndialogs
                & $ADB shell pm disable-user --user 0 com.sec.android.easyMover

                Write-Host "[6/7] Revoking APK installation permissions (Anti-Sideloading)..." -ForegroundColor Yellow
                & $ADB shell settings put secure install_non_market_apps 0
                & $ADB shell 'cmd appops set org.telegram.messenger REQUEST_INSTALL_PACKAGES deny; cmd appops set com.discord REQUEST_INSTALL_PACKAGES deny; cmd appops set com.whatsapp REQUEST_INSTALL_PACKAGES deny; cmd appops set org.thoughtcrime.securesms REQUEST_INSTALL_PACKAGES deny; cmd appops set com.sec.android.app.myfiles REQUEST_INSTALL_PACKAGES deny; cmd appops set com.google.android.apps.docs REQUEST_INSTALL_PACKAGES deny; cmd appops set com.microsoft.skydrive REQUEST_INSTALL_PACKAGES deny'

                Write-Host "[7/7] Enforcing DNS-over-TLS CleanBrowsing Family Shield..." -ForegroundColor Yellow
                & $ADB shell settings put global private_dns_mode hostname
                & $ADB shell settings put global private_dns_specifier family-filter-dns.cleanbrowsing.org

                Write-Host "`n[+] PERIMETER FULLY LOCKED DOWN ACROSS ALL VECTORS!" -ForegroundColor Green
            }
            Read-Host "`nPress Enter to return to menu..."
        }
        "7" {
            Clear-Host
            Write-Host "=== Opening Interactive Reports & Dashboards ===" -ForegroundColor Cyan
            $reportPath = Join-Path $PSScriptRoot "step_by_step_transformation.html"
            if (Test-Path $reportPath) {
                Start-Process $reportPath
                Write-Host "`n[+] Report opened in your default web browser!" -ForegroundColor Green
            } else {
                Write-Host "[!] Report file not found: $reportPath" -ForegroundColor Yellow
            }
            Read-Host "`nPress Enter to return to menu..."
        }
        "8" {
            Clear-Host
            Write-Host "=== Restore Stock Default Settings (Rollback) ===" -ForegroundColor DarkYellow
            Write-Host "Are you sure you want to unfreeze Play Store, restore colors, animations, and standard DNS? (Y/N)" -ForegroundColor Yellow
            $ans = Read-Host
            if ($ans -match "^[yY]") {
                if (Test-DeviceConnection) {
                    Write-Host "`n[1/6] Enabling Google Play Store..." -ForegroundColor Cyan
                    & $ADB shell pm enable com.android.vending

                    Write-Host "[2/6] Restoring Full Color Display..." -ForegroundColor Cyan
                    & $ADB shell settings put secure accessibility_display_daltonizer_enabled 0
                    & $ADB shell settings put secure reduce_bright_colors_activated 0

                    Write-Host "[3/6] Restoring Standard Window Animations (1.0x)..." -ForegroundColor Cyan
                    & $ADB shell settings put global window_animation_scale 1.0
                    & $ADB shell settings put global transition_animation_scale 1.0
                    & $ADB shell settings put global animator_duration_scale 1.0

                    Write-Host "[4/6] Restoring Haptics and System Sounds..." -ForegroundColor Cyan
                    & $ADB shell settings put system haptic_feedback_enabled 1
                    & $ADB shell settings put system sound_effects_enabled 1
                    & $ADB shell settings put system lockscreen_sounds_enabled 1

                    Write-Host "[5/6] Resetting Private DNS to Automatic (Opportunistic)..." -ForegroundColor Cyan
                    & $ADB shell settings put global private_dns_mode opportunistic
                    & $ADB shell settings put global private_dns_specifier ""

                    Write-Host "[6/6] Restoring Notification Badges..." -ForegroundColor Cyan
                    & $ADB shell settings put secure notification_badging 1

                    Write-Host "`n[+] Stock system settings successfully restored!" -ForegroundColor Green
                }
            } else {
                Write-Host "`nOperation cancelled." -ForegroundColor Gray
            }
            Read-Host "`nPress Enter to return to menu..."
        }
        "9" {
            $running = $false
            Write-Host "Goodbye!" -ForegroundColor Green
        }
        default {
            Write-Host "Invalid option. Enter a number from 1 to 9." -ForegroundColor Red
            Start-Sleep -Milliseconds 800
        }
    }
}