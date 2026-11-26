#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.15"
# ///
import json
import sys
from pathlib import Path
from typing import Any
lazy import shutil
lazy import subprocess

YAML_SUFFIXES = (".yml", ".yaml")

type Finding = dict[str, Any]


def run(*args: str, cwd: Path) -> subprocess.CompletedProcess[str]:
    return subprocess.run(  # noqa: S603
        args, capture_output=True, text=True, check=False, cwd=cwd
    )


def is_target(path: Path) -> bool:
    if path.suffix not in YAML_SUFFIXES:
        return False
    if path.stem == "action":
        return True
    if path.parent.name == "workflows" and path.parent.parent.name == ".github":
        return True
    return path.stem == "dependabot" and path.parent.name == ".github"


def read_target() -> Path | None:
    payload = {}
    if not sys.stdin.isatty():
        try:
            payload = json.load(sys.stdin)
        except ValueError:
            return None
    file_path = (payload.get("tool_input") or {}).get("file_path", "")
    if not file_path:
        return None
    target = Path(file_path)
    return target if is_target(target) and target.is_file() else None


def git_root(target: Path) -> Path | None:
    root = run("git", "rev-parse", "--show-toplevel", cwd=target.parent)
    if root.returncode != 0:
        return None
    if run("git", "rev-parse", "--verify", "HEAD", cwd=target.parent).returncode:
        return None
    return Path(root.stdout.strip())


def format_findings(findings: list[Finding]) -> str:
    return "\n\n".join(
        f"{f['severity']}[{f['id']}] {f.get('filepath', '')}:{f['line']}:{f['column']}"
        f" {f['message']}" + (f"\n{f['snippet']}" if f.get("snippet") else "")
        for f in findings
    )


def main() -> None:
    target = read_target()
    jactionlint = shutil.which("jactionlint")
    if target is None or jactionlint is None:
        return

    root = git_root(target)
    args = [jactionlint, "--format", "json", "--no-hints"]
    if root is not None:
        args += ["--changed-since", "HEAD"]
    result = run(*args, "--", str(target), cwd=root or target.parent)
    try:
        findings: list[Finding] = json.loads(result.stdout)
    except ValueError:
        raw = result.stdout.strip() or result.stderr.strip()
        if raw:
            print(
                json.dumps(
                    {"decision": "block", "reason": f"jactionlint failed:\n\n{raw}"}
                )
            )
        return

    errors = [f for f in findings if f["severity"] == "error"]
    advisories = [f for f in findings if f["severity"] != "error"]
    if errors:
        reason = "jactionlint errors:\n\n" + format_findings(errors)
        if advisories:
            reason += "\n\njactionlint warnings (advisory):\n\n" + format_findings(
                advisories
            )
        print(json.dumps({"decision": "block", "reason": reason}))
    elif advisories:
        context = "jactionlint warnings (advisory):\n\n" + format_findings(advisories)
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


main()
