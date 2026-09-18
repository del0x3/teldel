<#
.SYNOPSIS
    Restoration & Rollback Script for Android Productivity Terminal.
.DESCRIPTION
    Reverts system UI, colors, animations, Google Play Store, Galaxy Store, Chrome,
    YouTube, launcher, APK installation permissions, and DNS settings back to standard
    stock Samsung / Android configurations.
#>

[CmdletBinding()]
param(
    [switch]$Unattended,
    [string]$AdbPath
)

function Resolve-Adb {
    if ($AdbPath -and (Test-Path $AdbPath)) { return $AdbPath }
    $cmd = Get-Command "adb.exe" -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $localAdb = Join-Path $PSScriptRoot "platform-tools\adb.exe"
    if (Test-Path $localAdb) { return $localAdb }
    $parentAdb = Join-Path $PSScriptRoot "..\platform-tools\adb.exe"
    if (Test-Path $parentAdb) { return $parentAdb }
    if ($env:LOCALAPPDATA) {
        $appDataAdb = Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"
        if (Test-Path $appDataAdb) { return $appDataAdb }
    }
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
if (-not $ADB) {
    Write-Error "adb.exe was not found. Please install Android platform-tools or specify -AdbPath."
    exit 1
}

Clear-Host
Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host "          RESTORE DEFAULTS - ANDROID SYSTEM ROLLBACK SCRIPT               " -ForegroundColor Yellow
Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host "This script will completely restore stock Samsung One UI settings:" -ForegroundColor White
Write-Host " - Reinstalls and unfreezes Chrome, YouTube, Play Store & Galaxy Store" -ForegroundColor Gray
Write-Host " - Restores stock colorful display (disables Samsung grayscale & Extra Dim)" -ForegroundColor Gray
Write-Host " - Restores stock Samsung One UI launcher" -ForegroundColor Gray
Write-Host " - Restores standard 1.0x animations, haptics, sounds, badges & timeout" -ForegroundColor Gray
Write-Host " - Restores APK installation permissions & default network DNS" -ForegroundColor Gray
Write-Host ""

$devs = (& $ADB devices | Out-String)
if ($devs -notmatch "\tdevice") {
    Write-Host "[!] No authorized ADB device detected." -ForegroundColor Red
    Write-Host "Please connect your phone, enable USB Debugging, and authorize this computer." -ForegroundColor Yellow
    exit 1
}

$deviceModel = (& $ADB shell getprop ro.product.model).Trim()
Write-Host "[+] Connected Device: $deviceModel" -ForegroundColor Green
Write-Host ""

if (-not $Unattended) {
    $confirm = Read-Host "Are you sure you want to revert all system restrictions to stock? (Y/N)"
    if ($confirm -notmatch "^[yY]") {
        Write-Host "Rollback cancelled." -ForegroundColor Gray
        exit 0
    }
}

Write-Host "`n>>> [1/7] Re-installing and Unfreezing Applications & Stores..." -ForegroundColor Cyan

# Known core packages to reinstall and enable
$corePackages = @(
    "com.android.vending",
    "com.sec.android.app.samsungapps",
    "com.android.chrome",
    "com.sec.android.app.chromecustomizations",
    "com.google.android.youtube",
    "com.google.android.googlequicksearchbox",
    "com.samsung.android.video",
    "com.android.htmlviewer",
    "com.android.vpndialogs",
    "com.sec.android.easyMover",
    "com.samsung.knox.securefolder",
    "ua.gov.reserveplus",
    "ua.alfabank.mobile.android",
    "ua.otpbank.android",
    "com.azure.authenticator"
)

foreach ($pkg in $corePackages) {
    & $ADB shell cmd package install-existing $pkg 2>$null | Out-Null
    & $ADB shell pm enable $pkg 2>$null | Out-Null
}

# Scan for any remaining packages uninstalled for user 0 and reinstall them
try {
    $allPkgs = (& $ADB shell pm list packages -u | Out-String) -split "`r?`n" | Where-Object { $_ -match "^package:" } | ForEach-Object { $_.Substring(8).Trim() }
    $instPkgs = (& $ADB shell pm list packages | Out-String) -split "`r?`n" | Where-Object { $_ -match "^package:" } | ForEach-Object { $_.Substring(8).Trim() }
    $instSet = New-Object System.Collections.Generic.HashSet[string]
    foreach ($p in $instPkgs) { [void]$instSet.Add($p) }

    foreach ($pkg in $allPkgs) {
        if (-not $instSet.Contains($pkg)) {
            $res = (& $ADB shell cmd package install-existing $pkg 2>&1 | Out-String)
            if ($res -match "NameNotFoundException|doesn't exist") {
                # Third-party user app with orphaned data blocking Play Store: purge ghost lock
                & $ADB shell pm uninstall $pkg 2>$null | Out-Null
            } else {
                & $ADB shell pm enable $pkg 2>$null | Out-Null
            }
        }
    }
} catch {
    Write-Host "    [!] Note: Automatic package scan encountered a minor error: $_" -ForegroundColor DarkGray
}

# Unfreeze any remaining disabled packages
$disabledPkgs = (& $ADB shell pm list packages -d | Out-String) -split "`r?`n" | Where-Object { $_ -match "^package:" } | ForEach-Object { $_.Substring(8).Trim() }
foreach ($pkg in $disabledPkgs) {
    if ($pkg) {
        & $ADB shell pm enable $pkg 2>$null | Out-Null
    }
}
Write-Host "    Done: Play Store, Galaxy Store, Chrome, YouTube & apps re-enabled." -ForegroundColor Green

Write-Host "`n>>> [2/7] Restoring Sideloading & Installation Permissions..." -ForegroundColor Cyan
& $ADB shell settings put secure install_non_market_apps 1
$installers = @(
    "org.telegram.messenger",
    "com.discord",
    "com.whatsapp",
    "org.thoughtcrime.securesms",
    "com.sec.android.app.myfiles",
    "com.google.android.apps.docs",
    "com.microsoft.skydrive",
    "com.android.chrome",
    "com.sec.android.app.samsungapps",
    "com.android.vending"
)
foreach ($inst in $installers) {
    & $ADB shell cmd appops set $inst REQUEST_INSTALL_PACKAGES allow 2>$null
}
Write-Host "    Done: App installation permissions restored." -ForegroundColor Green

Write-Host "`n>>> [3/7] Restoring Full Color Display..." -ForegroundColor Cyan
& $ADB shell settings put system greyscale_mode 0
& $ADB shell settings put secure accessibility_display_daltonizer_enabled 0
& $ADB shell settings put secure accessibility_display_daltonizer 0
& $ADB shell settings put secure reduce_bright_colors_activated 0
Write-Host "    Done: Display returned to stock full color (monochrome deactivated)." -ForegroundColor Green

Write-Host "`n>>> [4/7] Restoring Stock Launcher (Samsung One UI Home)..." -ForegroundColor Cyan
$samsungHome = "com.sec.android.app.launcher/com.sec.android.app.launcher.activities.LauncherActivity"
& $ADB shell cmd package set-home-activity $samsungHome 2>$null | Out-Null
& $ADB shell pm uninstall app.olauncher 2>$null | Out-Null
& $ADB shell am start -a android.intent.action.MAIN -c android.intent.category.HOME 2>$null | Out-Null
Write-Host "    Done: Stock Samsung launcher restored and Olauncher uninstalled." -ForegroundColor Green

Write-Host "`n>>> [5/7] Restoring Standard Window Animations (1.0x)..." -ForegroundColor Cyan
& $ADB shell settings put global window_animation_scale 1.0
& $ADB shell settings put global transition_animation_scale 1.0
& $ADB shell settings put global animator_duration_scale 1.0
Write-Host "    Done: Stock animation duration restored." -ForegroundColor Green

Write-Host "`n>>> [6/7] Restoring Haptics, Sounds, Screen Timeout & Badges..." -ForegroundColor Cyan
& $ADB shell settings put system haptic_feedback_enabled 1
& $ADB shell settings put system sound_effects_enabled 1
& $ADB shell settings put system lockscreen_sounds_enabled 1
& $ADB shell settings put secure notification_badging 1
& $ADB shell settings put system screen_off_timeout 60000
& $ADB shell settings put global wifi_scan_always_enabled 1
& $ADB shell settings put global ble_scan_always_enabled 1
Write-Host "    Done: Haptics, system sounds, and notification badges re-enabled." -ForegroundColor Green

Write-Host "`n>>> [7/7] Resetting Private DNS to Automatic (Opportunistic)..." -ForegroundColor Cyan
& $ADB shell settings delete global private_dns_specifier 2>$null | Out-Null
& $ADB shell settings put global private_dns_mode opportunistic
Write-Host "    Done: DNS restored to standard network default." -ForegroundColor Green

Write-Host "`n==========================================================================" -ForegroundColor Cyan
Write-Host "   [SUCCESS] SYSTEM SETTINGS SUCCESSFULLY RESTORED TO STOCK!              " -ForegroundColor Green
Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host ""
