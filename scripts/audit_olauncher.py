import os
import sys
import zipfile
import re

base_dir = os.path.dirname(os.path.abspath(__file__))
apk_path = sys.argv[1] if len(sys.argv) > 1 else os.path.join(base_dir, 'Olauncher.apk')

if not os.path.exists(apk_path):
    print(f"[!] Target APK not found: {apk_path}")
    print("Run `python download_launcher.py` to download the latest release.")
    sys.exit(1)

print(f"Auditing APK bytecode: {apk_path}")

trackers_and_ads = [
    'com.google.android.gms.ads',
    'com.google.firebase.analytics',
    'com.facebook.ads',
    'com.unity3d.ads',
    'com.applovin',
    'com.ironsource',
    'com.adjust.sdk',
    'com.appsflyer',
    'com.mixpanel',
    'io.branch',
    'com.flurry',
    'com.mbridge',
    'com.vungle',
    'com.chartboost'
]

dex_files = []
with zipfile.ZipFile(apk_path, 'r') as z:
    for name in z.namelist():
        if name.endswith('.dex'):
            dex_files.append((name, z.read(name)))

print(f"Found {len(dex_files)} DEX file(s).")

detected_trackers = []
for dex_name, data in dex_files:
    text = data.decode('latin1', errors='ignore')
    for tracker in trackers_and_ads:
        if tracker in text:
            detected_trackers.append((dex_name, tracker))

if detected_trackers:
    print(f"[!] Warning: Detected tracking or advertisement SDKs: {detected_trackers}")
else:
    print("[+] CLEAN: Zero known advertising or tracking SDKs found in DEX bytecode!")

urls = set()
for dex_name, data in dex_files:
    found = re.findall(r'https?://[a-zA-Z0-9\.\-_/]+', data.decode('latin1', errors='ignore'))
    for u in found:
        if 'schemas.android.com' not in u and 'w3.org' not in u:
            urls.add(u[:60])

print(f"\nDiscovered URL/Domain references in binary ({len(urls)} found):")
for u in sorted(urls)[:20]:
    print(f"  - {u}")
