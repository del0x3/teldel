import subprocess
import time
import xml.etree.ElementTree as ET
import re
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
dyn_xml = os.path.join(base_dir, "dyn_ui.xml")

def run_adb(cmd):
    full = f'"{adb}" shell {cmd}'
    res = subprocess.run(full, shell=True, capture_output=True, text=True)
    return res.stdout.strip()

def dump_ui():
    run_adb("uiautomator dump /sdcard/dyn_ui.xml")
    pull_cmd = f'"{adb}" pull /sdcard/dyn_ui.xml "{dyn_xml}"'
    subprocess.run(pull_cmd, shell=True, capture_output=True)
    tree = ET.parse(dyn_xml)
    return tree.getroot()

def get_center(bounds_str):
    m = re.match(r'\[(\d+),(\d+)\]\[(\d+),(\d+)\]', bounds_str)
    if m:
        x1, y1, x2, y2 = map(int, m.groups())
        return (x1 + x2) // 2, (y1 + y2) // 2
    return 540, 500

print("Step 1: Bringing Olauncher to front and searching...")
run_adb("input keyevent 3") # Home
time.sleep(0.3)
run_adb("input swipe 500 1800 500 500 200") # Swipe up
time.sleep(0.4)
run_adb("input text auth") # Search auth
time.sleep(0.5)

names = ["MS_Auth", "Bitwarden_Auth", "Google_Auth"]

for idx, new_name in enumerate(names):
    print(f"--- Renaming item {idx+1} -> {new_name} ---")
    root = dump_ui()
    
    # Find items with text="Authenticator"
    auth_nodes = []
    for node in root.iter('node'):
        if node.attrib.get('text') == 'Authenticator':
            auth_nodes.append(node)
            
    print(f"Found {len(auth_nodes)} Authenticator nodes.")
    if not auth_nodes:
        print("No more Authenticator nodes found, finishing.")
        break
        
    # Long press the first remaining 'Authenticator'
    target_node = auth_nodes[0]
    cx, cy = get_center(target_node.attrib['bounds'])
    print(f"Long pressing item at ({cx}, {cy})...")
    run_adb(f"input swipe {cx} {cy} {cx} {cy} 1100")
    time.sleep(0.5)
    
    # Dump UI to find 'Rename' button
    menu_root = dump_ui()
    rename_btn = None
    for n in menu_root.iter('node'):
        if n.attrib.get('text') == 'Rename':
            rename_btn = n
            break
            
    if rename_btn is not None:
        rx, ry = get_center(rename_btn.attrib['bounds'])
        print(f"Tapping 'Rename' button at ({rx}, {ry})...")
        run_adb(f"input tap {rx} {ry}")
        time.sleep(0.5)
        
        # Clear existing text
        for _ in range(25):
            run_adb("input keyevent 67") # Backspace
        time.sleep(0.2)
        
        # Input new name
        run_adb(f"input text {new_name}")
        time.sleep(0.4)
        
        # Find the confirm 'Rename' button in dialog
        diag_root = dump_ui()
        confirm_btn = None
        for n in diag_root.iter('node'):
            if n.attrib.get('text') == 'Rename':
                confirm_btn = n
                break
                
        if confirm_btn is not None:
            cfx, cfy = get_center(confirm_btn.attrib['bounds'])
            print(f"Tapping confirm button at ({cfx}, {cfy})...")
            run_adb(f"input tap {cfx} {cfy}")
            time.sleep(0.6)
            print(f"[OK] Successfully renamed to {new_name}")
    else:
        print("[!] Could not find Rename button in menu.")

run_adb("input keyevent 3") # Return to home
print("=== All authenticators renamed! ===")
