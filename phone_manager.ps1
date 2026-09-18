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

function Resolve-WirelessDevice {
    $cfgFile = Join-Path $PSScriptRoot "data\wireless_config.json"
    $savedIp = ""
    $savedPort = 5555
    if (Test-Path $cfgFile) {
        try {
            $cfg = Get-Content $cfgFile -Raw | ConvertFrom-Json
            if ($cfg.last_ip) { $savedIp = $cfg.last_ip }
            if ($cfg.port) { $savedPort = [int]$cfg.port }
        } catch {}
    }

    # Tier 1: Fast-path saved endpoint
    if ($savedIp) {
        & $ADB connect "$($savedIp):$savedPort" 2>$null | Out-Null
        $cur = (& $ADB devices 2>$null | Out-String)
        if ($cur -match "$($savedIp):$savedPort\tdevice") { return $true }
    }

    # Tier 2: mDNS ZeroConf (Android 11+ Wireless Debugging)
    $mdns = (& $ADB mdns services 2>$null | Out-String)
    if ($mdns -match '([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+):([0-9]+)') {
        & $ADB connect "$($Matches[1]):$($Matches[2])" 2>$null | Out-Null
        $cur = (& $ADB devices 2>$null | Out-String)
        if ($cur -match "\tdevice") { return $true }
    }

    # Tier 3: Dynamic Subnet ARP probe
    $arpOut = (arp -a | Out-String)
    $lines = $arpOut -split "`r?`n"
    foreach ($line in $lines) {
        if ($line -match '([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\s+([0-9a-fA-F-]+)\s+dynamic') {
            $cIp = $Matches[1]
            if ($cIp -notlike '169.254*' -and $cIp -notlike '224*' -and $cIp -notmatch '\.1$') {
                $probe = Test-NetConnection -ComputerName $cIp -Port 5555 -InformationLevel Quiet -WarningAction SilentlyContinue
                if ($probe) {
                    & $ADB connect "${cIp}:5555" 2>$null | Out-Null
                    $cur = (& $ADB devices 2>$null | Out-String)
                    if ($cur -match "\tdevice") {
                        try {
                            @{ last_ip = $cIp; port = 5555; auto_connect = $true } | ConvertTo-Json | Set-Content $cfgFile -Encoding UTF8
                        } catch {}
                        return $true
                    }
                }
            }
        }
    }
    return $false
}

function Get-DeviceStatus {
    $devsText = (& $ADB devices 2>$null | Out-String)
    
    # Auto-connect over Wi-Fi if no USB device is attached
    if ($devsText -notmatch "\tdevice") {
        [void](Resolve-WirelessDevice)
        $devsText = (& $ADB devices 2>$null | Out-String)
    }
    
    if ($devsText -notmatch "\tdevice") {
        return @{ Connected = $false }
    }
    
    $isWireless = ($devsText -match ":[0-9]{4,5}\tdevice")
    
    $query = @'
grey=$(settings get system greyscale_mode 2>/dev/null)
home=$(cmd role get-role-holders android.app.role.HOME 2>/dev/null)
vending=$(pm list packages -e com.android.vending 2>/dev/null)
bat=$(dumpsys battery 2>/dev/null | grep -o 'level: [0-9]*' | head -n 1 | cut -d ' ' -f 2)
dns=$(settings get global private_dns_mode 2>/dev/null)
wlan_ip=$(ip -4 addr show wlan0 2>/dev/null | grep -o 'inet [0-9.]*' | cut -d ' ' -f 2)
echo "$grey|$home|$vending|$bat|$dns|$wlan_ip"
'@
    $raw = ($query | & $ADB shell 2>$null | Out-String).Trim()
    $parts = $raw -split "\|"
    
    $wlanIp = if ($parts.Length -gt 5 -and $parts[5]) { $parts[5].Trim() } else { "" }
    
    # If on USB and Wi-Fi IP is discovered, ensure port 5555 is armed and config updated
    if (-not $isWireless -and $wlanIp) {
        $cfgFile = Join-Path $PSScriptRoot "data\wireless_config.json"
        try {
            $cfg = @{
                last_ip = $wlanIp
                port = 5555
                auto_connect = $true
            }
            $cfg | ConvertTo-Json | Set-Content $cfgFile -Encoding UTF8
        } catch {}
    }
    
    return @{
        Connected   = $true
        IsWireless  = $isWireless
        WlanIp      = $wlanIp
        IsGrey      = ($parts[0] -eq "1")
        IsMinimal   = ($parts[1] -match "olauncher")
        IsPlayStore = ($parts[2] -match "com.android.vending")
        Battery     = if ($parts[3]) { "$($parts[3])%" } else { "N/A" }
        IsDnsSecure = ($parts[4] -eq "hostname")
    }
}

