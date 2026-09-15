<#
.SYNOPSIS
    Restoration & Rollback Script for Android Productivity Terminal.
.DESCRIPTION
    Reverts system UI, colors, animations, Google Play Store, Chrome, and DNS settings
    back to standard stock Android configurations.
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
    Write-Error "adb.exe was not found. Please install Android platform-tools."
    exit 1
}

Clear-Host
Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host "          RESTORE DEFAULTS - ANDROID SYSTEM ROLLBACK SCRIPT               " -ForegroundColor Yellow
Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host "This script will restore stock colors, animations, Play Store, and DNS." -ForegroundColor White
Write-Host ""

$devs = (& $ADB devices | Out-String)
if ($devs -notmatch "\tdevice") {
    Write-Host "[!] No authorized ADB device detected." -ForegroundColor Red
    Write-Host "Please connect your phone, enable USB Debugging, and authorize this computer." -ForegroundColor Yellow
    exit 1
}

if (-not $Unattended) {
    $confirm = Read-Host "Are you sure you want to revert system settings? (Y/N)"
    if ($confirm -notmatch "^[yYдД]") {
        Write-Host "Rollback cancelled." -ForegroundColor Gray
        exit 0
    }
}

Write-Host "`n>>> [1/5] Re-enabling Google Play Store & Browser Services..." -ForegroundColor Cyan
& $ADB shell pm enable com.android.vending 2>$null
& $ADB shell pm enable com.android.chrome 2>$null
& $ADB shell pm enable com.sec.android.app.chromecustomizations 2>$null
& $ADB shell pm enable com.samsung.android.video 2>$null
& $ADB shell pm enable com.android.htmlviewer 2>$null
& $ADB shell pm enable com.android.vpndialogs 2>$null
& $ADB shell pm enable com.sec.android.easyMover 2>$null
& $ADB shell settings put secure install_non_market_apps 1
Write-Host "    Done: App stores and browsers re-enabled." -ForegroundColor Green

Write-Host "`n>>> [2/5] Restoring Full Color Display..." -ForegroundColor Cyan
& $ADB shell settings put secure accessibility_display_daltonizer_enabled 0
& $ADB shell settings put secure reduce_bright_colors_activated 0
Write-Host "    Done: Display returned to stock full color." -ForegroundColor Green

Write-Host "`n>>> [3/5] Restoring Standard Window Animations (1.0x)..." -ForegroundColor Cyan
& $ADB shell settings put global window_animation_scale 1.0
& $ADB shell settings put global transition_animation_scale 1.0
& $ADB shell settings put global animator_duration_scale 1.0
Write-Host "    Done: Stock animation duration restored." -ForegroundColor Green

Write-Host "`n>>> [4/5] Restoring Haptics, Sounds, Screen Timeout & Badges..." -ForegroundColor Cyan
& $ADB shell settings put system haptic_feedback_enabled 1
& $ADB shell settings put system sound_effects_enabled 1
& $ADB shell settings put system lockscreen_sounds_enabled 1
& $ADB shell settings put secure notification_badging 1
& $ADB shell settings put system screen_off_timeout 60000
& $ADB shell settings put global wifi_scan_always_enabled 1
& $ADB shell settings put global ble_scan_always_enabled 1
Write-Host "    Done: Haptics, system sounds, and notification badges re-enabled." -ForegroundColor Green

Write-Host "`n>>> [5/5] Resetting Private DNS to Automatic (Opportunistic)..." -ForegroundColor Cyan
& $ADB shell settings put global private_dns_mode opportunistic
& $ADB shell settings put global private_dns_specifier ""
Write-Host "    Done: DNS restored to standard network default." -ForegroundColor Green

Write-Host "`n==========================================================================" -ForegroundColor Cyan
Write-Host "   [SUCCESS] SYSTEM SETTINGS SUCCESSFULLY RESTORED TO STOCK!              " -ForegroundColor Green
Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host ""
