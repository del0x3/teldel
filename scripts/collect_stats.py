import os
import re
import sys
import json
import shutil
import subprocess
import webbrowser
from collections import defaultdict
from datetime import datetime

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
    root_adb = os.path.join(base_dir, '..', 'platform-tools', 'adb.exe')
    if os.path.exists(root_adb):
        return root_adb
    sdk_adb = os.path.expandvars(r'%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe')
    if os.path.exists(sdk_adb):
        return sdk_adb
    return 'adb'

def parse_time(t_str):
    parts = t_str.split(':')
    try:
        if len(parts) == 2:
            return int(parts[0]) * 60 + int(parts[1])
        elif len(parts) == 3:
            return int(parts[0]) * 3600 + int(parts[1]) * 60 + int(parts[2])
        elif len(parts) == 4:
            return int(parts[0]) * 86400 + int(parts[1]) * 3600 + int(parts[2]) * 60 + int(parts[3])
    except Exception:
        pass
    return 0

def parse_aggregate_packages(full_text):
    packages = {}
    intervals = []
    for line in full_text.splitlines():
        line_str = line.strip()
        if 'timeRange=' in line_str:
            intervals.append(line_str)
        m = re.search(r'package=([^\s]+)\s+totalTimeUsed="([^"]+)".*?appLaunchCount=(\d+)', line)
        if m:
            pkg = m.group(1)
            t_str = m.group(2)
            launches = int(m.group(3))
            seconds = parse_time(t_str)
            if pkg not in packages or seconds > packages[pkg]['seconds']:
                packages[pkg] = {
                    'pkg': pkg,
                    'time_str': t_str,
                    'seconds': seconds,
                    'launches': launches
                }
    return sorted(packages.values(), key=lambda x: x['seconds'], reverse=True)

def parse_multi_intervals(full_text):
    sections = re.split(r'timeRange="', full_text)
    results = {}
    for sec in sections[1:]:
        header_end = sec.find('"')
        tr = sec[:header_end]
        pkgs = {}
        for line in sec.split('\n'):
            m = re.search(r'package=([^\s]+)\s+totalTimeUsed="([^"]+)".*?appLaunchCount=(\d+)', line)
            if m:
                p = m.group(1)
                t = m.group(2)
                l = int(m.group(3))
                s = parse_time(t)
                if s > 0 or l > 0:
                    pkgs[p] = {'pkg': p, 'time_str': t, 'seconds': s, 'launches': l}
        sorted_p = sorted(pkgs.values(), key=lambda x: x['seconds'], reverse=True)
        total_sec = sum(x['seconds'] for x in sorted_p)
        results[tr] = {
            'total_hours': total_sec / 3600.0,
            'packages': sorted_p
        }
    return results

def mine_dopamine_loops(full_text):
    event_pattern = re.compile(r'time="([^"]+)"\s+type=([^\s]+)\s+package=([^\s]+)(?:\s+class=([^\s]+))?')
    events = []
    for line in full_text.splitlines():
        m = event_pattern.search(line)
        if m:
            t_str, ev_type, pkg, cls = m.group(1), m.group(2), m.group(3), m.group(4) or ''
            try:
                dt = datetime.strptime(t_str, "%Y-%m-%d %H:%M:%S")
                events.append({'time': dt, 'type': ev_type, 'package': pkg, 'class': cls})
            except Exception:
                pass

    events.sort(key=lambda x: x['time'])
    hourly_activity = defaultdict(int)
    app_switches = defaultdict(int)
    notifications_by_pkg = defaultdict(int)
    night_events = []

    resumed_events = [e for e in events if e['type'] == 'ACTIVITY_RESUMED']
    notif_events = [e for e in events if e['type'] == 'NOTIFICATION_INTERRUPTION']

    for ne in notif_events:
        notifications_by_pkg[ne['package']] += 1

    prev_pkg = None
    for re_ev in resumed_events:
        h = re_ev['time'].hour
        hourly_activity[h] += 1
        if h >= 23 or h < 6:
            night_events.append(re_ev)
        curr_pkg = re_ev['package']
        if prev_pkg and prev_pkg != curr_pkg:
            pair = f"{prev_pkg.split('.')[-1]} -> {curr_pkg.split('.')[-1]}"
            app_switches[pair] += 1
        prev_pkg = curr_pkg

    sessions = []
    current_session_start = None
    current_session_pkg = None

    for e in events:
        if e['type'] == 'ACTIVITY_RESUMED':
            if current_session_start is None:
                current_session_start = e['time']
                current_session_pkg = e['package']
            elif e['package'] != current_session_pkg:
                dur = (e['time'] - current_session_start).total_seconds()
                if dur > 0:
                    sessions.append({'pkg': current_session_pkg, 'duration_sec': dur, 'start': str(current_session_start)})
                current_session_start = e['time']
                current_session_pkg = e['package']
        elif e['type'] in ['ACTIVITY_PAUSED', 'SCREEN_NON_INTERACTIVE']:
            if current_session_start:
                dur = (e['time'] - current_session_start).total_seconds()
                if dur > 0:
                    sessions.append({'pkg': current_session_pkg, 'duration_sec': dur, 'start': str(current_session_start)})
                current_session_start = None
                current_session_pkg = None

    micro_checks = [s for s in sessions if s['duration_sec'] < 20 and 'launcher' not in s['pkg']]
    binge_sessions = [s for s in sessions if s['duration_sec'] > 1800]
    top_switches = sorted(app_switches.items(), key=lambda x: x[1], reverse=True)[:15]
    top_notifs = sorted(notifications_by_pkg.items(), key=lambda x: x[1], reverse=True)[:15]
    hourly_dist = {h: hourly_activity.get(h, 0) for h in range(24)}

    return {
        'total_events': len(events),
        'total_sessions': len(sessions),
        'micro_checks_count': len(micro_checks),
        'binge_sessions_count': len(binge_sessions),
        'night_activity_count': len(night_events),
        'hourly_distribution': hourly_dist,
        'top_app_switches': top_switches,
        'top_notifications_received': top_notifs,
        'longest_binges': sorted(binge_sessions, key=lambda x: x['duration_sec'], reverse=True)[:10]
    }

