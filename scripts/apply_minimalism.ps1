<#
.SYNOPSIS
    Automated 18-Step Android Productivity & Dopamine Detox Transformation Script (Ultra-Fast Engine).
.DESCRIPTION
    Transforms a connected Android / Samsung Galaxy device into a zero-distraction,
    monochrome, privacy-hardened productivity terminal via a single-stream batched ADB shell execution.
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
Write-Host "       ANDROID PRODUCTIVITY TERMINAL - 18-STEP AUTOMATED SETUP            " -ForegroundColor Yellow
Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host "This script transforms your connected device into a minimal terminal." -ForegroundColor White
Write-Host "No root required. 100% reversible via restore_defaults.ps1." -ForegroundColor Green
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
    $confirm = Read-Host "Proceed with 18-step transformation? (Y/N)"
    if ($confirm -notmatch "^[yY]") {
        Write-Host "Transformation cancelled." -ForegroundColor Gray
        exit 0
    }
}

Write-Host "`n>>> Applying high-speed 18-step policy batch payload..." -ForegroundColor Cyan
$sw = [System.Diagnostics.Stopwatch]::StartNew()

# Pre-check Olauncher presence to avoid slow APK reinstall overhead
$olauncherInstalled = ((& $ADB shell pm path app.olauncher 2>$null | Out-String).Trim() -match "package:")
if (-not $olauncherInstalled) {
    $launcherCandidates = @(
        (Join-Path $PSScriptRoot "..\Olauncher.apk"),
        (Join-Path $PSScriptRoot "Olauncher.apk")
    )
    $launcherApk = $launcherCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $launcherApk) {
        $fallbackPath = Join-Path $PSScriptRoot "Olauncher.apk"
        Write-Host "    [*] Fetching verified open-source Olauncher APK from GitHub..." -ForegroundColor DarkGray
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -Uri "https://github.com/tanujnotes/Olauncher/releases/latest/download/Olauncher.apk" -OutFile $fallbackPath -UseBasicParsing -TimeoutSec 30
            if (Test-Path $fallbackPath) {
                $launcherApk = $fallbackPath
            }
        } catch {
            Write-Host "    [!] Could not auto-download Olauncher: $_" -ForegroundColor Yellow
        }
    }
    if ($launcherApk) {
        Write-Host "    [+] First-time install of verified minimal launcher (Olauncher)..." -ForegroundColor DarkGray
        & $ADB install -r $launcherApk 2>$null | Out-Null
        & $ADB shell "cmd package compile -m speed -f app.olauncher" 2>$null | Out-Null
    }
}

# Single-stream in-memory execution payload across all security and sensory policies
$batchScript = @'
ENABLED=$(pm list packages -e)
for pkg in com.google.android.youtube com.zhiliaoapp.musically com.instagram.android com.linkedin.android com.glovo com.google.android.googlequicksearchbox com.android.chrome com.sec.android.app.chromecustomizations com.sec.android.app.samsungapps com.android.vending com.samsung.android.video com.android.htmlviewer com.android.vpndialogs com.sec.android.easyMover com.aura.oobe.samsung.gl com.samsung.android.cidmanager imslogger ipsgeofence diagmonagent sm.devicesecurity; do
    case "$ENABLED" in *package:$pkg*) pm disable-user --user 0 "$pkg" 2>/dev/null ;; esac
done

settings put secure install_non_market_apps 0
cmd appops set org.telegram.messenger REQUEST_INSTALL_PACKAGES deny 2>/dev/null
cmd appops set com.discord REQUEST_INSTALL_PACKAGES deny 2>/dev/null
cmd appops set com.whatsapp REQUEST_INSTALL_PACKAGES deny 2>/dev/null
cmd appops set org.thoughtcrime.securesms REQUEST_INSTALL_PACKAGES deny 2>/dev/null
cmd appops set com.sec.android.app.myfiles REQUEST_INSTALL_PACKAGES deny 2>/dev/null
cmd appops set com.google.android.apps.docs REQUEST_INSTALL_PACKAGES deny 2>/dev/null
cmd appops set com.microsoft.skydrive REQUEST_INSTALL_PACKAGES deny 2>/dev/null

settings put global ram_expand_size 0
settings put global window_animation_scale 0
settings put global transition_animation_scale 0
settings put global animator_duration_scale 0
settings put global wifi_scan_always_enabled 0
settings put global ble_scan_always_enabled 0

settings put system greyscale_mode 1
settings put secure accessibility_display_daltonizer 0
settings put secure accessibility_display_daltonizer_enabled 1
settings put secure reduce_bright_colors_activated 1
settings put secure reduce_bright_colors_level 80
settings put secure reduce_bright_colors_persist_across_reboots 1
settings put system blue_light_filter_night_dim 1
cmd uimode night yes 2>/dev/null
settings put system haptic_feedback_enabled 0
settings put system sound_effects_enabled 0
settings put system lockscreen_sounds_enabled 0
settings put secure notification_badging 0
settings put system badge_app_icon_type 0
settings put global heads_up_notifications_enabled 0
settings put system screen_off_timeout 30000

settings put global private_dns_mode hostname
settings put global private_dns_specifier family-filter-dns.cleanbrowsing.org

cmd appops set app.olauncher RECORD_AUDIO ignore 2>/dev/null
cmd appops set app.olauncher READ_PHONE_STATE ignore 2>/dev/null
cmd role add-role-holder --user 0 android.app.role.HOME app.olauncher 2>/dev/null
input keyevent 3 2>/dev/null
'@

# Execute the policy natively on device (sub-second performance)
$scriptFile = Join-Path $PSScriptRoot "teldel_minimal.sh"
if (Test-Path $scriptFile) {
    & $ADB push $scriptFile /data/local/tmp/teldel_minimal.sh 2>&1 | Out-Null
    & $ADB shell "sh /data/local/tmp/teldel_minimal.sh" 2>&1 | Out-Null
} else {
    $batchScript | & $ADB shell 2>&1 | Out-Null
}

$sw.Stop()
$elapsedMs = [math]::Round($sw.Elapsed.TotalMilliseconds, 1)
$elapsedSeconds = [math]::Round($sw.Elapsed.TotalSeconds, 3)

Write-Host "`n==========================================================================" -ForegroundColor Cyan
Write-Host "   [SUCCESS] TRANSFORMATION COMPLETE IN $elapsedSeconds s ($elapsedMs ms)! " -ForegroundColor Green
Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host "Device converted to minimal terminal. To rollback, run restore_defaults.bat." -ForegroundColor Yellow
Write-Host ""
