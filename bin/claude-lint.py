#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.15"
# ///
import json
import re
import sys
from pathlib import Path
from typing import Any
lazy import shutil
lazy import subprocess

EXTENSION_SUFFIXES = (".ts", ".tsx", ".vue")
HUNK_RE = re.compile(r"^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@", re.MULTILINE)
MAX_FIX_PASSES = 5
SGCONFIG = (
    Path(__file__).resolve().parent.parent / "public" / "ast-grep" / "sgconfig.yml"
)

type Match = dict[str, Any]
type LineRange = tuple[int, int]


def run(*args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(args, capture_output=True, text=True, check=False)  # noqa: S603


def scan(ast_grep: str, target: Path) -> tuple[list[Match] | None, str]:
    result = run(
        ast_grep,
        "scan",
        "--json",
        "--include-metadata",
        "-c",
        str(SGCONFIG),
        "--",
        str(target),
    )
    try:
        return json.loads(result.stdout), result.stderr.strip()
    except ValueError:
        return None, result.stdout.strip() or result.stderr.strip()


def changed_line_ranges(target: Path) -> list[LineRange] | None:
    git = ("git", "-C", str(target.parent))
    if run(*git, "rev-parse", "--is-inside-work-tree").stdout.strip() != "true":
        return None
    if run(*git, "ls-files", "--error-unmatch", "--", str(target)).returncode != 0:
        return [(1, sys.maxsize)]
    diff = run(*git, "diff", "-U0", "HEAD", "--", str(target))
    if diff.returncode != 0:
        return [(1, sys.maxsize)]
    ranges = []
    for hunk in HUNK_RE.finditer(diff.stdout):
        start = int(hunk.group(1))
        count = 1 if hunk.group(2) is None else int(hunk.group(2))
        if count > 0:
            ranges.append((start, start + count - 1))
    return ranges


def file_scoped(match: Match) -> bool:
    return (match.get("metadata") or {}).get("scope") == "file"


def in_scope(match: Match, ranges: list[LineRange]) -> bool:
    if file_scoped(match):
        return True
    start = match["range"]["start"]["line"] + 1
    end = match["range"]["end"]["line"] + 1
    return any(start <= hi and end >= lo for lo, hi in ranges)


def apply_fixes(
    ast_grep: str, target: Path, ranges: list[LineRange]
) -> list[LineRange]:
    for _ in range(MAX_FIX_PASSES):
        matches, _ = scan(ast_grep, target)
        if matches is None:
            break
        fixes = sorted(
            (
                m
                for m in matches
                if m.get("replacement") is not None and in_scope(m, ranges)
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
        ranges = changed_line_ranges(target) or []
    return ranges


def format_matches(matches: list[Match]) -> str:
    lines = []
    for m in matches:
        line = m["range"]["start"]["line"] + 1
        note = f" {m['message']}" if m.get("message") else ""
        source = m["lines"].splitlines()[0].strip() if m["lines"] else ""
        lines.append(
            f"{m['severity']}[{m['ruleId']}] {m['file']}:{line}{note}\n  {source}"
        )
    return "\n\n".join(lines)


def read_target() -> Path | None:
    payload = {}
    if not sys.stdin.isatty():
        try:
            payload = json.load(sys.stdin)
        except ValueError:
            return None
    file_path = (payload.get("tool_input") or {}).get("file_path", "")
    if not file_path.endswith(EXTENSION_SUFFIXES):
        return None
    target = Path(file_path)
    return target if target.is_file() else None


def report(matches: list[Match], ranges: list[LineRange] | None) -> None:
    if ranges is not None:
        matches = [m for m in matches if in_scope(m, ranges)]

    errors = [
        m
        for m in matches
        if m["severity"] == "error" and (ranges is not None or file_scoped(m))
    ]
    warnings = [m for m in matches if m not in errors]
    if errors:
        reason = "ast-grep errors:\n\n" + format_matches(errors)
        if warnings:
            reason += "\n\nast-grep warnings (advisory):\n\n" + format_matches(warnings)
        print(json.dumps({"decision": "block", "reason": reason}))
    elif warnings:
        context = "ast-grep warnings (advisory):\n\n" + format_matches(warnings)
        print(
            json.dumps(
                {
                    "hookSpecificOutput": {
                        "hookEventName": "PostToolUse",
                        "additionalContext": context,
                    }
                }
            )
        )


def main() -> None:
    target = read_target()
    ast_grep = shutil.which("ast-grep")
    if target is None or ast_grep is None or not SGCONFIG.is_file():
        return

    ranges = changed_line_ranges(target)
    if ranges is not None:
        ranges = apply_fixes(ast_grep, target, ranges)

    matches, raw = scan(ast_grep, target)
    if matches is None:
        if raw:
            print(
                json.dumps(
                    {"decision": "block", "reason": f"ast-grep failed:\n\n{raw}"}
                )
            )
        return
    report(matches, ranges)


main()
