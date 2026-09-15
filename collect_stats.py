import os
import shutil
import subprocess
import sys
import webbrowser

def find_adb():
    if 'ADB_PATH' in os.environ and os.path.exists(os.environ['ADB_PATH']):
        return os.environ['ADB_PATH']
    which_adb = shutil.which('adb')
    if which_adb:
        return which_adb
    base_dir = os.path.dirname(os.path.abspath(__file__))
    local_adb = os.path.join(base_dir, 'platform-tools', 'adb.exe')
    if os.path.exists(local_adb):
        return local_adb
    sdk_adb = os.path.expandvars(r'%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe')
    if os.path.exists(sdk_adb):
        return sdk_adb
    return 'adb'

def main():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    adb = find_adb()
    
    print("================================================================")
    print("       DATA COLLECTION & DOPAMINE ADDICTION MINING")
    print("================================================================")
    print(f"[*] Detected ADB: {adb}")
    
    # Check device
    try:
        res = subprocess.run([adb, "devices"], capture_output=True, text=True)
        if "device" not in res.stdout or len(res.stdout.strip().splitlines()) <= 1:
            print("\n[!] Error: Android phone not detected via ADB.")
            print("1. Connect your phone via USB cable.")
            print("2. Enable 'USB Debugging' in Developer Options.")
            print("3. Authorize USB Debugging on your device screen.")
            sys.exit(1)
    except Exception as e:
        print(f"\n[!] ADB execution error: {e}")
        sys.exit(1)

    print("\n[1/3] Extracting usagestats from Android kernel (dumpsys usagestats)...")
    stats_file = os.path.join(base_dir, "full_usagestats.txt")
    try:
        proc = subprocess.run([adb, "shell", "dumpsys", "usagestats"], capture_output=True, text=True, encoding='utf-8', errors='ignore')
        with open(stats_file, "w", encoding="utf-8", errors="ignore") as f:
            f.write(proc.stdout)
        print(f"[+] Dump saved: {os.path.basename(stats_file)} ({len(proc.stdout)} chars)")
    except Exception as e:
        print(f"[!] Error writing usagestats: {e}")
        sys.exit(1)

    print("\n[2/3] Running interval parser (parse_multi.py)...")
    try:
        import parse_multi
    except Exception as e:
        print(f"[!] Error in parse_multi: {e}")

    print("\n[3/3] Deep mining dopamine loops & binge sessions (deep_dopamine_miner.py)...")
    try:
        import deep_dopamine_miner
    except Exception as e:
        print(f"[!] Error in deep_dopamine_miner: {e}")

    dash_file = os.path.join(base_dir, "dopamine_interactive_dashboard.html")
    if os.path.exists(dash_file):
        print(f"\n[+] Analysis complete! Dashboard ready: {dash_file}")
        open_web = input("\nOpen interactive dashboard in web browser? (Y/N): ").strip()
        if open_web.lower() in ['y', 'yes']:
            webbrowser.open(f"file://{dash_file}")

if __name__ == '__main__':
    main()
