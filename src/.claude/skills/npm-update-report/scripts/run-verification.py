#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.13"
# ///
"""Run available verification scripts and report results.

Usage: ./run-verification.py <pm>
Checks: lint, typecheck, test, build (skips if script not defined in package.json)
Output: one line per script: PASS|FAIL|SKIP <script-name> [error-summary]
"""

import json
import subprocess
import sys

pm = sys.argv[1] if len(sys.argv) > 1 else sys.exit("Usage: run-verification.py <pm>")
SCRIPTS = ["lint", "typecheck", "test", "build"]
try:
    pkg = json.loads(open("package.json").read())
    available = set(pkg.get("scripts", {}).keys())
except (FileNotFoundError, json.JSONDecodeError):
    available = set()
for script in SCRIPTS:
    if script not in available:
        print(f"SKIP {script}")
        continue
    result = subprocess.run([pm, "run", script], capture_output=True, text=True)
    if result.returncode == 0:
        print(f"PASS {script}")
    else:
        output = result.stdout + result.stderr
        summary = " ".join(output.strip().splitlines()[-5:])
        print(f"FAIL {script} {summary}")
