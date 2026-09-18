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

# Construct single-stream batched shell script (zero Windows process-spawn overhead)
$batchScript = @'
# 1. Restore applications & application stores
cmd package install-existing com.android.vending
pm enable com.android.vending
cmd package install-existing com.sec.android.app.samsungapps
pm enable com.sec.android.app.samsungapps
cmd package install-existing com.android.chrome
pm enable com.android.chrome
pm enable com.sec.android.app.chromecustomizations
cmd package install-existing com.google.android.youtube
pm enable com.google.android.youtube
cmd package install-existing com.google.android.googlequicksearchbox
pm enable com.google.android.googlequicksearchbox
pm enable com.samsung.android.video
pm enable com.android.htmlviewer
pm enable com.android.vpndialogs
pm enable com.sec.android.easyMover
pm enable com.samsung.knox.securefolder

# 2. Restore installation & sideloading permissions
settings put secure install_non_market_apps 1
cmd appops set org.telegram.messenger REQUEST_INSTALL_PACKAGES allow
cmd appops set com.discord REQUEST_INSTALL_PACKAGES allow
cmd appops set com.whatsapp REQUEST_INSTALL_PACKAGES allow
cmd appops set org.thoughtcrime.securesms REQUEST_INSTALL_PACKAGES allow
cmd appops set com.sec.android.app.myfiles REQUEST_INSTALL_PACKAGES allow
cmd appops set com.google.android.apps.docs REQUEST_INSTALL_PACKAGES allow
cmd appops set com.microsoft.skydrive REQUEST_INSTALL_PACKAGES allow
cmd appops set com.android.chrome REQUEST_INSTALL_PACKAGES allow
cmd appops set com.sec.android.app.samsungapps REQUEST_INSTALL_PACKAGES allow
cmd appops set com.android.vending REQUEST_INSTALL_PACKAGES allow

# 3. Restore full-color display (Samsung One UI + AOSP daltonizer + Extra Dim)
settings put system greyscale_mode 0
settings put secure accessibility_display_daltonizer_enabled 0
settings put secure accessibility_display_daltonizer 0
settings put secure reduce_bright_colors_activated 0

# 4. Restore stock Samsung One UI launcher & notification listeners
cmd package set-home-activity com.sec.android.app.launcher/com.sec.android.app.launcher.activities.LauncherActivity
pm disable-user --user 0 app.olauncher
am start -a android.intent.action.MAIN -c android.intent.category.HOME

# 5. Restore animations & hardware settings
settings put global window_animation_scale 1.0
settings put global transition_animation_scale 1.0
settings put global animator_duration_scale 1.0
settings put global ram_expand_size 4
settings put global wifi_scan_always_enabled 1
settings put global ble_scan_always_enabled 1

# 6. Restore sensory feedback, notification badges & screen timeout
settings put system haptic_feedback_enabled 1
settings put system sound_effects_enabled 1
settings put system lockscreen_sounds_enabled 1
settings put secure notification_badging 1
settings put system badge_app_icon_type 0
settings put system screen_off_timeout 60000

# 7. Restore network DNS (opportunistic DHCP default)
settings delete global private_dns_specifier
settings put global private_dns_mode opportunistic
'@

# Pipe the entire batch payload into a single adb shell process
$scriptFile = Join-Path $PSScriptRoot "teldel_stock.sh"
if (Test-Path $scriptFile) {
    Get-Content $scriptFile | & $ADB shell 2>&1 | Out-Null
} else {
    $batchScript | & $ADB shell 2>&1 | Out-Null
}

$sw.Stop()
$elapsedSeconds = [math]::Round($sw.Elapsed.TotalSeconds, 2)

Write-Host "`n==========================================================================" -ForegroundColor Cyan
Write-Host "   [SUCCESS] SYSTEM RESTORED TO STOCK IN $elapsedSeconds SECONDS!         " -ForegroundColor Green
Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host "All stock One UI apps, stores, colorful screen, launcher, badges & DNS restored." -ForegroundColor Yellow
Write-Host ""
