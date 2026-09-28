#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.14"
# ///
import json
import sys
import time

BRAILLE = "⠀⡀⣀⣤⣶⣿"
GREEN, YELLOW, RED = "\033[32m", "\033[33m", "\033[31m"
RESET = "\033[0m"
SEP = " | "
FIVE_HOURS = 5 * 3600
SEVEN_DAYS = 7 * 86400


def level_color(value: float, warning: float, critical: float) -> str:
    if value >= critical:
        return RED
    if value >= warning:
        return YELLOW
    return GREEN


def pace_color(
    pct: int, resets_at: int | None, window: int, warning: int, critical: int
) -> str:
    if resets_at is None:
        return level_color(pct, warning, critical)
    remaining = min(window, max(0, resets_at - time.time()))
    elapsed_pct = 100 - remaining * 100 / window
    return level_color(pct - elapsed_pct, 10, 25)


def gauge(pct: int, color: str) -> str:
    level = max(1, min(10, pct * 10 // 100))
    if level >= 5:
        hi, lo = BRAILLE[5], BRAILLE[level - 5]
    else:
        hi, lo = BRAILLE[level], BRAILLE[0]
    gap = "" if lo == BRAILLE[0] else " "
    return f"{color}{hi}{lo}{gap}{pct}%{RESET}"


try:
    data = json.load(sys.stdin)
    model = (
        (data.get("model", {}).get("display_name") or "unknown").split("(")[0].strip()
    )
    effort = data.get("effort", {}).get("level")
    ctx_size = int(data.get("context_window", {}).get("context_window_size") or 0)
    ctx_pct = int(data.get("context_window", {}).get("used_percentage") or 0)
    five_hour = data.get("rate_limits", {}).get("five_hour", {})
    raw_5h = five_hour.get("used_percentage")
    rate_5h_pct = int(raw_5h) if raw_5h is not None else -1
    raw_5h_reset = five_hour.get("resets_at")
    rate_5h_reset = int(raw_5h_reset) if raw_5h_reset is not None else None
    seven_day = data.get("rate_limits", {}).get("seven_day", {})
    raw_7d = seven_day.get("used_percentage")
    rate_7d_pct = int(raw_7d) if raw_7d is not None else -1
    raw_7d_reset = seven_day.get("resets_at")
    rate_7d_reset = int(raw_7d_reset) if raw_7d_reset is not None else None
except Exception:  # noqa: BLE001
    print("claude")
    sys.exit()

line = model
if ctx_size >= 1_000_000:
    line += " (1M)"
if effort:
    line += f" - {effort}"
line += f"{SEP}context {gauge(ctx_pct, level_color(ctx_pct, 70, 90))}"
if rate_5h_pct >= 0:
    line += f"{SEP}5h {gauge(rate_5h_pct, pace_color(rate_5h_pct, rate_5h_reset, FIVE_HOURS, 60, 80))}"
else:
    line += f"{SEP}5h --%"
if rate_7d_pct >= 0:
    line += f"{SEP}7d {gauge(rate_7d_pct, pace_color(rate_7d_pct, rate_7d_reset, SEVEN_DAYS, 50, 70))}"
else:
    line += f"{SEP}7d --%"

print(line)
