# teldel — Android Productivity Terminal

[![Android](https://img.shields.io/badge/Android-10%2B-3DDC84?style=flat-square&logo=android&logoColor=white)](https://developer.android.com)
[![Samsung Knox](https://img.shields.io/badge/Knox-0x0%20Untouched-0057B7?style=flat-square)](https://www.samsungknox.com)
[![No Root](https://img.shields.io/badge/Root-Not%20Required-blueviolet?style=flat-square)]()
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![Interface](https://img.shields.io/badge/Interface-ADB%20CLI-black?style=flat-square&logo=powershell)](phone_manager.bat)

A surgical, root-free ADB automation suite and system policy engine that converts modern Samsung Galaxy and Android smartphones into zero-distraction, monochrome productivity terminals.

100% reversible in one click. Preserves Samsung Knox warranty status (`0x0`). Requires zero root privileges.

---

## Core System Policies

- **Zero-Browser Policy**: Disables Google Chrome, WebViews, and system HTML viewers. Tapping HTTP links returns `No Activity found`.
- **Controlled App Store**: Freezes Google Play Store and uninstalls Galaxy Store via `pm disable-user`. Controlled temporary unfreeze via CLI menu for required updates.
- **Anti-Sideloading Enforcement**: Revokes `REQUEST_INSTALL_PACKAGES` across Telegram, WhatsApp, Discord, file managers, and cloud drives using Android AppOps.
- **Sensory & Visual Detox**: Enforces system-wide hardware monochrome (`greyscale_mode 1`), Extra Dim, 0.0 ms window animations, and mutes haptic and audio feedback.
- **Notification Discipline**: Suppresses intrusive heads-up popup banners (`heads_up_notifications_enabled 0`) and strips red app badge counts (`notification_badging 0`). Status bar and notification shade push alerts remain 100% functional with full text and action buttons.
- **Telemetry & Bloatware Stripped**: Deactivates background diagnostic logging, carrier agents, and continuous Wi-Fi/Bluetooth beacon scanning.
- **DNS-over-TLS (DoT)**: Enforces CleanBrowsing Family Shield (`family-filter-dns.cleanbrowsing.org`) at socket level.
- **Minimal Text Launcher**: Integrates [Olauncher](https://github.com/tanujnotes/Olauncher) (open source, GPLv3, zero ads, zero trackers).

---

## Preserved Operational Perimeter

The device retains all critical real-world utilities:
- **Phone Calls, SMS & Contacts**
- **Messengers**: Telegram, WhatsApp, Signal, Viber, Discord
- **Push Notifications**: Incoming alerts in the top notification shade work normally
- **Financial Services**: Monobank, Privat24, Raiffeisen, OTP, etc.
- **Two-Factor Authentication**: Google Authenticator, Bitwarden, Microsoft Authenticator
- **Camera Hardware**: Photos are captured in original full resolution and true color
- **Navigation & Transit**: Google Maps, Waze, local transit utilities

---

## Repository Structure

```text
teldel/
├── phone_manager.bat       # Master Windows CLI runner (double-click to start)
├── phone_manager.ps1       # Interactive device management console
├── requirements.txt        # Environment spec (uses Python standard library only)
├── LICENSE                 # MIT License
├── README.md               # Technical documentation
│
├── scripts/                # Modular automation engines
│   ├── apply_minimalism.bat   # 1-click full 18-step transformation (Windows)
│   ├── apply_minimalism.ps1   # PowerShell automation wrapper
│   ├── teldel_minimal.sh      # Native on-device POSIX shell engine (cross-platform)
│   ├── restore_defaults.bat   # 1-click stock restoration (Windows)
│   ├── restore_defaults.ps1   # PowerShell rollback wrapper
│   ├── teldel_stock.sh        # Native on-device POSIX rollback engine (cross-platform)
│   ├── collect_stats.bat      # 1-click usage & dopamine data collection
│   ├── collect_stats.py       # Usagestats parser & dopamine loop analyzer
│   └── audit_olauncher.py     # DEX bytecode tracker & advertisement scanner
│
├── docs/                   # Interactive dashboards & technical reports
│   ├── index.html             # Documentation and reports hub
│   ├── dopamine_interactive_dashboard.html # Chart.js screen time analysis
│   ├── step_by_step_transformation.html    # 18-step chronological execution breakdown
│   └── full_system_transformation_report.html # System architecture whitepaper
│
└── data/                   # Generated analytics datasets
    ├── parsed_stats.json      # Lifetime app screen time & launch counts
    ├── multi_interval_stats.json # Daily, weekly, monthly interval statistics
    └── deep_dopamine_analysis.json # Discrete sessions, micro-checks, and binges
```

---

## Quick Start

### 1. Enable USB Debugging on Device
1. Navigate to **Settings** > **About phone** > **Software information**.
2. Tap **Build number** 7 times to unlock **Developer options**.
3. Open **Developer options** and enable **USB debugging**.
4. Connect device to PC via USB cable, check *Always allow from this computer*, and confirm.

### 2. Run Interactive Console
Double-click `phone_manager.bat` or run:
```powershell
.\phone_manager.bat
```

```text
================================================================
       ANDROID PRODUCTIVITY TERMINAL - PHONE MANAGER
================================================================
 [STATUS] Battery: 85% | Mode: [MINIMAL TERMINAL] | Screen: [B/W]
          Store: [LOCKED] | DNS: [CleanBrowsing DoT]
================================================================

  [1] Temporarily ENABLE Google Play Store  (for app updates)
  [2] DISABLE Google Play Store          (restore lockdown)

  [3] Mirror Phone Screen to PC          (scrcpy stream)
  [4] Toggle Display Mode: B/W <--> COLOR (fast toggle)
  [5] Express Battery, RAM & Security Perimeter Audit

  [6] Apply Full Minimalism Transformation (18-step setup)
  [7] Collect Usage Statistics & Dopamine Addiction Audit
  [8] Open Interactive HTML Reports & Dashboard
  [9] Restore Default Stock Android Settings (Rollback)

  [0] Exit
================================================================
```

---

## Direct Automation Commands

### 1-Click Transformation
```powershell
.\scripts\apply_minimalism.bat
```

### 1-Click Rollback to Stock
```powershell
.\scripts\restore_defaults.bat
```

### Collect App Usage & Dopamine Statistics
```powershell
.\scripts\collect_stats.bat
# or
python scripts\collect_stats.py
```

### Audit Launcher APK Bytecode
```powershell
python scripts\audit_olauncher.py
```

---

## Manual ADB Reference

For manual terminal execution on Windows, Linux, or macOS:

### 1. Neutralize Distractions & Feeds
```bash
adb shell pm disable-user --user 0 com.google.android.youtube
adb shell pm disable-user --user 0 com.zhiliaoapp.musically
adb shell pm disable-user --user 0 com.instagram.android
adb shell pm disable-user --user 0 com.linkedin.android
adb shell pm disable-user --user 0 com.glovo
adb shell pm disable-user --user 0 com.google.android.googlequicksearchbox
```

### 2. Zero-Browser & Store Perimeter
```bash
adb shell pm disable-user --user 0 com.android.chrome
adb shell pm uninstall -k --user 0 com.android.chrome
adb shell pm disable-user --user 0 com.sec.android.app.chromecustomizations
adb shell pm uninstall -k --user 0 com.sec.android.app.samsungapps
adb shell pm disable-user --user 0 com.android.vending
adb shell pm disable-user --user 0 com.samsung.android.video
adb shell pm disable-user --user 0 com.android.htmlviewer
```

### 3. Anti-Sideloading Permissions
```bash
adb shell settings put secure install_non_market_apps 0
adb shell cmd appops set org.telegram.messenger REQUEST_INSTALL_PACKAGES deny
adb shell cmd appops set com.sec.android.app.myfiles REQUEST_INSTALL_PACKAGES deny
adb shell cmd appops set com.discord REQUEST_INSTALL_PACKAGES deny
adb shell cmd appops set com.whatsapp REQUEST_INSTALL_PACKAGES deny
```

### 4. Remove Telemetry & Background Daemons
```bash
adb shell pm uninstall -k --user 0 com.aura.oobe.samsung.gl
adb shell pm uninstall -k --user 0 com.samsung.android.cidmanager
adb shell pm disable-user --user 0 imslogger
adb shell pm disable-user --user 0 diagmonagent
adb shell pm disable-user --user 0 ipsgeofence
adb shell pm disable-user --user 0 sm.devicesecurity
```

### 5. Hardware & Animation Optimization (0.0 ms)
```bash
adb shell settings put global ram_expand_size 0
adb shell settings put global window_animation_scale 0
adb shell settings put global transition_animation_scale 0
adb shell settings put global animator_duration_scale 0
adb shell settings put global wifi_scan_always_enabled 0
adb shell settings put global ble_scan_always_enabled 0
```

### 6. Monochrome Display & Sensory Detox
```bash
adb shell settings put system greyscale_mode 1
adb shell settings put secure accessibility_display_daltonizer 0
adb shell settings put secure accessibility_display_daltonizer_enabled 1
adb shell settings put secure reduce_bright_colors_activated 1
adb shell settings put system haptic_feedback_enabled 0
adb shell settings put system sound_effects_enabled 0
adb shell settings put system lockscreen_sounds_enabled 0
adb shell settings put global heads_up_notifications_enabled 0
adb shell settings put secure notification_badging 0
adb shell settings put system badge_app_icon_type 0
adb shell settings put system screen_off_timeout 30000
```

### 7. Enforce DNS-over-TLS (CleanBrowsing)
```bash
adb shell settings put global private_dns_mode hostname
adb shell settings put global private_dns_specifier family-filter-dns.cleanbrowsing.org
```

---

## Manual Rollback Reference

```bash
# 1. Restore applications & application stores
adb shell cmd package install-existing com.android.vending
adb shell cmd package install-existing com.sec.android.app.samsungapps
adb shell cmd package install-existing com.android.chrome
adb shell cmd package install-existing com.google.android.youtube
adb shell pm enable com.android.vending
adb shell pm enable com.sec.android.app.samsungapps
adb shell pm enable com.android.chrome
adb shell pm enable com.google.android.youtube

# 2. Restore full-color display
adb shell settings put system greyscale_mode 0
adb shell settings put secure accessibility_display_daltonizer_enabled 0
adb shell settings put secure reduce_bright_colors_activated 0

# 3. Restore Samsung One UI Home launcher
adb shell cmd role add-role-holder --user 0 android.app.role.HOME com.sec.android.app.launcher
adb shell cmd package set-home-activity com.sec.android.app.launcher/com.sec.android.app.launcher.activities.LauncherActivity
adb shell pm disable-user --user 0 app.olauncher
adb shell am start -a android.intent.action.MAIN -c android.intent.category.HOME

# 4. Restore sideloading permissions
adb shell settings put secure install_non_market_apps 1
adb shell cmd appops set org.telegram.messenger REQUEST_INSTALL_PACKAGES allow

# 5. Restore animations, haptics, sounds, badges, and default DNS
adb shell settings put global window_animation_scale 1.0
adb shell settings put global transition_animation_scale 1.0
adb shell settings put global animator_duration_scale 1.0
adb shell settings put system haptic_feedback_enabled 1
adb shell settings put system sound_effects_enabled 1
adb shell settings put system lockscreen_sounds_enabled 1
adb shell settings put global heads_up_notifications_enabled 1
adb shell settings put secure notification_badging 1
adb shell settings put system screen_off_timeout 60000
adb shell settings delete global private_dns_specifier
adb shell settings put global private_dns_mode opportunistic
```

---

## Technical Considerations

- **Package State Integrity**: Third-party applications are disabled using `pm disable-user --user 0` instead of `pm uninstall -k --user 0`. The `-k` flag on non-system apps creates orphaned `installed=false` package records, which corrupts Google Play Store reinstallations.
- **Knox Security Integrity**: Standard ADB shell configuration modifies user-space system settings tables (`global`, `secure`, `system`). No kernel binaries, recovery partitions, or bootloaders are modified. Knox warranty counter remains intact at `0x0`.

---

## License

This project is licensed under the [MIT License](LICENSE).  
Olauncher is licensed under [GPLv3](https://github.com/tanujnotes/Olauncher).
