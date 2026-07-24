#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.14"
# ///
import json
import os
import re
import sqlite3
import subprocess
import sys
import time
from pathlib import Path

if "TMUX" not in os.environ:
    sys.exit("Error: Not inside a tmux session")

AGENTS = ("claude", "codex", "opencode")
RESET = "\033[0m"
SECONDARY = "\033[2m"
SUCCESS = "\033[32m"
WARNING = "\033[33m"
STATE_ORDER = (WARNING, SUCCESS, SECONDARY)
CLAUDE_COLORS = {"waiting": WARNING, "busy": SUCCESS}
OPENCODE_BUSY_MS = 60000
TAIL_BYTES = 262144


def tail_entries(path):
    with open(path, "rb") as f:
        f.seek(0, os.SEEK_END)
        f.seek(max(0, f.tell() - TAIL_BYTES))
        chunk = f.read()
    for line in reversed(chunk.splitlines()):
        try:
            yield json.loads(line)
        except json.JSONDecodeError:
            continue


def load_claude_agents():
    try:
        out = subprocess.run(
            ["claude", "agents", "--json"],
            capture_output=True,
            text=True,
            timeout=10,
            check=True,
        ).stdout
        return {a["pid"]: a for a in json.loads(out) if "pid" in a}
    except OSError, subprocess.SubprocessError, json.JSONDecodeError:
        return {}


def claude_agent(pane_pid, children, agents):
    stack = [int(pane_pid)]
    while stack:
        pid = stack.pop()
        if pid in agents:
            return agents[pid]
        stack.extend(children.get(pid, ()))
    return None


def codex_state(cwd):
    sessions = Path.home() / ".codex" / "sessions"
    files = sorted(
        sessions.glob("*/*/*/*.jsonl"), key=lambda p: p.stat().st_mtime, reverse=True
    )
    for path in files[:20]:
        with open(path, encoding="utf-8") as f:
            try:
                meta = json.loads(f.readline())
            except json.JSONDecodeError:
                continue
        if (meta.get("payload") or {}).get("cwd") != cwd:
            continue
        for entry in tail_entries(path):
            payload = entry.get("payload") or {}
            if payload.get("type") in ("task_started", "task_complete", "turn_aborted"):
                return payload["type"] == "task_started"
        return False
    return False


def opencode_state(cwd):
    db = Path.home() / ".local" / "share" / "opencode" / "opencode.db"
    try:
        with sqlite3.connect(f"file:{db}?mode=ro", uri=True) as con:
            row = con.execute(
                "SELECT title, time_updated FROM session"
                " WHERE directory = ? AND parent_id IS NULL"
                " ORDER BY time_updated DESC LIMIT 1",
                (cwd,),
            ).fetchone()
    except sqlite3.Error:
        return "", False
    if not row:
        return "", False
    title, updated = row
    busy = time.time() * 1000 - (updated or 0) < OPENCODE_BUSY_MS
    return title or "", busy


panes = subprocess.run(
    [
        "tmux",
        "list-panes",
        "-a",
        "-F",
        "#{pane_id}\t#{pane_pid}\t#{session_name}\t#{pane_current_command}\t#{pane_current_path}\t#{pane_title}",
    ],
    capture_output=True,
    text=True,
    check=True,
).stdout

claude_agents = load_claude_agents()
children = {}
for line in subprocess.run(
    ["ps", "-Ao", "pid=,ppid="], capture_output=True, text=True, check=True
).stdout.splitlines():
    pid, ppid = map(int, line.split())
    children.setdefault(ppid, []).append(pid)

rows = []
for line in panes.splitlines():
    pane_id, pane_pid, session, command, path, title = line.split("\t", 5)
    title = re.sub(r"^[✳⠀-⣿]\s*", "", title)
    agent = next((a for a in AGENTS if command.startswith(a)), None)
    if agent is None:
        continue
    if agent == "claude":
        info = claude_agent(pane_pid, children, claude_agents) or {}
        color = CLAUDE_COLORS.get(info.get("status"), SECONDARY)
        summary = title or info.get("name", "")
    elif agent == "codex":
        color = SUCCESS if codex_state(path) else SECONDARY
        summary = ""
    else:
        summary, busy = opencode_state(path)
        color = SUCCESS if busy else SECONDARY
    rows.append((pane_id, session, agent, summary, color))

rows.sort(key=lambda r: STATE_ORDER.index(r[4]))

if not rows:
    print("No agent panes")
    time.sleep(1)
    sys.exit(0)

entries = []
for pane_id, session, agent, summary, color in rows:
    label = agent
    if summary:
        label += f" - {summary}"
    entries.append(f"{pane_id}\t{color}●{RESET} {session}\n  {SECONDARY}{label}{RESET}")

fzf = subprocess.run(
    [
        "fzf",
        "--ansi",
        "--reverse",
        "--read0",
        "--no-input",
        "--bind",
        "j:down,k:up,q:abort",
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
subprocess.run(["tmux", "select-window", "-t", target], check=True)
subprocess.run(["tmux", "select-pane", "-t", target], check=True)
