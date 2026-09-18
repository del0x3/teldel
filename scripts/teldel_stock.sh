#!/system/bin/sh
# ==============================================================================
# teldel - Stock One UI Profile (Autonomous High-Speed Native Engine)
# ==============================================================================

# 1. Restore applications & application stores
ENABLED=$(pm list packages -e 2>/dev/null)

for pkg in \
    com.android.vending \
    com.sec.android.app.samsungapps \
    com.android.chrome \
    com.sec.android.app.chromecustomizations \
    com.google.android.youtube \
    com.google.android.googlequicksearchbox \
    com.samsung.android.video \
    com.android.htmlviewer \
    com.android.vpndialogs \
    com.sec.android.easyMover \
    com.samsung.knox.securefolder
do
    case "$ENABLED" in
        *package:$pkg*)
            ;; # Already enabled
        *)
            cmd package install-existing "$pkg" 2>/dev/null
            pm enable "$pkg" 2>/dev/null
            ;;
    esac
done

# 2. Restore installation & sideloading permissions
settings put secure install_non_market_apps 1 2>/dev/null
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

# 3. Restore full-color display (Samsung One UI + AOSP daltonizer + Extra Dim)
settings put system greyscale_mode 0 2>/dev/null
settings put secure accessibility_display_daltonizer_enabled 0 2>/dev/null
settings put secure accessibility_display_daltonizer 0 2>/dev/null
settings put secure reduce_bright_colors_activated 0 2>/dev/null

# 4. Restore stock Samsung One UI launcher
cmd role add-role-holder --user 0 android.app.role.HOME com.sec.android.app.launcher 2>/dev/null
input keyevent 3 2>/dev/null

# 5. Restore animations & hardware settings
settings put global window_animation_scale 1.0 2>/dev/null
settings put global transition_animation_scale 1.0 2>/dev/null
settings put global animator_duration_scale 1.0 2>/dev/null
settings put global ram_expand_size 4 2>/dev/null
settings put global wifi_scan_always_enabled 1 2>/dev/null
settings put global ble_scan_always_enabled 1 2>/dev/null

# 6. Restore sensory feedback, notification badges, banners & screen timeout
settings put system haptic_feedback_enabled 1 2>/dev/null
settings put system sound_effects_enabled 1 2>/dev/null
settings put system lockscreen_sounds_enabled 1 2>/dev/null
settings put secure notification_badging 1 2>/dev/null
settings put system badge_app_icon_type 0 2>/dev/null
settings put global heads_up_notifications_enabled 1 2>/dev/null
settings put system screen_off_timeout 60000 2>/dev/null

# 7. Restore network DNS (opportunistic DHCP default)
settings delete global private_dns_specifier 2>/dev/null
settings put global private_dns_mode opportunistic 2>/dev/null

echo "TELDEL_STOCK_APPLIED"
exit 0
