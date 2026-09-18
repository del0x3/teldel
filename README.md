# teldel — turning my phone into a dumb terminal

A set of ADB scripts and system tweaks I used to turn my Samsung Galaxy into a distraction-free, zero-browser utility phone. No root, doesn't trip Knox, completely reversible.

---

### Why?

Last week I dumped my Android kernel usage stats and realized I averaged **10.4 hours a day** on my phone. 52 hours in a single week went to YouTube alone. That's literally a full-time job plus overtime spent staring at glowing pixels.

I didn't want to buy a $300 "minimalist" e-ink dumbphone that can't run banking apps, 2FA, or Telegram. I wanted to keep modern hardware (good camera, battery life, secure enclave, messengers, Uber, banking) while completely ripping out the casino mechanics.

So I plugged it into my PC and gutted the addiction loops over ADB.

---

### "Wait, you deleted the web browser?"

Yeah. People's first reaction is always: *"How do you survive without a browser on your phone?"*

Honestly, what are you actually doing in a mobile browser in 2026?
- Clicking some clickbait link from a group chat
- Getting flashbanged by 3 cookie consent banners, a newsletter popup, and an autoplaying video ad
- Scrolling past 12 paragraphs of AI-generated filler to find out what time a store closes

If I genuinely need information on the go, I open Claude or ChatGPT. I ask the question, get the exact answer in three sentences, close the phone, and get on with my life.

If I need to book a flight, fill out government paperwork, or do actual research, I open my laptop like a normal person. A mobile browser isn't a productivity tool — it's an excuse to doomscroll on the toilet while Google auctions your attention to ad brokers.

---

### What this actually does

