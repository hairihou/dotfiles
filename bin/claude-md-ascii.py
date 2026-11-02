#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.15"
# ///
import json
import os
import sys
from typing import NoReturn


def deny(reason: str) -> NoReturn:
    print(
        json.dumps(
            {
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "deny",
                    "permissionDecisionReason": reason,
                }
            }
        )
    )
    sys.exit(0)


if sys.stdin.isatty():
    sys.exit(0)

try:
    payload = json.load(sys.stdin)
except json.JSONDecodeError, ValueError:
    sys.exit(0)

tool_input = payload.get("tool_input") or {}
match payload.get("tool_name"):
    case "Write":
        text = tool_input.get("content", "")
    case "Edit":
        text = tool_input.get("new_string", "")
    case _:
        sys.exit(0)

path = os.path.realpath(tool_input.get("file_path", ""))
root = os.path.realpath(os.environ.get("CLAUDE_PROJECT_DIR") or payload.get("cwd", ""))
if not path.endswith(".md") or not path.startswith(root + os.sep):
    sys.exit(0)

relpath = os.path.relpath(path, root)
if "japanese-writing" in relpath:
    sys.exit(0)

if found := sorted({c for c in text if not c.isascii()}):
    deny(
        f"non-ASCII text blocked in {relpath!r}: {''.join(found[:20])!r} "
        "(Markdown in this repo is ASCII-only, except japanese-writing)"
    )
