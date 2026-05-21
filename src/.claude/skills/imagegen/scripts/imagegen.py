#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.14"
# ///
"""Generate or edit an image via Codex (gpt-image-2) and place it at a target path.

Usage:
  imagegen.py <prompt> [-o PATH] [-i SOURCE ...] [--size WxH] [--model MODEL]
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path


def slugify(text: str) -> str:
    words = re.findall(r"[a-z0-9]+", text.lower())
    return "-".join(words[:6]) or "image"


def codex_home() -> Path:
    return Path(os.environ.get("CODEX_HOME") or Path.home() / ".codex")


def build_codex_cmd(prompt: str, sources: list[str], model: str | None) -> list[str]:
    cmd = ["codex", "exec", "--json", "--skip-git-repo-check", "--sandbox", "read-only"]
    if model:
        cmd += ["--model", model]
    for src in sources:
        cmd += ["-i", src]
    cmd += ["--", prompt]
    return cmd


def run_codex(cmd: list[str]) -> tuple[str | None, str]:
    """Run codex exec, return (thread_id, last_agent_message_or_error)."""
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
    except subprocess.TimeoutExpired:
        sys.exit("Codex timed out after 300s.")
    thread_id: str | None = None
    last_message = ""
    for line in proc.stdout.splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue
        if event.get("type") == "thread.started":
            thread_id = event.get("thread_id")
        elif event.get("type") == "item.completed":
            item = event.get("item", {})
            if item.get("type") == "agent_message":
                last_message = item.get("text", last_message)
    if thread_id is None:
        last_message = proc.stderr.strip() or last_message
    return thread_id, last_message


def newest_png(directory: Path) -> Path | None:
    if not directory.is_dir():
        return None
    pngs = sorted(directory.glob("*.png"), key=lambda p: p.stat().st_mtime, reverse=True)
    return pngs[0] if pngs else None


def parse_size(size: str) -> tuple[str, str]:
    match = re.fullmatch(r"(\d+)x(\d+)", size)
    if not match:
        sys.exit(f"Invalid --size '{size}', expected WxH like 256x256")
    return match.group(1), match.group(2)


def resize(path: Path, width: str, height: str) -> None:
    try:
        subprocess.run(["sips", "-z", height, width, str(path)],
                       check=True, capture_output=True, text=True)
    except subprocess.CalledProcessError as exc:
        sys.exit(f"Resize failed (unsized image left at {path}): {exc.stderr.strip()}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate/edit an image via Codex gpt-image-2")
    parser.add_argument("prompt", help="Image generation prompt")
    parser.add_argument("-o", "--output", help="Output path (default: ./<slug>.png in cwd)")
    parser.add_argument("-i", "--source", action="append", default=[],
                        help="Source image for editing (repeatable)")
    parser.add_argument("--size", help="Resize output to WxH, e.g. 256x256")
    parser.add_argument("--model", help="Override the Codex agent model")
    args = parser.parse_args()

    size = parse_size(args.size) if args.size else None

    sources: list[str] = []
    for src in args.source:
        path = Path(src).expanduser()
        if not path.is_file():
            sys.exit(f"Source image not found: {src}")
        sources.append(str(path.resolve()))

    gen_prompt = (
        f"{args.prompt}\n\n"
        "Use your built-in image generation tool to produce this image. "
        "Do not run any shell commands and do not copy or move files."
    )
    thread_id, message = run_codex(build_codex_cmd(gen_prompt, sources, args.model))
    if thread_id is None:
        sys.exit(f"Codex did not start a session. {message}".strip())

    src_png = newest_png(codex_home() / "generated_images" / thread_id)
    if src_png is None:
        sys.exit(f"No image was generated. Codex said: {message}".strip())

    output = (Path(args.output) if args.output else Path.cwd() / f"{slugify(args.prompt)}.png").expanduser()
    output.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(src_png, output)
    if size:
        resize(output, size[0], size[1])

    print(output.resolve())


if __name__ == "__main__":
    main()
