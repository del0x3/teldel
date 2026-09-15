import os
import re
import json

base_dir = os.path.dirname(os.path.abspath(__file__))
candidates = [
    os.path.join(base_dir, 'full_usagestats.txt'),
    os.path.join(base_dir, '..', 'full_usagestats.txt'),
    os.path.join(base_dir, '..', 'data', 'full_usagestats.txt'),
    'full_usagestats.txt'
]
stats_file = next((p for p in candidates if os.path.exists(p)), None)

if not stats_file:
    print("[!] File 'full_usagestats.txt' was not found.")
    print("[*] Collect stats first by running `collect_stats.bat` (or `python collect_stats.py`).")
    exit(1)

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

def load_lines(filepath):
    for enc in ['utf-8', 'utf-16', 'latin1']:
        try:
            with open(filepath, 'r', encoding=enc, errors='ignore') as f:
                lines = f.readlines()
                if any('package=' in l or 'timeRange=' in l for l in lines[:100]):
                    return lines
        except Exception:
            continue
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        return f.readlines()

packages = {}
intervals = []

for line in load_lines(stats_file):
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

sorted_pkgs = sorted(packages.values(), key=lambda x: x['seconds'], reverse=True)

print(f"Tracked intervals found: {len(intervals)}")
for i in intervals[:5]:
    print(f"  Interval: {i}")

print("\n" + "=" * 80)
print(f"{'Package':<45} | {'Time':<12} | {'Hours':<8} | {'Launches':<10}")
print("=" * 80)

total_phone_seconds = 0
for p in sorted_pkgs:
    if p['seconds'] > 0:
        total_phone_seconds += p['seconds']

for p in sorted_pkgs[:50]:
    if p['seconds'] > 0:
        hours = p['seconds'] / 3600.0
        print(f"{p['pkg']:<45} | {p['time_str']:<12} | {hours:<8.1f} | {p['launches']:<10}")

print(f"\nTotal Recorded App Screen Time: {total_phone_seconds / 3600.0:.1f} hours ({total_phone_seconds / 86400.0:.1f} full days)")

data_dir = os.path.join(base_dir, '..', 'data') if os.path.exists(os.path.join(base_dir, '..', 'data')) else base_dir
out_json = os.path.join(data_dir, 'parsed_stats.json')
with open(out_json, 'w', encoding='utf-8') as f:
    json.dump(sorted_pkgs, f, indent=2)

print(f"Saved {out_json}")
