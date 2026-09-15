# 📵 Android Productivity Terminal

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Android](https://img.shields.io/badge/Android-11%20--%2015-3DDC84?logo=android&logoColor=white)](https://www.android.com)
[![Samsung Knox](https://img.shields.io/badge/Knox%20Warranty-0x0%20(Untouched)-brightgreen)](#-faq--no-bullshit)
[![Root Required](https://img.shields.io/badge/Root-NOT%20Required-success)](#-quick-start)
[![Reversible](https://img.shields.io/badge/Reversible-100%25-orange)](#-how-to-un-brick-your-addiction-rollback)

> **Surgical, root-free ADB framework that converts modern Android smartphones from pocket slot machines into cold, distraction-free productivity terminals.**

---

## 💀 The Manifesto: Why the Hell Do You Need a Browser in 2026?

Congratulations. You spent $800 on a handheld supercomputer packing 8 CPU cores, a 90Hz AMOLED panel, and military-grade cryptographic enclaves — and you’re using it to watch teenagers dance to sped-up pop songs while doomscrolling outrage at 2:15 AM.

Your phone is not a tool anymore. It’s an attention extraction rig engineered by Stanford behavioral psychologists whose annual bonuses depend entirely on keeping your eyeballs glued to an infinite stream of algorithmic brainrot.

**Here is our foundational architectural philosophy:**

> **Why the fuck do you need a web browser in your pocket in 2026?**  
> What are you browsing? Are you enjoying accepting 47 GDPR cookie consent modals while an autoplaying video ad covers 60% of your viewport, just to read an AI-generated SEO article about *"Top 10 Garlic Presses"* with a 3,000-word prelude about someone's grandma in Minnesota?  
>  
> **We have conversational AI.**  
> If you need information, ask Claude or ChatGPT. Get the raw synthesis, execute the task, put the phone down, and go touch some damn grass. If you’re opening Chrome on a touchscreen, let’s be honest with each other: you’re not *researching*. You’re procrastinating on the toilet while Google auctions off your retina fixations to high-frequency ad exchanges.  
>  
> **No browser. No store. No dopamine hooks.**

---

## ⚡ Key Highlights (What Gets Murdered)

* 🚫 **Zero-Browser Perimeter:** Chrome and HTML rendering engines are completely uninstalled or frozen. Tap a link anywhere? Kernel returns `No activity found`. The rabbit hole is bricked shut.
* 🪓 **App Store Guillotine:** Google Play Store frozen, Samsung Galaxy Store permanently removed. You can’t impulse-download an ad-riddled match-3 game at midnight when willpower is at zero.
* 🪨 **"Gray Stone" Sensory Calm:** Hardware matrix daltonizer forces strict monochromatic grayscale + Extra Dim. Stripped of neon saturation, Instagram looks like an obituary and TikTok looks like CCTV footage from a Chernobyl basement.
* ⚡ **0.0 ms Latency (Instant UI):** Animation scales forced to `0.0x`. The GPU stops wasting clock cycles rendering smooth transitions. Windows snap instantly like a military radio.
* 🛑 **RAM Plus Deicide:** Killed Samsung’s 4 GB virtual swap file (`ram_expand_size 0`). No more thrashing your slow UFS flash storage just to fake memory benchmarks. Pure physical LPDDR4X speed only.
* 🛡️ **Cryptographic DNS Condom:** System-level DNS-over-TLS through CleanBrowsing Family Filter. Adult content, telemetry trackers, and proxy bypasses blocked at the socket layer.
* 🔕 **Sensory Silence:** Keypress vibrations killed. System clicks muted. Red unread counter badges annihilated. 30-second screen timeout enforced.
* 🎛️ **The Desktop Leash ([`phone_manager.bat`](phone_manager.bat)):** Need to update your banking app so your debit card doesn't get declined at Whole Foods? Plug the phone into your PC, hit `[1]` to unfreeze Google Play, update, then hit `[2]` to freeze it back into carbonite.

---

## 📁 Clean Minimalist Architecture

No messy root directory. Everything is strictly organized:

```text
├── phone_manager.bat         # 🚀 1-Click root launcher (Double-click to manage device)
├── phone_manager.ps1         # ⚙️  Core interactive terminal engine
├── README.md                 # 📖 The documentation you're reading right now
├── LICENSE                   # 📜 MIT License
├── requirements.txt          # 🐍 Zero external pip dependencies (Standard library only)
│
├── docs/                     # 🌐 Standalone interactive web reports (Open in browser)
│   ├── index.html            #    Unified portal hub
│   ├── step_by_step_transformation.html  # 18-step chronological engineering log
│   ├── full_system_transformation_report.html # In-depth technical architecture whitepaper
│   └── dopamine_interactive_dashboard.html # Chart.js screen addiction visualizer
│
├── scripts/                  # 🛠️  Modular automation, rollback & telemetry tools
│   ├── apply_minimalism.bat  #    1-Click batch runner for 18-step transformation
│   ├── apply_minimalism.ps1  #    Automated PowerShell deployment engine
│   ├── restore_defaults.bat  #    1-Click emergency factory rollback
│   ├── restore_defaults.ps1  #    Full system restoration script
│   ├── start_screen.bat      #    Low-latency scrcpy phone mirror
│   ├── collect_stats.bat     #    Extract dumpsys usagestats & notifications
│   ├── collect_stats.py      #    Telemetry acquisition pipeline
│   ├── audit_olauncher.py    #    DEX bytecode ad/tracker scanner
│   ├── download_launcher.py  #    Automated GitHub release downloader
│   └── dyn_rename.py         #    UIAutomator batch app renamer
│
└── data/                     # 📊 Anonymized sample telemetry datasets
    ├── deep_dopamine_analysis.json
    ├── multi_interval_stats.json
    └── parsed_stats.json
```

---

## 🚀 Quick Start

### 1. Requirements
1. Android smartphone running **Android 11 to 15** (fine-tuned on Samsung Galaxy One UI 6, compatible with all modern Android OEMs).
2. USB cable connected to your PC.
3. **USB Debugging enabled:**
   * Go to `Settings` -> `About phone` -> `Software information`.
   * Tap `Build number` 7 times until Developer options unlock.
   * Go to `Settings` -> `Developer options` -> toggle **USB debugging** to `ON`.
   * When plugged in, check `Always allow from this computer` -> Tap **Allow**.

### 2. Run the Manager
Double-click `phone_manager.bat` in the root folder:

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

## 🛠️ The 18-Step Manual Protocol (For Terminal Purists)

Prefer running the commands manually via ADB? Here is the complete protocol:

```bash
# === 1. Baseline Extraction ===
adb devices
adb shell dumpsys usagestats > usagestats_baseline.txt

# === 2. Eradicate Entertainment Feeds (User 0) ===
adb shell pm uninstall -k --user 0 com.google.android.youtube
adb shell pm uninstall -k --user 0 com.zhiliaoapp.musically
adb shell pm uninstall -k --user 0 com.instagram.android
adb shell pm uninstall -k --user 0 com.linkedin.android
adb shell pm uninstall -k --user 0 com.glovo
adb shell pm uninstall -k --user 0 ua.com.uklontaxi

# === 3. Murder Google Discover Feed ===
adb shell pm uninstall -k --user 0 com.google.android.googlequicksearchbox

# === 4. Zero-Browser Perimeter ===
adb shell pm disable-user --user 0 com.android.chrome
adb shell pm uninstall -k --user 0 com.android.chrome
adb shell pm disable-user --user 0 com.sec.android.app.chromecustomizations
adb shell pm disable-user --user 0 com.android.htmlviewer

# === 5. App Store Lockdown ===
adb shell pm uninstall -k --user 0 com.sec.android.app.samsungapps
adb shell pm disable-user --user 0 com.android.vending

# === 6. Anti-Sideloading Enforcer (No APK installs from chats/files) ===
adb shell settings put secure install_non_market_apps 0
adb shell cmd appops set com.sec.android.app.myfiles REQUEST_INSTALL_PACKAGES deny
adb shell cmd appops set org.telegram.messenger REQUEST_INSTALL_PACKAGES deny
adb shell cmd appops set com.discord REQUEST_INSTALL_PACKAGES deny
adb shell cmd appops set com.whatsapp REQUEST_INSTALL_PACKAGES deny
adb shell cmd appops set com.google.android.apps.docs REQUEST_INSTALL_PACKAGES deny

# === 7. Purge OEM Adware Autoinstallers ===
adb shell pm uninstall -k --user 0 com.aura.oobe.samsung.gl
adb shell pm uninstall -k --user 0 com.samsung.android.cidmanager
adb shell pm uninstall -k --user 0 com.samsung.android.app.omcagent
adb shell pm uninstall -k --user 0 com.samsung.android.sdm.config

# === 8. Mute 15 Telemetry & Diagnostic Daemons ===
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

# === 9. Radio Idle Power Saving (Stop background Wi-Fi/BT snooping) ===
adb shell settings put global wifi_scan_always_enabled 0
adb shell settings put global ble_scan_always_enabled 0

# === 10. Disable RAM Plus (Kill slow storage swap) ===
adb shell settings put global ram_expand_size 0

# === 11. Instant 0 ms UI (No transition latency) ===
adb shell settings put global window_animation_scale 0
adb shell settings put global transition_animation_scale 0
adb shell settings put global animator_duration_scale 0

# === 12. "Gray Stone" Monochromatic Display Mode ===
adb shell settings put secure accessibility_display_daltonizer 0
adb shell settings put secure accessibility_display_daltonizer_enabled 1
adb shell settings put secure reduce_bright_colors_activated 1

# === 13. Mute Tactile & Sound Triggers ===
adb shell settings put system haptic_feedback_enabled 0
adb shell settings put system sound_effects_enabled 0
adb shell settings put system lockscreen_sounds_enabled 0

# === 14. Kill Unread Badges & Enforce 30s Timeout ===
adb shell settings put secure notification_badging 0
adb shell settings put system screen_off_timeout 30000

# === 15. Cryptographic DNS-over-TLS (CleanBrowsing Family) ===
adb shell settings put global private_dns_mode hostname
adb shell settings put global private_dns_specifier family-filter-dns.cleanbrowsing.org

# === 16. Deploy Minimal Text Launcher ===
adb install -r Olauncher.apk
adb shell cmd appops set app.olauncher RECORD_AUDIO ignore
adb shell cmd appops set app.olauncher READ_PHONE_STATE ignore

# === 17. Use Phone Manager for 1-Click Desktop Control ===
# Run phone_manager.bat

# === 18. Hardware Verification Audit ===
adb shell "dumpsys battery | grep -E 'level|temperature|status'"
adb shell "cat /proc/meminfo | head -n 2"
adb shell "cmd package resolve-activity http://google.com"
```

---

## 🔄 How to Un-Brick Your Addiction (Rollback)

Scared of living without infinite feeds? Regret kicking your TikTok habit? Everything is **100% reversible** in 5 seconds.

Run in PowerShell:
```powershell
.\scripts\restore_defaults.ps1
```
*(Or choose option `[8]` in `phone_manager.bat`)*

This immediately re-enables Google Play Store, restores Chrome, turns colors back on, resets animations to 1.0x, turns system vibrations back on, and restores default DNS. Zero factory reset required.

---

## ❓ FAQ & No-Bullshit

#### Will this trip Samsung Knox or void my warranty?
**Hell no.** Knox warranty (`0x0`) only trips if you flash an unsigned bootloader or kernel binary via Odin (custom ROMs/rooting). This framework operates 100% in user space via standard, official Android Debug Bridge (`adb shell pm` and `adb shell settings`) for User 0. Your warranty, banking security flags, and Samsung Knox remain pristine.

#### Can I still receive phone calls, SMS, and WhatsApp messages?
**Yes.** Phone calls, cellular SMS, 2FA tokens, authenticators, banking apps, and work messengers (Telegram, Signal, WhatsApp) continue working normally. The goal is to eradicate passive algorithmic consumption, not turn your phone into a literal brick that can't call an ambulance.

#### How do I update banking apps without an app store?
Plug your phone into your computer, run `phone_manager.bat`, and press `[1]`. Google Play Store appears on your phone. Update your apps, then press `[2]` in the menu to freeze it back into oblivion.

---

## 📜 License

MIT License. Engineered for maximum human focus, radical digital independence, and zero corporate telemetry.
Olauncher is licensed under GNU GPLv3 by [Tanuj Notes](https://github.com/tanujnotes/Olauncher).
