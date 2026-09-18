#!/system/bin/sh
# ==============================================================================
# teldel - Stock One UI Profile (On-Device Native Shell Engine)
# ==============================================================================

# 1. Restore applications & application stores
cmd package install-existing com.android.vending 2>/dev/null
pm enable com.android.vending 2>/dev/null
cmd package install-existing com.sec.android.app.samsungapps 2>/dev/null
pm enable com.sec.android.app.samsungapps 2>/dev/null
cmd package install-existing com.android.chrome 2>/dev/null
pm enable com.android.chrome 2>/dev/null
pm enable com.sec.android.app.chromecustomizations 2>/dev/null
cmd package install-existing com.google.android.youtube 2>/dev/null
pm enable com.google.android.youtube 2>/dev/null
cmd package install-existing com.google.android.googlequicksearchbox 2>/dev/null
pm enable com.google.android.googlequicksearchbox 2>/dev/null
pm enable com.samsung.android.video 2>/dev/null
pm enable com.android.htmlviewer 2>/dev/null
pm enable com.android.vpndialogs 2>/dev/null
pm enable com.sec.android.easyMover 2>/dev/null
pm enable com.samsung.knox.securefolder 2>/dev/null

# 2. Restore installation & sideloading permissions
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

# 3. Restore full-color display (Samsung One UI + AOSP daltonizer + Extra Dim)
settings put system greyscale_mode 0
settings put secure accessibility_display_daltonizer_enabled 0
settings put secure accessibility_display_daltonizer 0
settings put secure reduce_bright_colors_activated 0

# 4. Restore stock Samsung One UI launcher & disable Olauncher
cmd package set-home-activity com.sec.android.app.launcher/com.sec.android.app.launcher.activities.LauncherActivity 2>/dev/null
pm disable-user --user 0 app.olauncher 2>/dev/null
am start -a android.intent.action.MAIN -c android.intent.category.HOME 2>/dev/null

# 5. Restore animations & hardware settings
settings put global window_animation_scale 1.0
settings put global transition_animation_scale 1.0
settings put global animator_duration_scale 1.0
settings put global ram_expand_size 4
settings put global wifi_scan_always_enabled 1
settings put global ble_scan_always_enabled 1

# 6. Restore sensory feedback, notification badges, banners & screen timeout
settings put system haptic_feedback_enabled 1
settings put system sound_effects_enabled 1
settings put system lockscreen_sounds_enabled 1
settings put secure notification_badging 1
settings put system badge_app_icon_type 0
settings put global heads_up_notifications_enabled 1
settings put system screen_off_timeout 60000

# 7. Restore network DNS (opportunistic DHCP default)
settings delete global private_dns_specifier 2>/dev/null
settings put global private_dns_mode opportunistic

echo "TELDEL_STOCK_APPLIED"