function Show-Header {
    Clear-Host
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "       ANDROID PRODUCTIVITY TERMINAL - PHONE MANAGER" -ForegroundColor Yellow
    Write-Host "================================================================" -ForegroundColor Cyan
    
    $st = Get-DeviceStatus
    if ($st.Connected) {
        $modeText = if ($st.IsMinimal) { "MINIMAL TERMINAL" } else { "STOCK ONE UI" }
        $modeColor = if ($st.IsMinimal) { "Green" } else { "Yellow" }
        
        $colorText = if ($st.IsGrey) { "B/W" } else { "COLOR" }
        $colorColor = if ($st.IsGrey) { "DarkGray" } else { "Magenta" }
        
        $storeText = if ($st.IsPlayStore) { "UNFROZEN" } else { "LOCKED" }
        $storeColor = if ($st.IsPlayStore) { "Yellow" } else { "Green" }
        
        $dnsText = if ($st.IsDnsSecure) { "CleanBrowsing DoT" } else { "Default DHCP" }
        $connText = if ($st.IsWireless) { "Wi-Fi Wireless" } else { "USB Cable" }
        $connColor = if ($st.IsWireless) { "Cyan" } else { "Green" }
        
        Write-Host " [STATUS] Link: " -NoNewline -ForegroundColor DarkGray
        Write-Host "[$connText]" -NoNewline -ForegroundColor $connColor
        Write-Host " | Bat: " -NoNewline -ForegroundColor DarkGray
        Write-Host "$($st.Battery)" -NoNewline -ForegroundColor White
        Write-Host " | Mode: " -NoNewline -ForegroundColor DarkGray
        Write-Host "[$modeText]" -NoNewline -ForegroundColor $modeColor
        Write-Host " | Screen: " -NoNewline -ForegroundColor DarkGray
        Write-Host "[$colorText]" -ForegroundColor $colorColor
        Write-Host "          Store: " -NoNewline -ForegroundColor DarkGray
        Write-Host "[$storeText]" -NoNewline -ForegroundColor $storeColor
        Write-Host " | DNS: [$dnsText]" -NoNewline -ForegroundColor DarkGray
        if ($st.WlanIp) {
            Write-Host " | IP: $($st.WlanIp)" -ForegroundColor DarkGray
        } else {
            Write-Host ""
        }
    } else {
        Write-Host " [STATUS] Device: DISCONNECTED (Connect USB cable or enable Wi-Fi ADB)" -ForegroundColor DarkGray
    }
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [1] Temporarily ENABLE Google Play Store  (for app updates)" -ForegroundColor Green
    Write-Host "  [2] DISABLE Google Play Store          (restore lockdown)" -ForegroundColor Red
    Write-Host ""
    Write-Host "  [3] Mirror Phone Screen to PC          (scrcpy stream)" -ForegroundColor Cyan
    Write-Host "  [4] Toggle Display Mode: B/W <--> COLOR (fast toggle)" -ForegroundColor Magenta
    Write-Host "  [5] Express Battery, RAM & Security Perimeter Audit" -ForegroundColor White
    Write-Host ""
    Write-Host "  [6] Apply Full Minimalism Transformation (18-step setup)" -ForegroundColor DarkCyan
    Write-Host "  [7] Collect Usage Statistics & Dopamine Addiction Audit" -ForegroundColor Yellow
    Write-Host "  [8] Open Interactive HTML Reports & Dashboard" -ForegroundColor Blue
    Write-Host "  [9] Restore Default Stock Android Settings (Rollback)" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "  [W] Wireless ADB Menu: Wi-Fi Pairing / Cable-Free Mode" -ForegroundColor Cyan
    Write-Host "  [0] Exit" -ForegroundColor Gray
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Cyan
}

