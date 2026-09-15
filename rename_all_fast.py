import subprocess
import time
import os
import shutil

base_dir = os.path.dirname(os.path.abspath(__file__))

def find_adb():
    adb_path = shutil.which("adb")
    if adb_path:
        return adb_path
    local_app_data = os.environ.get("LOCALAPPDATA", "")
    candidates = [
        os.path.join(local_app_data, r"Android\Sdk\platform-tools\adb.exe"),
        os.path.join(base_dir, r"platform-tools\adb.exe"),
        r"C:\platform-tools\adb.exe",
    ]
    for c in candidates:
        if os.path.exists(c):
            return c
    return "adb"

adb = find_adb()

def run(cmd):
    full_cmd = f'"{adb}" shell {cmd}'
    subprocess.run(full_cmd, shell=True, capture_output=True)

print("Starting automated fast renaming for Olauncher...")

# 1. Go to Home
run("input keyevent 3")
time.sleep(0.3)

# 2. Swipe up to open search
run("input swipe 500 1800 500 500 200")
time.sleep(0.5)

# 3. Type 'auth'
run("input text auth")
time.sleep(0.5)

# 4. First item: Long press at (540, 578)
print("Renaming 1st authenticator -> MS_Auth...")
run("input swipe 540 578 540 578 1000")
time.sleep(0.4)
run("input tap 324 578")
time.sleep(0.4)
for _ in range(20):
    run("input keyevent 67")
run("input text MS_Auth")
time.sleep(0.3)
run("input tap 840 578")
time.sleep(0.5)

# Clear search query and retype auth
run("input keyevent 3")
time.sleep(0.3)
run("input swipe 500 1800 500 500 200")
time.sleep(0.4)
run("input text auth")
time.sleep(0.5)

# 5. Second item: Long press at (540, 758)
print("Renaming 2nd authenticator -> Bitwarden_Auth...")
run("input swipe 540 758 540 758 1000")
time.sleep(0.4)
run("input tap 324 758")
time.sleep(0.4)
for _ in range(20):
    run("input keyevent 67")
run("input text Bitwarden_Auth")
time.sleep(0.3)
run("input tap 840 758")
time.sleep(0.5)

# 6. Third item:
run("input keyevent 3")
time.sleep(0.3)
run("input swipe 500 1800 500 500 200")
time.sleep(0.4)
run("input text auth")
time.sleep(0.5)

print("Renaming 3rd authenticator -> Google_Auth...")
run("input swipe 540 938 540 938 1000")
time.sleep(0.4)
run("input tap 324 938")
time.sleep(0.4)
for _ in range(20):
    run("input keyevent 67")
run("input text Google_Auth")
time.sleep(0.3)
run("input tap 840 938")
time.sleep(0.5)

# Return to Home
run("input keyevent 3")
print("Done automated renaming!")
