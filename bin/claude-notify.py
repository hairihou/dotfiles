#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.15"
# ///
import sys
from pathlib import Path
lazy import subprocess

if not sys.stdin.isatty():
    sys.stdin.read()

sound = (
    Path.home()
    / "dotfiles/public"
    / f"{sys.argv[1] if len(sys.argv) > 1 else 'stop'}.mp3"
)
if sound.exists():
    subprocess.Popen(
        ["afplay", str(sound)],
        stdin=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
