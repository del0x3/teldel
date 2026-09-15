import os
import urllib.request
import json

base_dir = os.path.dirname(os.path.abspath(__file__))
apk_target = os.path.join(base_dir, 'Olauncher.apk')

print("Fetching latest Olauncher release from GitHub...")
req = urllib.request.Request(
    'https://api.github.com/repos/tanujnotes/Olauncher/releases/latest',
    headers={'User-Agent': 'Mozilla/5.0'}
)
try:
    with urllib.request.urlopen(req) as resp:
        data = json.loads(resp.read().decode('utf-8'))

    apk_url = None
    for asset in data.get('assets', []):
        if asset['name'].endswith('.apk'):
            apk_url = asset['browser_download_url']
            print(f"Found APK asset: {asset['name']} -> {apk_url}")
            break

    if apk_url:
        print(f"Downloading to {apk_target}...")
        urllib.request.urlretrieve(apk_url, apk_target)
        print("[+] Downloaded Olauncher.apk successfully!")
    else:
        print("[!] No APK asset found in latest release.")
except Exception as e:
    print(f"[!] Error fetching release: {e}")
