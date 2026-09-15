import os
import json

base_dir = os.path.dirname(os.path.abspath(__file__))
candidates = [
    os.path.join(base_dir, '..', 'data', 'multi_interval_stats.json'),
    os.path.join(base_dir, 'multi_interval_stats.json'),
    'multi_interval_stats.json'
]
json_path = next((p for p in candidates if os.path.exists(p)), None)

if not json_path:
    print("[!] File 'multi_interval_stats.json' not found in data/ or current folder. Run `collect_stats.bat` first.")
    exit(1)

with open(json_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

found = False
for k, v in data.items():
    if '9/7/2026' in k or '7' in k:
        print(f"=== INTERVAL ({k}) ===")
        print(f"Total: {v['total_hours']:.1f} hours ({v['total_hours']/7.0:.1f} hrs/day)")
        print("-" * 65)
        for p in v['packages'][:25]:
            h = p['seconds'] / 3600.0
            print(f"{p['pkg']:<38} | {p['time_str']:<9} | {h:5.1f}h | {p['launches']:>4} opens")
        found = True
        break

if not found and data:
    k = list(data.keys())[0]
    v = data[k]
    print(f"=== INTERVAL ({k}) ===")
    print(f"Total: {v['total_hours']:.1f} hours")
    print("-" * 65)
    for p in v['packages'][:25]:
        h = p['seconds'] / 3600.0
        print(f"{p['pkg']:<38} | {p['time_str']:<9} | {h:5.1f}h | {p['launches']:>4} opens")
