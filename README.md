# 📵 Android Productivity Terminal & Dopamine Detox

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Android](https://img.shields.io/badge/Android-11%20--%2015-3DDC84?logo=android&logoColor=white)](https://www.android.com)
[![Knox Warranty](https://img.shields.io/badge/Samsung%20Knox-0x0%20(Untouched)-brightgreen)](#faq--knox-security)
[![Root Required](https://img.shields.io/badge/Root-NOT%20Required-success)](#prerequisites)
[![Reversibility](https://img.shields.io/badge/Reversible-100%25-orange)](#-how-to-revert--rollback)

> **Transform modern Samsung Galaxy and Android smartphones into distraction-free, zero-browser, monochromatic productivity terminals via surgical ADB commands. No root, no Knox void, completely reversible.**

---

## 🧭 Overview & Philosophy

Modern smartphones are engineered as hyper-optimized dopamine slot machines: infinite feeds, vibrating engagement loops, red notification badges, and aggressive background analytics. 

**Android Productivity Terminal** is a reproducible, rootless framework designed to strip away the addiction-by-design layer while retaining mission-critical utilities:
- 🚫 **Zero-Browser Perimeter:** Eliminates Chrome and web renderers. No doomscrolling, no impulse search rabbit holes.
- 🔒 **Store Lockdown & Anti-Sideloading:** Google Play Store is frozen by default; third-party APK installations via Telegram, file managers, or browsers are locked down via `cmd appops`.
- ⚡ **0.0 ms Latency & Swap Kill:** Window animation scales set to 0 and Samsung RAM Plus (ZRAM flash-swap) disabled to eradicate micro-stutters.
- 🪨 **"Gray Stone" Sensory Mode:** Hardware daltonizer grayscale + Extra Dim mode eliminates visual triggers.
- 🛡️ **Network Cryptographic Shield:** System-wide DNS-over-TLS (DoT) through CleanBrowsing Family Filter prevents adult content, bypass proxies, and malicious telemetry.
- 🔇 **Sensory De-escalation:** Haptics and keyboard click sounds muted; red notification badges eradicated; 30-second screen timeout enforced.
- 🖥️ **Desktop Phone Manager:** 1-click temporary unfreeze of Google Play Store (for vital banking/authenticator updates), color/monochrome toggle, screen mirroring via `scrcpy`, and instant security audits.

---

## 📊 Interactive Dashboards & Technical Reports

The repository includes a suite of standalone interactive HTML reports (open directly in any browser):

1. **[📋 18-Step Chronological Transformation Registry](step_by_step_transformation.html)**  
   Detailed log of every command executed, engineering rationale, and verified system effects.
2. **[🏛️ Comprehensive System Architecture Report](full_system_transformation_report.html)**  
   Deep dive into memory swap architecture, Knox user isolation, zero-trust security perimeters, and battery telemetry.
3. **[🧠 Interactive Dopamine & Screen Time Dashboard](dopamine_interactive_dashboard.html)**  
   Chart.js visualizer analyzing pre-transformation addiction baselines (10.4h/day, 9000+ unlocks, binge durations, notification interruptions).
4. **[🌐 Web Portal Hub](index.html)**  
   Unified navigation hub linking all reports and project documentation.

---

## ⚡ Quick Start Guide (Windows)

### 1. Prerequisites
- Any Android device running Android 11 to 15 (tested and fine-tuned on **Samsung Galaxy A16 / One UI 6.x**, compatible with Galaxy A/S/Z series and general Android).
- A USB data cable.
- **USB Debugging enabled:**
  1. Go to `Settings` -> `About phone` -> `Software information`.
  2. Tap `Build number` 7 times until Developer options are unlocked.
  3. Go to `Settings` -> `Developer options` and toggle **USB debugging** to `ON`.
- **ADB (Android Platform Tools):**
  - If you already have Android Studio or platform-tools in your `PATH`, the scripts will auto-detect it.
  - Otherwise, download [Android SDK Platform-Tools](https://developer.android.com/tools/releases/platform-tools) and extract `adb.exe` into the repository folder or add it to your system `PATH`.

### 2. Connect Your Phone
Plug your phone into the computer. Look at your phone screen and check:
`Always allow from this computer` -> Tap **Allow**.

### 3. Run Phone Manager
Double-click `phone_manager.bat` (or run PowerShell):

```powershell
.\phone_manager.bat
```

You will be greeted by the terminal control panel:

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

---

## 🚀 How to Reproduce the Full Setup

### Option A: Automated One-Click Script (Recommended)
Run the automated transformation script in PowerShell:

```powershell
.\apply_minimalism.ps1
```

This automates all 18 steps with verification at each stage.

### Option B: Manual Step-by-Step Execution
If you prefer executing commands directly via ADB CLI, here is the verified 18-step protocol:

#### Phase 1: Dopamine & Distraction Cleansing
```bash
# 1. Baseline audit & stats extraction
adb devices
adb shell dumpsys usagestats > usagestats_baseline.txt

# 2. Remove entertainment & impulse apps (User 0)
adb shell pm uninstall -k --user 0 com.google.android.youtube
adb shell pm uninstall -k --user 0 com.zhiliaoapp.musically
adb shell pm uninstall -k --user 0 com.instagram.android
adb shell pm uninstall -k --user 0 com.linkedin.android
adb shell pm uninstall -k --user 0 com.glovo
adb shell pm uninstall -k --user 0 ua.com.uklontaxi

# 3. Eliminate Google Discover news feed
adb shell pm uninstall -k --user 0 com.google.android.googlequicksearchbox
```

#### Phase 2: Zero-Browser & App Store Perimeter
```bash
# 4. Zero-browser perimeter (Chrome removal)
adb shell pm disable-user --user 0 com.android.chrome
adb shell pm uninstall -k --user 0 com.android.chrome
adb shell pm disable-user --user 0 com.sec.android.app.chromecustomizations
adb shell pm disable-user --user 0 com.android.htmlviewer

# 5. Store lockdown (Galaxy Store & Google Play Store)
adb shell pm uninstall -k --user 0 com.sec.android.app.samsungapps
adb shell pm disable-user --user 0 com.android.vending

# 6. Anti-sideloading enforcement
adb shell settings put secure install_non_market_apps 0
adb shell cmd appops set com.sec.android.app.myfiles REQUEST_INSTALL_PACKAGES deny
adb shell cmd appops set org.telegram.messenger REQUEST_INSTALL_PACKAGES deny
adb shell cmd appops set com.discord REQUEST_INSTALL_PACKAGES deny
adb shell cmd appops set com.whatsapp REQUEST_INSTALL_PACKAGES deny
adb shell cmd appops set org.thoughtcrime.securesms REQUEST_INSTALL_PACKAGES deny
adb shell cmd appops set com.google.android.apps.docs REQUEST_INSTALL_PACKAGES deny

# 7. Eradicate adware autoinstallers & OEM bloatware
adb shell pm uninstall -k --user 0 com.aura.oobe.samsung.gl
adb shell pm uninstall -k --user 0 com.samsung.android.cidmanager
adb shell pm uninstall -k --user 0 com.samsung.android.app.omcagent
adb shell pm uninstall -k --user 0 com.samsung.android.sdm.config
```

#### Phase 3: Hardware Tuning & Latency Eradication
```bash
# 8. Disable 15 background telemetry & tracking daemons
adb shell pm disable-user --user 0 imslogger
adb shell pm disable-user --user 0 ipsgeofence
adb shell pm disable-user --user 0 diagmonagent
adb shell pm disable-user --user 0 iaft
adb shell pm disable-user --user 0 dsms
adb shell pm disable-user --user 0 sdhms
adb shell pm disable-user --user 0 aware.service
adb shell pm disable-user --user 0 dqagent
adb shell pm disable-user --user 0 networkdiagnostic
adb shell pm disable-user --user 0 sm.devicesecurity

# 9. Power saving: Disable constant background Wi-Fi & Bluetooth scanning
adb shell settings put global wifi_scan_always_enabled 0
adb shell settings put global ble_scan_always_enabled 0

# 10. Disable RAM Plus (Prevent flash memory swap file thrashing)
adb shell settings put global ram_expand_size 0

# 11. Set UI animations to 0 ms (Instant response)
adb shell settings put global window_animation_scale 0
adb shell settings put global transition_animation_scale 0
adb shell settings put global animator_duration_scale 0
```

#### Phase 4: Sensory Detox ("Gray Stone" Mode)
```bash
# 12. Monochromatic display & Extra Dim mode
adb shell settings put secure accessibility_display_daltonizer 0
adb shell settings put secure accessibility_display_daltonizer_enabled 1
adb shell settings put secure reduce_bright_colors_activated 1

# 13. Mute tactile and sound micro-triggers
adb shell settings put system haptic_feedback_enabled 0
adb shell settings put system sound_effects_enabled 0
adb shell settings put system lockscreen_sounds_enabled 0

# 14. Silence attention triggers (Notification badges off, 30s timeout)
adb shell settings put secure notification_badging 0
adb shell settings put system screen_off_timeout 30000
```

#### Phase 5: Network Shield & Minimal Launcher
```bash
# 15. Encrypted DNS-over-TLS (CleanBrowsing family filter)
adb shell settings put global private_dns_mode hostname
adb shell settings put global private_dns_specifier family-filter-dns.cleanbrowsing.org

# 16. Install minimalist text launcher (Olauncher)
adb install -r Olauncher.apk
adb shell cmd appops set app.olauncher RECORD_AUDIO ignore
adb shell cmd appops set app.olauncher READ_PHONE_STATE ignore

# 17. Use Phone Manager for 1-click desktop control
# (phone_manager.bat)

# 18. Verification audit
adb shell "dumpsys battery | grep -E 'level|temperature|status'"
adb shell "cat /proc/meminfo | head -n 2"
adb shell "cmd package resolve-activity http://google.com"
```

---

## 🔄 How to Revert / Rollback

Every change is **100% reversible** without factory resetting your phone.

### Quick Rollback via Script
Run in PowerShell:
```powershell
.\restore_defaults.ps1
```
*(Or select option `[8]` in `phone_manager.bat`)*

### Manual Rollback Commands
```bash
# Re-enable Play Store & Chrome
adb shell pm enable com.android.vending
adb shell pm enable com.android.chrome
adb shell pm enable com.sec.android.app.chromecustomizations
adb shell pm enable com.samsung.android.video
adb shell pm enable com.android.htmlviewer
adb shell pm enable com.android.vpndialogs
adb shell pm enable com.sec.android.easyMover
adb shell settings put secure install_non_market_apps 1

# Restore colors & display
adb shell settings put secure accessibility_display_daltonizer_enabled 0
adb shell settings put secure reduce_bright_colors_activated 0

# Restore animations (1.0x)
adb shell settings put global window_animation_scale 1.0
adb shell settings put global transition_animation_scale 1.0
adb shell settings put global animator_duration_scale 1.0

# Restore haptics & sounds
adb shell settings put system haptic_feedback_enabled 1
adb shell settings put system sound_effects_enabled 1
adb shell settings put system lockscreen_sounds_enabled 1

# Restore screen timeout & badges
adb shell settings put secure notification_badging 1
adb shell settings put system screen_off_timeout 60000

# Reset DNS to automatic
adb shell settings put global private_dns_mode opportunistic
adb shell settings put global private_dns_specifier ""
```

---

## 🛠️ Included Tools & Utilities

| File | Description |
|---|---|
| `phone_manager.bat` | Portable launcher for the Windows terminal control manager. |
| `phone_manager.ps1` | Interactive terminal UI: toggle Play Store, toggle screen colors, scrcpy mirroring, and audits. |
| `apply_minimalism.ps1` | Automated 18-step transformation script. |
| `restore_defaults.ps1` | Instant rollback script restoring stock Android configurations. |
| `start_screen.bat` | 1-click low-latency phone screen mirroring via [scrcpy](https://github.com/Genymobile/scrcpy). |
| `Olauncher.apk` | Lightweight, open-source (GPLv3) text launcher v6.9.1. |
| `audit_olauncher.py` | Standalone DEX bytecode scanner to verify 0 ads / trackers in any APK. |
| `collect_stats.bat` | 1-click collection of `dumpsys usagestats` and `dumpsys notification` from device. |
| `deep_dopamine_miner.py` | Parser calculating session binges, compulsive micro-checks, and app-switching loops. |
| `parse_usage.py` | Aggregator calculating total active screen time and per-package metrics. |
| `dyn_rename.py` | Automated UIAutomator script to rename apps on Olauncher (e.g., distinguishing 2FA authenticators). |

---

## ❓ FAQ & Knox Security

#### Will this trip Samsung Knox or void my warranty?
**No.** Samsung Knox warranty flag (`0x0`) is only tripped when flashing unofficial bootloaders or unsigned kernel binaries via Odin (rooting/custom ROMs). This suite operates strictly in user space via official Android Debug Bridge (`adb shell pm` and `adb shell settings`) for User 0. Knox warranty remains completely intact.

#### How do I update banking apps or messengers?
Open `phone_manager.bat` and press `[1]` to unfreeze the Google Play Store. Launch Play Store on your phone, update your apps, then return to `phone_manager.bat` and press `[2]` to freeze it back.

#### Can I still receive calls, SMS, and WhatsApp/Telegram messages?
**Yes.** Phone calls, cellular SMS, calendar alarms, and work messengers (Telegram, WhatsApp, Signal) remain fully functional. Only distracting feeds, entertainment timekillers, and advertising hooks are suppressed.

#### Can I run this on Mac or Linux?
**Yes.** While the `.bat` and `.ps1` wrappers are tailored for Windows, all underlying commands are standard POSIX ADB shell commands. You can execute the commands from the [18-step manual guide](#option-b-manual-step-by-step-execution) directly in bash/zsh.

---

## 📜 License

This project is released under the [MIT License](LICENSE).  
Olauncher is created by [Tanuj Notes](https://github.com/tanujnotes/Olauncher) under GNU GPLv3.
