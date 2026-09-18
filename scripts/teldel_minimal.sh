#!/system/bin/sh
# ==============================================================================
# teldel - Minimal Terminal Profile (Autonomous High-Speed Native Engine)
# ==============================================================================

# 1. Neutralize entertainment, feeds, zero-browser & telemetry
# Fast-path: query enabled packages once to avoid redundant PackageManager locks and broadcasts
ENABLED=$(pm list packages -e)

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
settings put secure install_non_market_apps 0
cmd appops set org.telegram.messenger REQUEST_INSTALL_PACKAGES deny 2>/dev/null
cmd appops set com.discord REQUEST_INSTALL_PACKAGES deny 2>/dev/null
cmd appops set com.whatsapp REQUEST_INSTALL_PACKAGES deny 2>/dev/null
cmd appops set org.thoughtcrime.securesms REQUEST_INSTALL_PACKAGES deny 2>/dev/null
cmd appops set com.sec.android.app.myfiles REQUEST_INSTALL_PACKAGES deny 2>/dev/null
cmd appops set com.google.android.apps.docs REQUEST_INSTALL_PACKAGES deny 2>/dev/null
cmd appops set com.microsoft.skydrive REQUEST_INSTALL_PACKAGES deny 2>/dev/null

# 3. Hardware tuning & 0ms animations
settings put global ram_expand_size 0
settings put global window_animation_scale 0
settings put global transition_animation_scale 0
settings put global animator_duration_scale 0
settings put global wifi_scan_always_enabled 0
settings put global ble_scan_always_enabled 0

# 4. Sensory detox (Monochrome + Extra Dim White Point 80% + Mute + Heads-Up & Badges)
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

# 5. DNS-over-TLS (CleanBrowsing Family Shield)
settings put global private_dns_mode hostname
settings put global private_dns_specifier family-filter-dns.cleanbrowsing.org

# 6. Minimal text launcher activation (Atomic Role Manager Switch - No Restarts)
cmd appops set app.olauncher RECORD_AUDIO ignore 2>/dev/null
cmd appops set app.olauncher READ_PHONE_STATE ignore 2>/dev/null
cmd role add-role-holder --user 0 android.app.role.HOME app.olauncher 2>/dev/null
input keyevent 3 2>/dev/null

echo "TELDEL_MINIMAL_APPLIED"
