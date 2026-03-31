#!/usr/bin/env python3
import json, sys, subprocess, os, time

# Force UTF-8 output on Windows
sys.stdout.reconfigure(encoding='utf-8', errors='replace')

data = json.load(sys.stdin)

model = data.get('model', {}).get('display_name') or data.get('model', {}).get('id', 'Unknown')
cwd = data.get('workspace', {}).get('current_dir') or data.get('cwd') or os.getcwd()
dirname = os.path.basename(cwd)
cost = data.get('cost', {}).get('total_cost_usd', 0) or 0
pct = int(data.get('context_window', {}).get('used_percentage', 0) or 0)
duration_ms = data.get('cost', {}).get('total_duration_ms', 0) or 0

CYAN   = '\033[36m'
GREEN  = '\033[32m'
YELLOW = '\033[33m'
RED    = '\033[31m'
DIM    = '\033[2m'
RESET  = '\033[0m'

if pct >= 90:
    bar_color = RED
elif pct >= 70:
    bar_color = YELLOW
else:
    bar_color = GREEN

filled = pct // 10
bar = '[' + '#' * filled + '-' * (10 - filled) + ']'

mins = duration_ms // 60000
secs = (duration_ms % 60000) // 1000

branch = ''
try:
    subprocess.check_output(['git', 'rev-parse', '--git-dir'], stderr=subprocess.DEVNULL)
    b = subprocess.check_output(
        ['git', 'branch', '--show-current'], text=True, stderr=subprocess.DEVNULL
    ).strip()
    if b:
        branch = f' | {GREEN}{b}{RESET}'
except Exception:
    pass

def fmt_countdown(remaining_mins):
    if remaining_mins >= 1440:
        days = remaining_mins // 1440
        hours = (remaining_mins % 1440) // 60
        return f'{DIM}{days}d {hours}h{RESET}'
    if remaining_mins >= 60:
        hours = remaining_mins // 60
        mins = remaining_mins % 60
        return f'{DIM}{hours}h {mins}m{RESET}'
    return f'{DIM}{remaining_mins}m{RESET}'

def fmt_usage(used_pct, resets_at, window_mins):
    """Format rate limit: remaining% [pace delta] countdown"""
    now = int(time.time())
    remaining_pct = 100 - used_pct

    if used_pct >= 90:
        pct_str = f'{RED}{remaining_pct}%{RESET}'
    elif used_pct >= 70:
        pct_str = f'{YELLOW}{remaining_pct}%{RESET}'
    else:
        pct_str = f'{GREEN}{remaining_pct}%{RESET}'

    parts = [pct_str]

    if resets_at and resets_at > now:
        remaining_mins = max(0, (resets_at - now) // 60)

        # Pace delta: are we burning faster or slower than linear?
        if remaining_mins <= window_mins:
            pace = (window_mins - remaining_mins) * 100 // window_mins - used_pct
            if pace >= 0:
                parts.append(f'pace: {GREEN}+{pace}%{RESET}')
            else:
                parts.append(f'pace: {RED}{pace}%{RESET}')

        parts.append(fmt_countdown(remaining_mins))

    return ' '.join(parts)

rl = data.get('rate_limits', {})
rl_parts = []

five_hour = rl.get('five_hour', {})
if five_hour:
    u5 = five_hour.get('used_percentage')
    r5 = five_hour.get('resets_at', 0)
    if u5 is not None:
        rl_parts.append(f'5h {fmt_usage(int(u5), r5, 300)}')

seven_day = rl.get('seven_day', {})
if seven_day:
    u7 = seven_day.get('used_percentage')
    r7 = seven_day.get('resets_at', 0)
    if u7 is not None:
        rl_parts.append(f'7d {fmt_usage(int(u7), r7, 10080)}')

rl_str = ('  |  ' + '  |  '.join(rl_parts)) if rl_parts else ''

print(f"{CYAN}[{model}]{RESET} {dirname}{branch}")
print(f"{bar_color}{bar}{RESET} {pct}% | {YELLOW}${cost:.4f}{RESET}{rl_str}")