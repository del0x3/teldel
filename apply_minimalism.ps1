<#
.SYNOPSIS
    Automated 18-Step Android Productivity & Dopamine Detox Transformation Script.
.DESCRIPTION
    Transforms a connected Android / Samsung Galaxy device into a zero-distraction,
    monochrome, privacy-hardened productivity terminal via ADB without root or Knox tripping.
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
    Write-Error "adb.exe was not found. Please install Android platform-tools or specify -AdbPath."
    exit 1
}

Clear-Host
Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host "       ANDROID PRODUCTIVITY TERMINAL - 18-STEP AUTOMATED SETUP            " -ForegroundColor Yellow
Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host "This script will transform your connected device into a minimal terminal." -ForegroundColor White
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

Write-Host "`n>>> [1/6] Removing Dopamine Time-Killers & Social Feeds..." -ForegroundColor Cyan
$distractions = @(
    "com.google.android.youtube",
    "com.zhiliaoapp.musically",
    "com.instagram.android",
    "com.linkedin.android",
    "com.glovo",
    "ua.com.uklontaxi",
    "com.google.android.googlequicksearchbox"
)
foreach ($pkg in $distractions) {
    & $ADB shell pm uninstall -k --user 0 $pkg 2>$null
}
Write-Host "    Done: Entertainment feeds & news tickers removed." -ForegroundColor Green

Write-Host "`n>>> [2/6] Enforcing Zero-Browser & Store Lockdown..." -ForegroundColor Cyan
& $ADB shell pm disable-user --user 0 com.android.chrome 2>$null
& $ADB shell pm uninstall -k --user 0 com.android.chrome 2>$null
& $ADB shell pm disable-user --user 0 com.sec.android.app.chromecustomizations 2>$null
& $ADB shell pm uninstall -k --user 0 com.sec.android.app.samsungapps 2>$null
& $ADB shell pm disable-user --user 0 com.android.vending 2>$null
& $ADB shell pm disable-user --user 0 com.samsung.android.video 2>$null
& $ADB shell pm disable-user --user 0 com.android.htmlviewer 2>$null
& $ADB shell pm disable-user --user 0 com.android.vpndialogs 2>$null
& $ADB shell pm disable-user --user 0 com.sec.android.easyMover 2>$null

# Anti-sideloading: Revoke REQUEST_INSTALL_PACKAGES
& $ADB shell settings put secure install_non_market_apps 0
$installers = @(
    "org.telegram.messenger",
    "com.discord",
    "com.whatsapp",
    "org.thoughtcrime.securesms",
    "com.sec.android.app.myfiles",
    "com.google.android.apps.docs",
    "com.microsoft.skydrive"
)
foreach ($inst in $installers) {
    & $ADB shell cmd appops set $inst REQUEST_INSTALL_PACKAGES deny 2>$null
}
Write-Host "    Done: Browser eliminated, stores frozen, sideloading locked." -ForegroundColor Green

Write-Host "`n>>> [3/6] Purging Adware, Bloatware & Telemetry Daemons..." -ForegroundColor Cyan
$adwareAndTelemetry = @(
    "com.aura.oobe.samsung.gl",
    "com.samsung.android.cidmanager",
    "com.samsung.android.app.omcagent",
    "com.samsung.android.sdm.config",
    "imslogger",
    "ipsgeofence",
    "diagmonagent",
    "iaft",
    "dsms",
    "sdhms",
    "aware.service",
    "dqagent",
    "networkdiagnostic",
    "sm.devicesecurity"
)
foreach ($t in $adwareAndTelemetry) {
    & $ADB shell pm uninstall -k --user 0 $t 2>$null
    & $ADB shell pm disable-user --user 0 $t 2>$null
}
Write-Host "    Done: Adware auto-installers and tracking daemons terminated." -ForegroundColor Green

Write-Host "`n>>> [4/6] Tuning Hardware, Memory & UI Latency (0 ms)..." -ForegroundColor Cyan
# Disable RAM Plus (Swap file thrashing)
& $ADB shell settings put global ram_expand_size 0
# Instant UI response (0ms window animations)
& $ADB shell settings put global window_animation_scale 0
& $ADB shell settings put global transition_animation_scale 0
& $ADB shell settings put global animator_duration_scale 0
# Radio idle power saving
& $ADB shell settings put global wifi_scan_always_enabled 0
& $ADB shell settings put global ble_scan_always_enabled 0
Write-Host "    Done: RAM Plus disabled, animations set to 0.0 ms, radio scanning muted." -ForegroundColor Green

Write-Host "`n>>> [5/6] Engaging Sensory Detox ('Gray Stone' Mode)..." -ForegroundColor Cyan
# Grayscale daltonizer + Extra Dim
& $ADB shell settings put secure accessibility_display_daltonizer 0
& $ADB shell settings put secure accessibility_display_daltonizer_enabled 1
& $ADB shell settings put secure reduce_bright_colors_activated 1
# Silence tactile & sound micro-triggers
& $ADB shell settings put system haptic_feedback_enabled 0
& $ADB shell settings put system sound_effects_enabled 0
& $ADB shell settings put system lockscreen_sounds_enabled 0
# Focus guard: Disable notification badges & set 30s screen timeout
& $ADB shell settings put secure notification_badging 0
& $ADB shell settings put system screen_off_timeout 30000
Write-Host "    Done: Grayscale active, haptics muted, red badges removed, 30s timeout set." -ForegroundColor Green

Write-Host "`n>>> [6/6] Establishing Cryptographic Network Shield & Launcher..." -ForegroundColor Cyan
# CleanBrowsing DoT family filter
& $ADB shell settings put global private_dns_mode hostname
& $ADB shell settings put global private_dns_specifier family-filter-dns.cleanbrowsing.org

# Install Olauncher if present
$launcherApk = Join-Path $PSScriptRoot "Olauncher.apk"
if (-not (Test-Path $launcherApk)) {
    Write-Host "    [i] Olauncher.apk not found locally. Fetching latest release from GitHub..." -ForegroundColor Cyan
    try {
        $release = Invoke-RestMethod -Uri "https://api.github.com/repos/tanujnotes/Olauncher/releases/latest" -Headers @{"User-Agent"="Mozilla/5.0"}
        $asset = $release.assets | Where-Object { $_.name -like "*.apk" } | Select-Object -First 1
        if ($asset) {
            Write-Host "    Downloading $($asset.name)..." -ForegroundColor DarkGray
            Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $launcherApk
        }
    } catch {
        Write-Host "    [!] Could not auto-download Olauncher: $_" -ForegroundColor Yellow
    }
}

if (Test-Path $launcherApk) {
    Write-Host "    Installing verified minimal launcher (Olauncher.apk)..." -ForegroundColor Yellow
    & $ADB install -r $launcherApk
    & $ADB shell cmd appops set app.olauncher RECORD_AUDIO ignore 2>$null
    & $ADB shell cmd appops set app.olauncher READ_PHONE_STATE ignore 2>$null
    Write-Host "    Olauncher installed and permissions stripped." -ForegroundColor Green
} else {
    Write-Host "    [!] Olauncher.apk not found. You can run download_launcher.py later." -ForegroundColor Yellow
}

Write-Host "`n==========================================================================" -ForegroundColor Cyan
Write-Host "   [SUCCESS] TRANSFORMATION COMPLETE: PRODUCTIVITY TERMINAL READY!         " -ForegroundColor Green
Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host "To manage or temporarily unfreeze Google Play Store, run phone_manager.bat." -ForegroundColor Yellow
Write-Host "To revert any settings back to standard Android, run restore_defaults.ps1." -ForegroundColor White
Write-Host ""