def main():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.abspath(os.path.join(base_dir, '..'))
    data_dir = os.path.join(project_root, 'data')
    os.makedirs(data_dir, exist_ok=True)

    print("================================================================")
    print("       DATA COLLECTION & DOPAMINE ADDICTION MINING")
    print("================================================================")

    full_text = None
    adb = find_adb()

    # 1. Try dumping live from device
    try:
        res = subprocess.run([adb, "devices"], capture_output=True, text=True, timeout=15)
        if "device" in res.stdout and len(res.stdout.strip().splitlines()) > 1:
            print("[+] Connected Android device detected via ADB.")
            print("[*] Pulling dumpsys usagestats...")
            dump = subprocess.run([adb, "shell", "dumpsys", "usagestats"], capture_output=True, text=True, encoding='utf-8', errors='ignore', timeout=30)
            if dump.returncode == 0 and len(dump.stdout) > 500:
                full_text = dump.stdout
                raw_dump_path = os.path.join(data_dir, "full_usagestats.txt")
                with open(raw_dump_path, "w", encoding="utf-8", errors="ignore") as f:
                    f.write(full_text)
                print(f"[+] Raw usagestats dumped: {len(full_text)} characters")
    except Exception as e:
        print(f"[*] ADB pull skipped or failed ({e}). Checking local cache...")

    # 2. If ADB pull failed or offline, load from cached file
    if not full_text:
        candidates = [
            os.path.join(data_dir, "full_usagestats.txt"),
            os.path.join(project_root, "full_usagestats.txt"),
            os.path.join(base_dir, "full_usagestats.txt")
        ]
        cached_file = next((p for p in candidates if os.path.exists(p)), None)
        if cached_file:
            print(f"[*] Reading cached stats from {cached_file}...")
            with open(cached_file, "r", encoding="utf-8", errors="ignore") as f:
                full_text = f.read()
        else:
            print("\n[!] Error: No Android phone detected via ADB and no cached full_usagestats.txt found.")
            print("1. Connect your phone with a USB cable.")
            print("2. Enable USB Debugging in Developer Options.")
            print("3. Authorize connection on phone screen.")
            sys.exit(1)

    # 3. Process Package Aggregates
    print("\n[1/3] Parsing Package Usage Aggregates...")
    sorted_pkgs = parse_aggregate_packages(full_text)
    out_parsed = os.path.join(data_dir, 'parsed_stats.json')
    with open(out_parsed, 'w', encoding='utf-8') as f:
        json.dump(sorted_pkgs, f, indent=2)
    print(f"    Saved: {os.path.basename(out_parsed)} ({len(sorted_pkgs)} packages)")

    # 4. Process Multi-Interval Ranges
    print("[2/3] Analyzing Multi-Interval Ranges (Daily, Weekly, Monthly, Yearly)...")
    multi_intervals = parse_multi_intervals(full_text)
    out_intervals = os.path.join(data_dir, 'multi_interval_stats.json')
    with open(out_intervals, 'w', encoding='utf-8') as f:
        json.dump(multi_intervals, f, indent=2)
    print(f"    Saved: {os.path.basename(out_intervals)} ({len(multi_intervals)} intervals)")

    # 5. Mine Dopamine Addiction Patterns
    print("[3/3] Mining Dopamine Traps, Micro-checks & Continuous Binges...")
    deep_data = mine_dopamine_loops(full_text)
    out_deep = os.path.join(data_dir, 'deep_dopamine_analysis.json')
    with open(out_deep, 'w', encoding='utf-8') as f:
        json.dump(deep_data, f, indent=2, default=str)
    print(f"    Saved: {os.path.basename(out_deep)}")

    # Summary Display
    print("\n" + "=" * 64)
    print("                     AUDIT SUMMARY")
    print("=" * 64)
    print(f"Total App Events Recorded:    {deep_data['total_events']}")
    print(f"Total Discrete Sessions:      {deep_data['total_sessions']}")
    print(f"Impulsive Micro-Checks (<20s):{deep_data['micro_checks_count']}")
    print(f"Continuous Binges (>30 mins): {deep_data['binge_sessions_count']}")
    print(f"Nighttime Events (23:00-06:00):{deep_data['night_activity_count']}")
    print("=" * 64)

    dash_path = os.path.join(project_root, "docs", "dopamine_interactive_dashboard.html")
    if os.path.exists(dash_path):
        print(f"\n[+] Interactive Dashboard available at: {dash_path}")
        if sys.stdin.isatty() and "--no-browser" not in sys.argv:
            try:
                ans = input("\nOpen interactive dashboard in web browser now? (Y/N): ").strip()
                if ans.lower() in ['y', 'yes']:
                    webbrowser.open(f"file:///{os.path.abspath(dash_path).replace(os.sep, '/')}")
            except (EOFError, KeyboardInterrupt):
                pass

if __name__ == '__main__':
    main()
