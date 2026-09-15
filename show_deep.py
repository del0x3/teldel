import os
import json

base_dir = os.path.dirname(os.path.abspath(__file__))
json_path = os.path.join(base_dir, 'deep_dopamine_analysis.json')

if not os.path.exists(json_path):
    print(f"[!] Файл {json_path} не найден.")
    print("[*] Сначала запустите сбор статистики: collect_stats.bat (или python collect_stats.py)")
    exit(1)

with open(json_path, 'r', encoding='utf-8') as f:
    d = json.load(f)

print('=== РАСПРЕДЕЛЕНИЕ АКТИВНОСТИ ПО ЧАСАМ СУТОК (00:00 - 23:00) ===')
for h, count in d.get('hourly_distribution', {}).items():
    bar = '#' * (count // 2)
    print(f"{int(h):02d}:00 | {count:>3} {bar}")

print('\n=== ТОП ДОФАМИНОВЫХ ПЕТЕЛЬ (Переключения между приложениями) ===')
for pair, count in d.get('top_app_switches', [])[:10]:
    print(f"{pair:<35} : {count} раз")

print('\n=== ТОП ПРИЛОЖЕНИЙ ПО УВЕДОМЛЕНИЯМ (Прерывания) ===')
for pkg, count in d.get('top_notifications_received', [])[:10]:
    print(f"{pkg:<35} : {count} пингов")

print('\n=== САМЫЕ ДЛИННЫЕ НЕПРЕРЫВНЫЕ СЕССИИ (Binge sessions) ===')
for b in d.get('longest_binges', []):
    mins = b['duration_sec'] / 60.0
    print(f"{b['pkg']:<35} : {mins:.1f} мин ({b['start']})")
