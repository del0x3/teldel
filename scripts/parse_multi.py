import os
import re
import json

base_dir = os.path.dirname(os.path.abspath(__file__))
stats_file = os.path.join(base_dir, 'full_usagestats.txt')

if not os.path.exists(stats_file):
    print(f"[!] File '{stats_file}' was not found.")
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

def load_text(filepath):
    for enc in ['utf-8', 'utf-16', 'latin1']:
        try:
            with open(filepath, 'r', encoding=enc, errors='ignore') as f:
                content = f.read()
                if 'timeRange=' in content:
                    return content
        except Exception:
            continue
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        return f.read()

full_text = load_text(stats_file)

# Find sections by timeRange
sections = re.split(r'timeRange="', full_text)

results = {}

for idx, sec in enumerate(sections[1:], 1):
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

print("INTERVALS SUMMARY:")
for tr, data in results.items():
    print(f"[{tr}] -> Total screen time: {data['total_hours']:.1f} hours, {len(data['packages'])} active apps")

data_dir = os.path.join(base_dir, '..', 'data') if os.path.exists(os.path.join(base_dir, '..', 'data')) else base_dir
out_json = os.path.join(data_dir, 'multi_interval_stats.json')
with open(out_json, 'w', encoding='utf-8') as f:
    json.dump(results, f, indent=2)

print(f"Saved {out_json}")
