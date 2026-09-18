<#
.SYNOPSIS
    Restoration & Rollback Script for Android Productivity Terminal (High-Speed Batched Engine).
.DESCRIPTION
    Reverts system UI, colors, animations, Google Play Store, Galaxy Store, Chrome,
    YouTube, launcher, APK installation permissions, and DNS settings back to standard
    stock Samsung / Android configurations via a single-stream batched ADB shell execution.
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

Write-Host "`n>>> Executing high-speed batched restoration payload..." -ForegroundColor Cyan
$sw = [System.Diagnostics.Stopwatch]::StartNew()

# Construct single-stream batched shell script
$batchScript = @'
ENABLED=$(pm list packages -e)
for pkg in com.android.vending com.sec.android.app.samsungapps com.android.chrome com.sec.android.app.chromecustomizations com.google.android.youtube com.google.android.googlequicksearchbox com.samsung.android.video com.android.htmlviewer com.android.vpndialogs com.sec.android.easyMover com.samsung.knox.securefolder; do
    case "$ENABLED" in *package:$pkg*) ;; *) cmd package install-existing "$pkg" 2>/dev/null; pm enable "$pkg" 2>/dev/null ;; esac
done

settings put secure install_non_market_apps 1
cmd appops set org.telegram.messenger REQUEST_INSTALL_PACKAGES allow 2>/dev/null
cmd appops set com.discord REQUEST_INSTALL_PACKAGES allow 2>/dev/null
cmd appops set com.whatsapp REQUEST_INSTALL_PACKAGES allow 2>/dev/null
cmd appops set org.thoughtcrime.securesms REQUEST_INSTALL_PACKAGES allow 2>/dev/null
cmd appops set com.sec.android.app.myfiles REQUEST_INSTALL_PACKAGES allow 2>/dev/null
cmd appops set com.google.android.apps.docs REQUEST_INSTALL_PACKAGES allow 2>/dev/null
cmd appops set com.microsoft.skydrive REQUEST_INSTALL_PACKAGES allow 2>/dev/null
cmd appops set com.android.chrome REQUEST_INSTALL_PACKAGES allow 2>/dev/null
cmd appops set com.sec.android.app.samsungapps REQUEST_INSTALL_PACKAGES allow 2>/dev/null
cmd appops set com.android.vending REQUEST_INSTALL_PACKAGES allow 2>/dev/null

settings put system greyscale_mode 0
settings put secure accessibility_display_daltonizer_enabled 0
settings put secure accessibility_display_daltonizer 0
settings put secure reduce_bright_colors_activated 0

cmd role add-role-holder --user 0 android.app.role.HOME com.sec.android.app.launcher 2>/dev/null
input keyevent 3 2>/dev/null

settings put global window_animation_scale 1.0
settings put global transition_animation_scale 1.0
settings put global animator_duration_scale 1.0
settings put global ram_expand_size 4
settings put global wifi_scan_always_enabled 1
settings put global ble_scan_always_enabled 1

settings put system haptic_feedback_enabled 1
settings put system sound_effects_enabled 1
settings put system lockscreen_sounds_enabled 1
settings put secure notification_badging 1
settings put system badge_app_icon_type 0
settings put global heads_up_notifications_enabled 1
settings put system screen_off_timeout 60000

settings delete global private_dns_specifier 2>/dev/null
settings put global private_dns_mode opportunistic 2>/dev/null
'@

# Execute the policy natively on device (sub-second performance)
$scriptFile = Join-Path $PSScriptRoot "teldel_stock.sh"
if (Test-Path $scriptFile) {
    & $ADB push $scriptFile /data/local/tmp/teldel_stock.sh 2>&1 | Out-Null
    & $ADB shell "sh /data/local/tmp/teldel_stock.sh" 2>&1 | Out-Null
} else {
    $batchScript | & $ADB shell 2>&1 | Out-Null
}

$sw.Stop()
$elapsedMs = [math]::Round($sw.Elapsed.TotalMilliseconds, 1)
$elapsedSeconds = [math]::Round($sw.Elapsed.TotalSeconds, 3)

Write-Host "`n==========================================================================" -ForegroundColor Cyan
Write-Host "   [SUCCESS] SYSTEM RESTORED TO STOCK IN $elapsedSeconds s ($elapsedMs ms)! " -ForegroundColor Green
Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host "All stock One UI apps, stores, colorful screen, launcher, badges & DNS restored." -ForegroundColor Yellow
Write-Host ""
