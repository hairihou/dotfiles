#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.14"
# ///
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

EXTENSION_SUFFIXES = (".ts", ".tsx", ".vue")
HUNK_RE = re.compile(r"^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@", re.MULTILINE)
MAX_FIX_PASSES = 5

stdin_data = {}
if not sys.stdin.isatty():
    try:
        stdin_data = json.loads(sys.stdin.read())
    except json.JSONDecodeError, ValueError:
        pass

file_path = stdin_data.get("tool_input", {}).get("file_path", "")
if not file_path or not file_path.endswith(EXTENSION_SUFFIXES):
    sys.exit(0)

target = Path(file_path)
ast_grep_bin = shutil.which("ast-grep")
sgconfig = (
    Path(__file__).resolve().parent.parent / "public" / "ast-grep" / "sgconfig.yml"
)
if not ast_grep_bin or not sgconfig.is_file() or not target.is_file():
    sys.exit(0)
ast_grep = ast_grep_bin


def scan() -> tuple[list | None, str]:
    result = subprocess.run(
        [
            ast_grep,
            "scan",
            "--json",
            "--include-metadata",
            "-c",
            str(sgconfig),
            "--",
            str(target),
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    try:
        return json.loads(result.stdout), result.stderr.strip()
    except json.JSONDecodeError, ValueError:
        return None, (result.stdout.strip() or result.stderr.strip())


def changed_line_ranges() -> list[tuple[int, int]] | None:
    git = ["git", "-C", str(target.parent)]
    inside = subprocess.run(
        [*git, "rev-parse", "--is-inside-work-tree"],
        capture_output=True,
        text=True,
        check=False,
    )
    if inside.stdout.strip() != "true":
        return None
    tracked = subprocess.run(
        [*git, "ls-files", "--error-unmatch", "--", str(target)],
        capture_output=True,
        text=True,
        check=False,
    )
    if tracked.returncode != 0:
        return [(1, sys.maxsize)]
    diff = subprocess.run(
        [*git, "diff", "-U0", "HEAD", "--", str(target)],
        capture_output=True,
        text=True,
        check=False,
    )
    if diff.returncode != 0:
        return [(1, sys.maxsize)]
    ranges = []
    for hunk in HUNK_RE.finditer(diff.stdout):
        start = int(hunk.group(1))
        count = 1 if hunk.group(2) is None else int(hunk.group(2))
        if count > 0:
            ranges.append((start, start + count - 1))
    return ranges


def intersects(match: dict, ranges: list[tuple[int, int]]) -> bool:
    start = match["range"]["start"]["line"] + 1
    end = match["range"]["end"]["line"] + 1
    return any(start <= hi and end >= lo for lo, hi in ranges)


def file_scoped(match: dict) -> bool:
    return (match.get("metadata") or {}).get("scope") == "file"


def format_match(match: dict) -> str:
    line = match["range"]["start"]["line"] + 1
    note = f" {match['message']}" if match.get("message") else ""
    source = match["lines"].splitlines()[0].strip() if match["lines"] else ""
    return f"{match['severity']}[{match['ruleId']}] {match['file']}:{line}{note}\n  {source}"


ranges = changed_line_ranges()

if ranges is not None:
    for _ in range(MAX_FIX_PASSES):
        matches, _ = scan()
        if matches is None:
            break
        fixes = sorted(
            (
                m
                for m in matches
                if m.get("replacement") is not None
                and (file_scoped(m) or intersects(m, ranges))
            ),
            key=lambda m: m["replacementOffsets"]["start"],
            reverse=True,
        )
        if not fixes:
            break
        content = target.read_bytes()
        floor = len(content)
        for m in fixes:
            offsets = m["replacementOffsets"]
            if offsets["end"] > floor:
                continue
            content = (
                content[: offsets["start"]]
                + m["replacement"].encode()
                + content[offsets["end"] :]
            )
            floor = offsets["start"]
        target.write_bytes(content)
        ranges = changed_line_ranges() or []

matches, raw = scan()
if matches is None:
    if raw:
        print(json.dumps({"decision": "block", "reason": f"ast-grep failed:\n\n{raw}"}))
    sys.exit(0)

if ranges is not None:
    matches = [m for m in matches if file_scoped(m) or intersects(m, ranges)]
if not matches:
    sys.exit(0)

errors = []
warnings = []
for m in matches:
    if m["severity"] == "error" and (ranges is not None or file_scoped(m)):
        errors.append(m)
    else:
        warnings.append(m)

if errors:
    reason = "ast-grep errors:\n\n" + "\n\n".join(format_match(m) for m in errors)
    if warnings:
        reason += "\n\nast-grep warnings (advisory):\n\n" + "\n\n".join(
            format_match(m) for m in warnings
        )
    print(json.dumps({"decision": "block", "reason": reason}))
elif warnings:
    print(
        "ast-grep warnings:\n\n" + "\n\n".join(format_match(m) for m in warnings),
        file=sys.stderr,
    )

sys.exit(0)
