#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.14"
# ///
import json
import os
import re
import subprocess
import sys
import time
from pathlib import Path
from typing import NamedTuple

if "TMUX" not in os.environ:
    sys.exit("Error: Not inside a tmux session")

RESET = "\033[0m"
SECONDARY = "\033[2m"
SUCCESS = "\033[32m"
WARNING = "\033[33m"
STATE_COLORS = {"waiting": WARNING, "busy": SUCCESS, "idle": SECONDARY}
STATE_ORDER = tuple(STATE_COLORS)


class Row(NamedTuple):
    pane_id: str
    window: str
    name: str
    summary: str
    state: str


def tmux(*args):
    return subprocess.run(
        ["tmux", *args], capture_output=True, text=True, check=True
    ).stdout


def agent_states():
    try:
        agents = json.loads(
            subprocess.run(
                ["claude", "agents", "--json"],
                capture_output=True,
                text=True,
                check=True,
                timeout=2,
            ).stdout
        )
    except OSError, subprocess.SubprocessError, ValueError:
        return {}
    by_pid = {str(a["pid"]): a.get("status") for a in agents if "pid" in a}
    if not by_pid:
        return {}
    ps = subprocess.run(
        ["ps", "-o", "pid=,ppid=", "-p", ",".join(by_pid)],
        capture_output=True,
        text=True,
        check=False,
    ).stdout
    states = {}
    for line in ps.split("\n"):
        fields = line.split()
        if len(fields) == 2:
            states[fields[1]] = by_pid.get(fields[0])
    return states


def repo_name(path):
    p = Path(path)
    for d in (p, *p.parents):
        if (d / ".git").exists():
            return d.name
    return p.name


panes = tmux(
    "list-panes",
    "-a",
    "-F",
    "#{pane_id}\t#{pane_pid}\t#{window_id}\t#{pane_current_command}\t#{pane_current_path}\t#{pane_title}",
)
states = agent_states()

rows = []
for line in panes.splitlines():
    pane_id, pane_pid, window, command, path, title = line.split("\t", 5)
    if not command.startswith("claude"):
        continue
    state = states.get(pane_pid)
    if state not in STATE_COLORS:
        state = "busy" if re.match(r"[◐-◓]", title) else "idle"
    summary = re.sub(r"^[✳◐-◓]\s*", "", title)
    rows.append(Row(pane_id, window, repo_name(path), summary, state))

rows.sort(key=lambda r: STATE_ORDER.index(r.state))

if not rows:
    print("No agent panes")
    time.sleep(1)
    sys.exit(0)

cur_window, cur_pane = (
    tmux("display", "-p", "#{window_id}\t#{pane_id}").strip().split("\t")
)
pos = next(
    (i for i, r in enumerate(rows) if r.pane_id == cur_pane),
    next((i for i, r in enumerate(rows) if r.window == cur_window), 0),
)

entries = []
for row in rows:
    label = "claude"
    if row.summary:
        label += f" - {row.summary}"
    entries.append(
        f"{row.pane_id}\t{STATE_COLORS[row.state]}●{RESET} {row.name}\n"
        f"  {SECONDARY}{label}{RESET}"
    )

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
        "bg+:0",
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
tmux("switch-client", "-t", target)
