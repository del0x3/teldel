#!/system/bin/sh
# ==============================================================================
# teldel - Minimal Terminal Profile (On-Device Native Shell Engine)
# ==============================================================================

# 1. Neutralize entertainment & distraction feeds
pm disable-user --user 0 com.google.android.youtube 2>/dev/null
pm disable-user --user 0 com.zhiliaoapp.musically 2>/dev/null
pm disable-user --user 0 com.instagram.android 2>/dev/null
pm disable-user --user 0 com.linkedin.android 2>/dev/null
pm disable-user --user 0 com.glovo 2>/dev/null
pm disable-user --user 0 com.google.android.googlequicksearchbox 2>/dev/null

# 2. Zero-Browser & App Store Perimeter
pm disable-user --user 0 com.android.chrome 2>/dev/null
pm uninstall -k --user 0 com.android.chrome 2>/dev/null
pm disable-user --user 0 com.sec.android.app.chromecustomizations 2>/dev/null
pm uninstall -k --user 0 com.sec.android.app.samsungapps 2>/dev/null
pm disable-user --user 0 com.android.vending 2>/dev/null
pm disable-user --user 0 com.samsung.android.video 2>/dev/null
pm disable-user --user 0 com.android.htmlviewer 2>/dev/null
pm disable-user --user 0 com.android.vpndialogs 2>/dev/null
pm disable-user --user 0 com.sec.android.easyMover 2>/dev/null

# 3. Anti-sideloading (AppOps)
settings put secure install_non_market_apps 0
cmd appops set org.telegram.messenger REQUEST_INSTALL_PACKAGES deny 2>/dev/null
cmd appops set com.discord REQUEST_INSTALL_PACKAGES deny 2>/dev/null
cmd appops set com.whatsapp REQUEST_INSTALL_PACKAGES deny 2>/dev/null
cmd appops set org.thoughtcrime.securesms REQUEST_INSTALL_PACKAGES deny 2>/dev/null
cmd appops set com.sec.android.app.myfiles REQUEST_INSTALL_PACKAGES deny 2>/dev/null
cmd appops set com.google.android.apps.docs REQUEST_INSTALL_PACKAGES deny 2>/dev/null
cmd appops set com.microsoft.skydrive REQUEST_INSTALL_PACKAGES deny 2>/dev/null

# 4. Telemetry & background daemons
pm uninstall -k --user 0 com.aura.oobe.samsung.gl 2>/dev/null
pm disable-user --user 0 com.aura.oobe.samsung.gl 2>/dev/null
pm uninstall -k --user 0 com.samsung.android.cidmanager 2>/dev/null
pm disable-user --user 0 com.samsung.android.cidmanager 2>/dev/null
pm disable-user --user 0 imslogger 2>/dev/null
pm disable-user --user 0 ipsgeofence 2>/dev/null
pm disable-user --user 0 diagmonagent 2>/dev/null
pm disable-user --user 0 sm.devicesecurity 2>/dev/null

# 5. Hardware tuning & 0ms animations
settings put global ram_expand_size 0
settings put global window_animation_scale 0
settings put global transition_animation_scale 0
settings put global animator_duration_scale 0
settings put global wifi_scan_always_enabled 0
settings put global ble_scan_always_enabled 0

# 6. Sensory detox (Monochrome + Mute + Badge & Banner Suppression)
settings put system greyscale_mode 1
settings put secure accessibility_display_daltonizer 0
settings put secure accessibility_display_daltonizer_enabled 1
settings put secure reduce_bright_colors_activated 1
settings put system haptic_feedback_enabled 0
settings put system sound_effects_enabled 0
settings put system lockscreen_sounds_enabled 0
settings put secure notification_badging 0
settings put system badge_app_icon_type 0
settings put global heads_up_notifications_enabled 0
settings put system screen_off_timeout 30000

# 7. DNS-over-TLS (CleanBrowsing Family Shield)
settings put global private_dns_mode hostname
settings put global private_dns_specifier family-filter-dns.cleanbrowsing.org

# 8. Minimal text launcher activation
pm enable app.olauncher 2>/dev/null
cmd appops set app.olauncher RECORD_AUDIO ignore 2>/dev/null
cmd appops set app.olauncher READ_PHONE_STATE ignore 2>/dev/null
cmd role add-role-holder --user 0 android.app.role.HOME app.olauncher 2>/dev/null
cmd package set-home-activity app.olauncher/.MainActivity 2>/dev/null
am start -a android.intent.action.MAIN -c android.intent.category.HOME 2>/dev/null

echo "TELDEL_MINIMAL_APPLIED"
