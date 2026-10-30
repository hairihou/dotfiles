#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.15"
# ///
import json
import sys
from pathlib import Path

if sys.stdin.isatty():
    sys.exit(0)

try:
    payload = json.load(sys.stdin)
except json.JSONDecodeError, ValueError:
    sys.exit(0)

file = (payload.get("tool_input") or {}).get("file_path", "")
if not file:
    sys.exit(0)

p = Path(file)
if not p.is_file():
    sys.exit(0)
try:
    original = p.read_text()
except UnicodeDecodeError:
    sys.exit(0)
fixed = original.rstrip() + "\n"
if fixed != original:
    p.write_text(fixed)
