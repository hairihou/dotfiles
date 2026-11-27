#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.15"
# dependencies = []
# ///
"""Run a synthetic respondent panel over concepts and summarize the ratings.

Each persona sees each concept in its own isolated `claude -p` call and answers in
free text; a separate rater call maps that text to a 5-point scale.

Usage:
    panel.py run --personas P.jsonl --concept ID=PATH[,PATH...] ... --question Q
                 --scale L1 L2 L3 L4 L5 --language LANG --out DIR
                 [--model M] [--jobs N] [--dry-run]
    panel.py report DIR

personas.jsonl rows: {"id": "...", "profile": "<who this person is, in LANG>"}.
DIR/responses.jsonl rows: {"persona", "concept", "answer", "rating" | "error",
"cost_usd"}; DIR/run.json holds the question, scale, language, and model.
Concept paths ending in .png/.jpg/.jpeg/.gif/.webp are sent as images, others as
text. Rerunning `run` with the same --out skips pairs that already succeeded.
"""

import argparse
import base64
import json
import random
import statistics
import subprocess
import sys
import tempfile
import threading
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
lazy from collections.abc import Sequence

IMAGE_TYPES = {
    ".gif": "image/gif",
    ".jpeg": "image/jpeg",
    ".jpg": "image/jpeg",
    ".png": "image/png",
    ".webp": "image/webp",
}
SCALE_POINTS = 5
RATING_SCHEMA = {
    "type": "object",
    "properties": {
        "rating": {"type": "integer", "minimum": 1, "maximum": SCALE_POINTS}
    },
    "required": ["rating"],
}
BOOTSTRAP_ROUNDS = 2000


def isolated_claude(model: str, system_prompt: str) -> list[str]:
    # The user's `language` setting overrides a language stated in --system-prompt
    # (observed in Claude Code 2.1.332), so user settings are excluded entirely.
    return [
        "claude",
        "-p",
        "--safe-mode",
        "--setting-sources",
        "",
        "--no-session-persistence",
        "--tools",
        "",
        "--model",
        model,
        "--system-prompt",
        system_prompt,
    ]


def load_concept(spec: str) -> tuple[str, list[dict]]:
    concept_id, _, paths = spec.partition("=")
    if not concept_id or not paths:
        sys.exit(f"--concept must be ID=PATH[,PATH...]: {spec}")
    blocks = []
    for raw in paths.split(","):
        path = Path(raw).expanduser()
        media_type = IMAGE_TYPES.get(path.suffix.lower())
        if media_type:
            data = base64.b64encode(path.read_bytes()).decode()
            source = {"type": "base64", "media_type": media_type, "data": data}
            blocks.append({"type": "image", "source": source})
        else:
            blocks.append({"type": "text", "text": path.read_text()})
    return concept_id, blocks


def persona_prompt(profile: str, language: str) -> str:
    return (
        "You are the person described below, taking part in a survey. "
        "Stay in character.\n\n"
        f"{profile}\n\n"
        f"Reply in {language}, in 2 to 4 sentences, in your own voice. "
        "Do not give numbers, scores, ratings, or scale positions: "
        "say how you feel and why."
    )


def rater_prompt(question: str, scale: list[str]) -> str:
    points = "\n".join(f"{i}: {label}" for i, label in enumerate(scale, 1))
    return (
        "You rate free-text survey answers on a 5-point scale. Given a respondent's "
        "answer to the question below, choose the scale point that respondent would "
        "most likely have picked.\n\n"
        f"Question: {question}\n\nScale:\n{points}"
    )


def elicit(
    args: argparse.Namespace, cwd: str, profile: str, blocks: list[dict]
) -> tuple[str, float]:
    content = [*blocks, {"type": "text", "text": args.question}]
    message = {"type": "user", "message": {"role": "user", "content": content}}
    command = [
        *isolated_claude(args.model, persona_prompt(profile, args.language)),
        "--input-format",
        "stream-json",
        "--output-format",
        "stream-json",
        "--verbose",
    ]
    proc = subprocess.run(  # noqa: S603
        command,
        input=json.dumps(message) + "\n",
        capture_output=True,
        text=True,
        cwd=cwd,
        check=False,
    )
    for line in reversed(proc.stdout.splitlines()):
        event = json.loads(line)
        if event.get("type") == "result":
            if event.get("is_error"):
                raise RuntimeError(event.get("result") or "persona call failed")
            return event["result"].strip(), event.get("total_cost_usd", 0.0)
    raise RuntimeError(proc.stderr.strip() or "persona call returned no result")


