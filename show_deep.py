import os
import json

base_dir = os.path.dirname(os.path.abspath(__file__))
json_path = os.path.join(base_dir, 'deep_dopamine_analysis.json')

if not os.path.exists(json_path):
    print(f"[!] File '{json_path}' not found.")
    print("[*] Collect statistics first: run `collect_stats.bat` (or `python collect_stats.py`).")
    exit(1)

with open(json_path, 'r', encoding='utf-8') as f:
    d = json.load(f)

print('=== HOURLY ACTIVITY DISTRIBUTION (00:00 - 23:00) ===')
for h, count in d.get('hourly_distribution', {}).items():
    bar = '#' * (count // 2)
    print(f"{int(h):02d}:00 | {count:>3} {bar}")

print('\n=== TOP CONTEXT-SWITCHING DOPAMINE LOOPS ===')
for pair, count in d.get('top_app_switches', [])[:10]:
    print(f"{pair:<35} : {count} switches")

print('\n=== TOP NOTIFICATION INTERRUPTIONS ===')
for pkg, count in d.get('top_notifications_received', [])[:10]:
    print(f"{pkg:<35} : {count} pings")

print('\n=== LONGEST CONTINUOUS SESSIONS (Binge Sessions) ===')
for b in d.get('longest_binges', []):
    mins = b['duration_sec'] / 60.0
    print(f"{b['pkg']:<35} : {mins:.1f} mins ({b['start']})")
