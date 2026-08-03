#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.14"
# ///
import os
import re
import subprocess
import sys
import time
from pathlib import Path

if "TMUX" not in os.environ:
    sys.exit("Error: Not inside a tmux session")

RESET = "\033[0m"
SECONDARY = "\033[2m"
SUCCESS = "\033[32m"
STATE_ORDER = (SUCCESS, SECONDARY)

panes = subprocess.run(
    [
        "tmux",
        "list-panes",
        "-a",
        "-F",
        "#{pane_id}\t#{window_id}\t#{pane_current_command}\t#{pane_current_path}\t#{pane_title}",
    ],
    capture_output=True,
    text=True,
    check=True,
).stdout

rows = []
for line in panes.splitlines():
    pane_id, window, command, path, title = line.split("\t", 4)
    if not command.startswith("claude"):
        continue
    color = SUCCESS if re.match(r"[⠀-⣿]", title) else SECONDARY
    summary = re.sub(r"^[✳⠀-⣿]\s*", "", title)
    rows.append((pane_id, window, Path(path).name, summary, color))

rows.sort(key=lambda r: STATE_ORDER.index(r[4]))

if not rows:
    print("No agent panes")
    time.sleep(1)
    sys.exit(0)

cur_window, cur_pane = (
    subprocess.run(
        ["tmux", "display", "-p", "#{window_id}\t#{pane_id}"],
        capture_output=True,
        text=True,
        check=True,
    )
    .stdout.strip()
    .split("\t")
)
pos = next(
    (i for i, r in enumerate(rows) if r[0] == cur_pane),
    next((i for i, r in enumerate(rows) if r[1] == cur_window), 0),
)

entries = []
for pane_id, window, name, summary, color in rows:
    label = "claude"
    if summary:
        label += f" - {summary}"
    entries.append(f"{pane_id}\t{color}●{RESET} {name}\n  {SECONDARY}{label}{RESET}")

fzf = subprocess.run(
    [
        "fzf",
        "--ansi",
        "--reverse",
        "--read0",
        "--no-input",
        "--bind",
        "j:down,k:up,q:abort",
        "--bind",
        f"start:pos({pos + 1})",
        "--highlight-line",
        "--color",
        "bg+:#1e2939",
        "--pointer",
        "",
        "--delimiter",
        "\t",
        "--with-nth",
        "2",
    ],
    input="\0".join(entries),
    capture_output=True,
    text=True,
    check=False,
)
if fzf.returncode != 0:
    sys.exit(0)

target = fzf.stdout.split("\t", 1)[0]
subprocess.run(["tmux", "switch-client", "-t", target], check=True)
