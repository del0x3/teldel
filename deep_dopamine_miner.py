import os
import re
import json
from collections import defaultdict
from datetime import datetime

base_dir = os.path.dirname(os.path.abspath(__file__))
stats_file = os.path.join(base_dir, 'full_usagestats.txt')

if not os.path.exists(stats_file):
    print(f"[!] Stats file '{stats_file}' not found.")
    print("[*] Connect your Android phone with USB debugging and run `collect_stats.bat` first.")
    exit(1)

print(f"Processing deep event logs from: {stats_file}")

# 1. Parse Events from full_usagestats.txt
events = []
event_pattern = re.compile(r'time="([^"]+)"\s+type=([^\s]+)\s+package=([^\s]+)(?:\s+class=([^\s]+))?')

# Check encodings
def open_stats_file(path):
    for enc in ['utf-16', 'utf-8', 'latin1']:
        try:
            with open(path, 'r', encoding=enc, errors='ignore') as f:
                content = f.read(1024)
                if 'time=' in content or 'package=' in content:
                    return open(path, 'r', encoding=enc, errors='ignore')
        except Exception:
            continue
    return open(path, 'r', encoding='utf-8', errors='ignore')

with open_stats_file(stats_file) as f:
    for line in f:
        m = event_pattern.search(line)
        if m:
            t_str, ev_type, pkg, cls = m.group(1), m.group(2), m.group(3), m.group(4) or ''
            try:
                dt = datetime.strptime(t_str, "%Y-%m-%d %H:%M:%S")
                events.append({
                    'time': dt,
                    'type': ev_type,
                    'package': pkg,
                    'class': cls
                })
            except Exception:
                pass

print(f"Parsed {len(events)} total events.")

# Sort events chronologically
events.sort(key=lambda x: x['time'])

# Analyze Hourly Distribution of Activity (resumed)
hourly_activity = defaultdict(int)
hourly_screen_on = defaultdict(int)
app_switches = defaultdict(int)
notifications_by_pkg = defaultdict(int)
night_events = [] # 23:00 - 06:00

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

# Calculate Continuous Sessions
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
binge_sessions = [s for s in sessions if s['duration_sec'] > 1800] # > 30 mins

print(f"Total user sessions identified: {len(sessions)}")
print(f"Micro-checks (<20s impulsive glance): {len(micro_checks)}")
print(f"Binge sessions (>30 min continuous stare): {len(binge_sessions)}")
print(f"Night events (23:00 - 06:00): {len(night_events)}")

# Top app switches
top_switches = sorted(app_switches.items(), key=lambda x: x[1], reverse=True)[:15]

# Top notifs
top_notifs = sorted(notifications_by_pkg.items(), key=lambda x: x[1], reverse=True)[:15]

# Hourly distribution dict
hourly_dist = {h: hourly_activity.get(h, 0) for h in range(24)}

deep_data = {
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

out_file = os.path.join(base_dir, 'deep_dopamine_analysis.json')
with open(out_file, 'w', encoding='utf-8') as f:
    json.dump(deep_data, f, indent=2, default=str)

print(f"Saved analytics to: {out_file}")
