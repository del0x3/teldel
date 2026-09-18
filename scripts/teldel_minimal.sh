#!/system/bin/sh
# ==============================================================================
# teldel - Minimal Terminal Profile (Transaction-Safe Engine with Auto-Rollback)
# ==============================================================================

# 0. Transaction Safety Boundary
rollback_on_failure() {
    echo "[!] CRITICAL ERROR: Transformation failed or verification checks did not pass." >&2
    echo "[!] Initiating automatic transactional rollback to default stock state..." >&2
    if [ -f /data/local/tmp/teldel_stock.sh ]; then
        sh /data/local/tmp/teldel_stock.sh
    fi
    echo "TELDEL_TRANSACTION_FAILED_AND_ROLLED_BACK" >&2
    exit 1
}

# Pre-flight Check: Ensure target launcher is installed
if ! pm path app.olauncher >/dev/null 2>&1; then
    echo "[!] Pre-flight check failed: app.olauncher is not installed on device!" >&2
    rollback_on_failure
fi

# 1. Neutralize entertainment, feeds, zero-browser & telemetry
ENABLED=$(pm list packages -e 2>/dev/null)

for pkg in \
    com.google.android.youtube \
    com.zhiliaoapp.musically \
    com.instagram.android \
    com.linkedin.android \
    com.glovo \
    com.google.android.googlequicksearchbox \
    com.android.chrome \
    com.sec.android.app.chromecustomizations \
    com.sec.android.app.samsungapps \
    com.android.vending \
    com.samsung.android.video \
    com.android.htmlviewer \
    com.android.vpndialogs \
    com.sec.android.easyMover \
    com.aura.oobe.samsung.gl \
    com.samsung.android.cidmanager \
    imslogger \
    ipsgeofence \
    diagmonagent \
    sm.devicesecurity
do
    case "$ENABLED" in
        *package:$pkg*)
            pm disable-user --user 0 "$pkg" 2>/dev/null
            ;;
    esac
done

# 2. Anti-sideloading (AppOps)
settings put secure install_non_market_apps 0 2>/dev/null
cmd appops set org.telegram.messenger REQUEST_INSTALL_PACKAGES deny 2>/dev/null
cmd appops set com.discord REQUEST_INSTALL_PACKAGES deny 2>/dev/null
cmd appops set com.whatsapp REQUEST_INSTALL_PACKAGES deny 2>/dev/null
cmd appops set org.thoughtcrime.securesms REQUEST_INSTALL_PACKAGES deny 2>/dev/null
cmd appops set com.sec.android.app.myfiles REQUEST_INSTALL_PACKAGES deny 2>/dev/null
cmd appops set com.google.android.apps.docs REQUEST_INSTALL_PACKAGES deny 2>/dev/null
cmd appops set com.microsoft.skydrive REQUEST_INSTALL_PACKAGES deny 2>/dev/null

# 3. Hardware tuning & 0ms animations
settings put global ram_expand_size 0 2>/dev/null
settings put global window_animation_scale 0 2>/dev/null
settings put global transition_animation_scale 0 2>/dev/null
settings put global animator_duration_scale 0 2>/dev/null
settings put global wifi_scan_always_enabled 0 2>/dev/null
settings put global ble_scan_always_enabled 0 2>/dev/null

# 4. Sensory detox (Monochrome + Extra Dim White Point 80% + Mute + Heads-Up & Badges)
settings put system greyscale_mode 1 2>/dev/null
settings put secure accessibility_display_daltonizer 0 2>/dev/null
settings put secure accessibility_display_daltonizer_enabled 1 2>/dev/null
settings put secure reduce_bright_colors_activated 1 2>/dev/null
settings put secure reduce_bright_colors_level 80 2>/dev/null
settings put secure reduce_bright_colors_persist_across_reboots 1 2>/dev/null
settings put system blue_light_filter_night_dim 1 2>/dev/null
cmd uimode night yes 2>/dev/null
settings put system haptic_feedback_enabled 0 2>/dev/null
settings put system sound_effects_enabled 0 2>/dev/null
settings put system lockscreen_sounds_enabled 0 2>/dev/null
settings put secure notification_badging 0 2>/dev/null
settings put system badge_app_icon_type 0 2>/dev/null
settings put global heads_up_notifications_enabled 0 2>/dev/null
settings put system screen_off_timeout 30000 2>/dev/null

# 5. DNS-over-TLS (CleanBrowsing Family Shield)
settings put global private_dns_mode hostname 2>/dev/null
settings put global private_dns_specifier family-filter-dns.cleanbrowsing.org 2>/dev/null

# 6. Minimal text launcher activation (Atomic Role Manager Switch)
cmd appops set app.olauncher RECORD_AUDIO ignore 2>/dev/null
cmd appops set app.olauncher READ_PHONE_STATE ignore 2>/dev/null
cmd role add-role-holder --user 0 android.app.role.HOME app.olauncher 2>/dev/null
input keyevent 3 2>/dev/null

# 7. Post-Flight Health Check Verification
CURRENT_HOME=$(cmd role get-role-holders android.app.role.HOME 2>/dev/null)
if [ "$CURRENT_HOME" != "app.olauncher" ]; then
    echo "[!] Post-flight check failed: HOME role holder is '$CURRENT_HOME', expected 'app.olauncher'!" >&2
    rollback_on_failure
fi

echo "TELDEL_MINIMAL_APPLIED"
exit 0