1. **Kills entertainment apps:** YouTube, TikTok, Instagram, casual games, and food delivery apps are uninstalled for `user 0`.
2. **Zero-Browser:** Chrome and web view customizers disabled. Tapping an HTTP link in any app returns `No activity found`. The rabbit hole simply doesn't exist.
3. **App Store on a leash:** Google Play is frozen (`pm disable-user`) and Galaxy Store is uninstalled. You can't impulsively download games at midnight. When you legitimately need to update banking apps, plug into your PC, run `phone_manager.bat`, press `1` to temporarily unfreeze it, update, and press `2` to lock it again.
4. **Anti-sideloading:** Revoked `REQUEST_INSTALL_PACKAGES` from Telegram, file managers, and cloud drives via `appops`. Even if you download an APK, the OS refuses to install it.
5. **Killed telemetry & carrier junk:** Stripped 15 background diagnostic daemons, Samsung DiagMon, McAfee scanner, and persistent Wi-Fi/Bluetooth beacon snooping.
6. **Disabled RAM Plus (ZRAM swap):** Samsung enables a 4 GB virtual swap file on flash storage by default. On budget/midrange flash storage, this just causes I/O wait micro-stutters. Setting `ram_expand_size 0` lets the phone run purely on physical LPDDR RAM.
7. **0 ms animations:** Set `window_animation_scale`, `transition_animation_scale`, and `animator_duration_scale` to `0`. Windows snap open instantly instead of sliding around.
8. **Grayscale ("Gray Stone"):** Hardware daltonizer set to monochrome + Extra Dim enabled. Without bright saturated colors, your monkey brain stops treating your screen like a bush of ripe berries. Instagram in black-and-white looks like surveillance footage.
9. **Muted sensory triggers:** Haptic feedback off, keypress clicks off, lock sounds off, notification badges (the red anxiety dots) disabled, screen timeout set to 30s.
10. **CleanBrowsing DoT:** System-wide DNS-over-TLS set to CleanBrowsing family filter. Blocks adult content, malware domains, and open bypass proxies at the socket layer.
11. **Minimal text launcher:** Uses [Olauncher](https://github.com/tanujnotes/Olauncher) (open source, GPLv3, 0 trackers/ads). Clean text list instead of colorful app icons.

### What still works:
- Phone calls & SMS
- Work messengers (Telegram, WhatsApp, Signal)
- Banking apps (Monobank, Privat24, etc.)
- 2FA authenticators (Google Auth, Bitwarden)
- Camera (photos are still taken in full color; only the screen render is monochrome)
- Navigation & ride-sharing (Google Maps, Uber)

---

### Quick Start (Windows)

#### 1. Enable USB Debugging on your phone:
- Go to `Settings` -> `About phone` -> `Software information`.
- Tap `Build number` 7 times to unlock Developer options.
- Go to `Settings` -> `Developer options` -> turn on **USB debugging**.
- Connect phone to PC, check "Always allow from this computer" and accept.

#### 2. Run the manager:
Just double-click:
```cmd
phone_manager.bat
```
*(If you don't have ADB installed, download [Google Platform-Tools](https://developer.android.com/tools/releases/platform-tools) and extract `adb.exe` into this folder or add it to PATH).*

```text
================================================================
       ANDROID PRODUCTIVITY TERMINAL - PHONE MANAGER
================================================================

  [1] Temporarily ENABLE Google Play Store  (for app updates)
  [2] DISABLE Google Play Store          (restore lockdown)

  [3] Mirror Phone Screen to PC          (scrcpy stream)
  [4] Toggle Display Mode: B/W <--> COLOR (quick color toggle)
  [5] Express Battery, RAM & Security Perimeter Audit

  [6] Full Lockdown (Zero-Browser + YouTube + Play Store + DoT)
  [7] Open Interactive HTML Reports & Dopamine Dashboard
  [8] Restore Default Stock Android Settings (Rollback)

  [9] Exit
================================================================
```

To run the whole 18-step transformation in one shot:
```powershell
.\scripts\apply_minimalism.bat
```

---

### Repo Structure

```text
├── phone_manager.bat         # Main entry point (double-click to run)
├── phone_manager.ps1         # Terminal UI script
│
├── docs/                     # Interactive visualizers (double-click to open in browser)
│   ├── index.html            # Hub linking all reports
│   ├── step_by_step_transformation.html  # Detailed 18-step technical log
│   ├── full_system_transformation_report.html # Architecture whitepaper
│   └── dopamine_interactive_dashboard.html # Chart.js screen time analysis
│
├── scripts/                  # Individual scripts if you want to run things separately
│   ├── apply_minimalism.bat  # Full 18-step setup
│   ├── restore_defaults.bat  # Rollback script
│   ├── start_screen.bat      # Scrcpy screen mirror
│   ├── collect_stats.bat     # Dumps usagestats from phone and parses them
│   ├── audit_olauncher.py    # Bytecode scanner verifying 0 trackers in the launcher
│   └── ...
│
└── data/                     # Anonymized sample data used by the HTML dashboards
```

---

### The Manual Commands (If you prefer running ADB yourself)

```bash
# Baseline check
adb devices

# Remove timekillers
adb shell pm uninstall -k --user 0 com.google.android.youtube
adb shell pm uninstall -k --user 0 com.zhiliaoapp.musically
adb shell pm uninstall -k --user 0 com.instagram.android
adb shell pm uninstall -k --user 0 com.linkedin.android
adb shell pm uninstall -k --user 0 com.glovo
adb shell pm uninstall -k --user 0 com.google.android.googlequicksearchbox

# Kill browser & stores
adb shell pm disable-user --user 0 com.android.chrome
adb shell pm uninstall -k --user 0 com.android.chrome
adb shell pm disable-user --user 0 com.sec.android.app.chromecustomizations
adb shell pm uninstall -k --user 0 com.sec.android.app.samsungapps
adb shell pm disable-user --user 0 com.android.vending

# Block APK sideloading
adb shell settings put secure install_non_market_apps 0
adb shell cmd appops set org.telegram.messenger REQUEST_INSTALL_PACKAGES deny
adb shell cmd appops set com.sec.android.app.myfiles REQUEST_INSTALL_PACKAGES deny
adb shell cmd appops set com.discord REQUEST_INSTALL_PACKAGES deny
adb shell cmd appops set com.whatsapp REQUEST_INSTALL_PACKAGES deny

# Clean telemetry & bloatware
adb shell pm uninstall -k --user 0 com.aura.oobe.samsung.gl
adb shell pm uninstall -k --user 0 com.samsung.android.cidmanager
adb shell pm disable-user --user 0 imslogger
adb shell pm disable-user --user 0 diagmonagent
adb shell pm disable-user --user 0 ipsgeofence
adb shell pm disable-user --user 0 sm.devicesecurity

# Hardware & animations
adb shell settings put global ram_expand_size 0
adb shell settings put global window_animation_scale 0
adb shell settings put global transition_animation_scale 0
adb shell settings put global animator_duration_scale 0
adb shell settings put global wifi_scan_always_enabled 0
adb shell settings put global ble_scan_always_enabled 0

# Grayscale & sound triggers
adb shell settings put secure accessibility_display_daltonizer 0
adb shell settings put secure accessibility_display_daltonizer_enabled 1
adb shell settings put secure reduce_bright_colors_activated 1
adb shell settings put system haptic_feedback_enabled 0
adb shell settings put system sound_effects_enabled 0
adb shell settings put system lockscreen_sounds_enabled 0
adb shell settings put secure notification_badging 0
adb shell settings put system screen_off_timeout 30000

# Private DNS (CleanBrowsing DoT)
adb shell settings put global private_dns_mode hostname
adb shell settings put global private_dns_specifier family-filter-dns.cleanbrowsing.org
```

---

### How to Rollback

If you decide you want to revert everything back to stock settings without wiping your phone or losing data:

Double-click `scripts\restore_defaults.bat` (or select option `8` in `phone_manager.bat`).

The rollback script automatically:
1. **Reinstalls & unfreezes applications**: Restores Chrome, YouTube, Google Play Store, Galaxy Store, and preinstalled apps via `cmd package install-existing` and `pm enable`.
2. **Restores full-color display**: Deactivates Samsung One UI native monochrome (`system greyscale_mode 0`), hardware daltonizer, and Extra Dim.
3. **Restores stock Samsung One UI launcher**: Automatically reactivates Samsung One UI Home as default and uninstalls `Olauncher`.
4. **Restores installation permissions**: Re-enables APK sideloading and `REQUEST_INSTALL_PACKAGES` for messengers, files, and browsers.
5. **Restores system feel & DNS**: Resets animations to 1.0x, haptics, sounds, badges, and sets Private DNS back to opportunistic default.

Or manually:
```bash
# 1. Reinstall and enable core apps
adb shell cmd package install-existing com.android.vending
adb shell cmd package install-existing com.sec.android.app.samsungapps
adb shell cmd package install-existing com.android.chrome
adb shell cmd package install-existing com.google.android.youtube
adb shell pm enable com.android.vending
adb shell pm enable com.sec.android.app.samsungapps
adb shell pm enable com.android.chrome
adb shell pm enable com.google.android.youtube

# 2. Restore full color display (Samsung + AOSP)
adb shell settings put system greyscale_mode 0
adb shell settings put secure accessibility_display_daltonizer_enabled 0
adb shell settings put secure reduce_bright_colors_activated 0

# 3. Restore Samsung One UI Home
adb shell cmd package set-home-activity com.sec.android.app.launcher/com.sec.android.app.launcher.activities.LauncherActivity
adb shell pm uninstall app.olauncher
adb shell am start -a android.intent.action.MAIN -c android.intent.category.HOME

# 4. Restore APK installations & Sideloading
adb shell settings put secure install_non_market_apps 1
adb shell cmd appops set org.telegram.messenger REQUEST_INSTALL_PACKAGES allow

# 5. Restore animations, sounds, and network DNS
adb shell settings put global window_animation_scale 1.0
adb shell settings put global transition_animation_scale 1.0
adb shell settings put global animator_duration_scale 1.0
adb shell settings put system haptic_feedback_enabled 1
adb shell settings put system sound_effects_enabled 1
adb shell settings put system lockscreen_sounds_enabled 1
adb shell settings put secure notification_badging 1
adb shell settings put system screen_off_timeout 60000
adb shell settings delete global private_dns_specifier
adb shell settings put global private_dns_mode opportunistic
```

---

### FAQ

**Does this trip Samsung Knox or void warranty?**  
No. Knox trips only when you flash unauthorized bootloaders or custom recovery partitions (Odin/rooting). All these changes run in user space via standard `adb shell pm` and `adb shell settings` commands. Knox stays `0x0`.

**Can I run this on Mac or Linux?**  
Yes. The `.bat` and `.ps1` files are convenience wrappers for Windows, but the ADB commands are standard POSIX shell commands. Just copy-paste the commands from the manual section into your terminal.

**What phone was this tested on?**  
Tested on a Samsung Galaxy A16 running One UI 6 (Android 14), but the ADB commands apply to virtually any modern Android device (One UI, Pixel UI, Motorola, etc.).

---

### License

MIT. Do whatever you want with it.  
Olauncher is by [Tanuj Notes](https://github.com/tanujnotes/Olauncher) under GPLv3.