def rate(args: argparse.Namespace, cwd: str, answer: str) -> tuple[int, float]:
    command = [
        *isolated_claude(args.model, rater_prompt(args.question, args.scale)),
        "--output-format",
        "json",
        "--json-schema",
        json.dumps(RATING_SCHEMA),
        f"Respondent's answer:\n{answer}",
    ]
    proc = subprocess.run(  # noqa: S603
        command, capture_output=True, text=True, cwd=cwd, check=False
    )
    try:
        result = json.loads(proc.stdout)
    except json.JSONDecodeError as error:
        message = proc.stderr.strip() or "rater call returned no JSON"
        raise RuntimeError(message) from error
    if result.get("is_error") or "structured_output" not in result:
        raise RuntimeError(result.get("result") or "rater call failed")
    rating = int(result["structured_output"]["rating"])
    return rating, result.get("total_cost_usd", 0.0)


def run(args: argparse.Namespace) -> None:
    personas = [
        json.loads(line)
        for line in Path(args.personas).read_text().splitlines()
        if line.strip()
    ]
    concepts = dict(load_concept(spec) for spec in args.concept)
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    responses = out / "responses.jsonl"
    done = set()
    if responses.exists():
        for line in responses.read_text().splitlines():
            row = json.loads(line)
            if "rating" in row:
                done.add((row["persona"], row["concept"]))
    pairs = [
        (persona, concept_id)
        for persona in personas
        for concept_id in concepts
        if (persona["id"], concept_id) not in done
    ]
    print(
        f"{len(personas)} personas x {len(concepts)} concepts: "
        f"{len(pairs)} pairs to run ({len(done)} already done), "
        f"{2 * len(pairs)} claude calls on {args.model}",
        file=sys.stderr,
    )
    meta = {
        "question": args.question,
        "scale": args.scale,
        "language": args.language,
        "model": args.model,
    }
    run_file = out / "run.json"
    if run_file.exists() and json.loads(run_file.read_text()) != meta:
        sys.exit(f"{run_file} has a different question, scale, language, or model")
    if args.dry_run or not pairs:
        return
    run_file.write_text(json.dumps(meta, ensure_ascii=False, indent=2))
    lock = threading.Lock()
    cost = 0.0
    counts = {"ok": 0, "failed": 0}

    def work(pair: tuple[dict, str]) -> None:
        nonlocal cost
        persona, concept_id = pair
        row: dict[str, object] = {"persona": persona["id"], "concept": concept_id}
        spent = 0.0
        with tempfile.TemporaryDirectory() as cwd:
            try:
                answer, elicit_cost = elicit(
                    args, cwd, persona["profile"], concepts[concept_id]
                )
                spent += elicit_cost
                row["answer"] = answer
                rating, rate_cost = rate(args, cwd, answer)
                spent += rate_cost
                row["rating"] = rating
            except (RuntimeError, json.JSONDecodeError, KeyError) as error:
                row["error"] = str(error)
        row["cost_usd"] = spent
        with lock:
            with responses.open("a") as file:
                file.write(json.dumps(row, ensure_ascii=False) + "\n")
            cost += spent
            counts["ok" if "rating" in row else "failed"] += 1
            print(
                f"\r{counts['ok']} ok, {counts['failed']} failed, ${cost:.2f}",
                end="",
                file=sys.stderr,
            )

    with ThreadPoolExecutor(args.jobs) as pool:
        list(pool.map(work, pairs))
    print(file=sys.stderr)


def bootstrap_means(values: Sequence[float], rng: random.Random) -> list[float]:
    return sorted(
        statistics.fmean(rng.choices(values, k=len(values)))
        for _ in range(BOOTSTRAP_ROUNDS)
    )