function Test-DeviceConnection {
    $st = Get-DeviceStatus
    if (-not $st.Connected) {
        Write-Host "`n[WARNING] Device not detected via USB or Wireless ADB!" -ForegroundColor Yellow
        Write-Host "1. Connect phone via USB OR ensure phone and PC are on same Wi-Fi." -ForegroundColor DarkGray
        Write-Host "2. Enable 'USB Debugging' (or 'Wireless Debugging') in Developer Options." -ForegroundColor DarkGray
        Write-Host "3. Authorize connection on your phone screen.`n" -ForegroundColor DarkGray
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
    settings put secure reduce_bright_colors_level 80
    settings put secure reduce_bright_colors_persist_across_reboots 1
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
        { $_ -in "W", "w" } {
            Clear-Host
            Write-Host "================================================================" -ForegroundColor Cyan
            Write-Host "       WIRELESS ADB (Wi-Fi) MANAGEMENT CONSOLE                  " -ForegroundColor Yellow
            Write-Host "================================================================" -ForegroundColor Cyan
            Write-Host ""
            
            $cfgFile = Join-Path $PSScriptRoot "data\wireless_config.json"
            $savedIp = ""
            if (Test-Path $cfgFile) {
                try {
                    $cfg = Get-Content $cfgFile -Raw | ConvertFrom-Json
                    $savedIp = $cfg.last_ip
                } catch {}
            }
            
            Write-Host "  Last Saved Phone Wi-Fi IP: " -NoNewline -ForegroundColor DarkGray
            if ($savedIp) { Write-Host "$savedIp:5555" -ForegroundColor Green } else { Write-Host "None" -ForegroundColor Yellow }
            Write-Host ""
            Write-Host "  [1] Switch USB to Wireless Mode (Arm port 5555 via USB)" -ForegroundColor Green
            Write-Host "  [2] Connect to Saved Phone IP ($savedIp:5555)" -ForegroundColor Cyan
            Write-Host "  [3] Connect to Custom IP:Port (Enter IP manually)" -ForegroundColor White
            Write-Host "  [4] Pair via Android 11+ Wireless Debugging (Enter Code)" -ForegroundColor Magenta
            Write-Host "  [5] Disconnect all Wireless ADB sessions" -ForegroundColor Red
            Write-Host ""
            Write-Host "  [0] Back to Main Menu" -ForegroundColor Gray
            Write-Host "================================================================" -ForegroundColor Cyan
            
            $wChoice = Read-Host "Select wireless option [0-5]"
            switch ($wChoice) {
                "1" {
                    Write-Host "`n>>> Querying device Wi-Fi IP and enabling TCP mode..." -ForegroundColor Cyan
                    $ip = (& $ADB shell "ip -4 addr show wlan0 | grep -o 'inet [0-9.]*' | cut -d ' ' -f 2" 2>$null | Out-String).Trim()
                    if ($ip) {
                        & $ADB tcpip 5555
                        $cfg = @{ last_ip = $ip; port = 5555; auto_connect = $true }
                        $cfg | ConvertTo-Json | Set-Content $cfgFile -Encoding UTF8
                        Write-Host "[+] Port 5555 enabled! Phone Wi-Fi IP: $ip" -ForegroundColor Green
                        Write-Host "[+] You can now unplug the USB cable and manage phone wirelessly!" -ForegroundColor Yellow
                    } else {
                        Write-Host "[!] Phone is not connected to Wi-Fi. Turn on Wi-Fi on phone first." -ForegroundColor Red
                    }
                }
                "2" {
                    if ($savedIp) {
                        Write-Host "`n>>> Connecting to $savedIp:5555..." -ForegroundColor Cyan
                        $res = (& $ADB connect "$savedIp:5555" | Out-String)
                        Write-Host $res -ForegroundColor Green
                    } else {
                        Write-Host "[!] No saved IP found. Connect via USB first or enter IP manually." -ForegroundColor Yellow
                    }
                }
                "3" {
                    $customIp = Read-Host "Enter Phone IP address (e.g. 192.168.0.108)"
                    $customPort = Read-Host "Enter Port (default 5555)"
                    if (-not $customPort) { $customPort = "5555" }
                    if ($customIp) {
                        Write-Host "`n>>> Connecting to ${customIp}:${customPort}..." -ForegroundColor Cyan
                        $res = (& $ADB connect "${customIp}:${customPort}" | Out-String)
                        Write-Host $res -ForegroundColor Green
                        $cfg = @{ last_ip = $customIp; port = [int]$customPort; auto_connect = $true }
                        $cfg | ConvertTo-Json | Set-Content $cfgFile -Encoding UTF8
                    }
                }
                "4" {
                    Write-Host "`n>>> Android 11+ Wireless Debugging Pairing" -ForegroundColor Cyan
                    Write-Host "1. On phone: Developer Options -> Wireless Debugging -> Pair device with pairing code" -ForegroundColor DarkGray
                    $pairHost = Read-Host "Enter IP & Port from phone screen (e.g. 192.168.0.108:37123)"
                    $pairCode = Read-Host "Enter 6-digit Wi-Fi Pairing Code"
                    if ($pairHost -and $pairCode) {
                        $res = (& $ADB pair $pairHost $pairCode | Out-String)
                        Write-Host $res -ForegroundColor Green
                    }
                }
                "5" {
                    Write-Host "`n>>> Disconnecting wireless sessions..." -ForegroundColor Yellow
                    & $ADB disconnect | Out-Host
                }
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