def interval(means: list[float]) -> str:
    low = means[int(0.025 * BOOTSTRAP_ROUNDS)]
    high = means[int(0.975 * BOOTSTRAP_ROUNDS) - 1]
    return f"{low:.2f} to {high:.2f}"


def report(args: argparse.Namespace) -> None:
    out = Path(args.dir)
    meta = json.loads((out / "run.json").read_text())
    lines = (out / "responses.jsonl").read_text().splitlines()
    rows = [json.loads(line) for line in lines]
    ratings: dict[str, dict[str, int]] = {row["concept"]: {} for row in rows}
    for row in rows:
        if "rating" in row:
            ratings[row["concept"]][row["persona"]] = row["rating"]
    failed: dict[str, int] = {}
    for persona, concept in {
        (r["persona"], r["concept"]) for r in rows if "error" in r
    }:
        if persona not in ratings.get(concept, {}):
            failed[concept] = failed.get(concept, 0) + 1
    rng = random.Random(0)  # noqa: S311
    print(f"Question: {meta['question']}")
    print(f"Model: {meta['model']} (synthetic panel, not human data)\n")
    points = range(1, SCALE_POINTS + 1)
    print(
        "| concept | n | failed | mean | 95% CI | "
        + " | ".join(map(str, points))
        + " |"
    )
    print("|---|---|---|---|---|" + "---|" * SCALE_POINTS)
    for concept in [c for c in ratings if not ratings[c]]:
        print(f"| {concept} | 0 | {failed.get(concept, 0)} | | | {'| ' * SCALE_POINTS}")
    ranked = sorted(
        [c for c in ratings if ratings[c]],
        key=lambda c: statistics.fmean(ratings[c].values()),
        reverse=True,
    )
    for concept in ranked:
        values = list(ratings[concept].values())
        spread = " | ".join(str(values.count(i)) for i in points)
        print(
            f"| {concept} | {len(values)} | {failed.get(concept, 0)} "
            f"| {statistics.fmean(values):.2f} "
            f"| {interval(bootstrap_means(values, rng))} | {spread} |"
        )
    if len(ranked) > 1:
        print_paired(ratings, ranked, rng)


def print_paired(
    ratings: dict[str, dict[str, int]], ranked: list[str], rng: random.Random
) -> None:
    print("\nPaired differences (same personas rating both concepts):\n")
    print("| higher | lower | n | mean diff | 95% CI | share of resamples > 0 |")
    print("|---|---|---|---|---|---|")
    for i, a in enumerate(ranked):
        for b in ranked[i + 1 :]:
            shared = sorted(ratings[a].keys() & ratings[b].keys())
            if not shared:
                continue
            diffs = [ratings[a][p] - ratings[b][p] for p in shared]
            means = bootstrap_means(diffs, rng)
            share = sum(m > 0 for m in means) / BOOTSTRAP_ROUNDS
            print(
                f"| {a} | {b} | {len(shared)} | {statistics.fmean(diffs):.2f} "
                f"| {interval(means)} | {share:.0%} |"
            )


def main() -> None:
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    commands = parser.add_subparsers(dest="command", required=True)
    run_parser = commands.add_parser("run", help="collect answers and ratings")
    run_parser.add_argument("--personas", required=True)
    run_parser.add_argument(
        "--concept", action="append", required=True, metavar="ID=PATH[,PATH...]"
    )
    run_parser.add_argument("--question", required=True)
    run_parser.add_argument(
        "--scale", nargs=SCALE_POINTS, required=True, metavar="LABEL"
    )
    run_parser.add_argument("--language", required=True)
    run_parser.add_argument("--out", required=True)
    run_parser.add_argument(
        "--model",
        default="sonnet",
        help="claude model alias or ID (default: %(default)s)",
    )
    run_parser.add_argument("--jobs", type=int, default=8)
    run_parser.add_argument("--dry-run", action="store_true")
    run_parser.set_defaults(func=run)
    report_parser = commands.add_parser("report", help="summarize a finished run")
    report_parser.add_argument("dir")
    report_parser.set_defaults(func=report)
    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
