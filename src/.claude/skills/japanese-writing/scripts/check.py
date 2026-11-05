#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.14"
# ///
"""Flag mechanical notation issues in Japanese prose (Markdown or plain text).

Usage:
    check.py <file>...    check files
    check.py -            read the text from stdin

Rows are `path:line:col: rule: excerpt`. Exits 1 when any row is printed.
Rules map to SKILL.md sections: ending -> Consistent Register,
wordy -> Tight and Concrete, spacing -> Spacing, bold-label -> No Filler,
dash -> One Point per Sentence, non-joyo -> Kanji.
Fenced code blocks, inline code, and URLs are skipped.
"""

import re
import sys
from pathlib import Path
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from collections.abc import Iterator

JOYO = frozenset(
    Path(__file__).resolve().with_name("joyo.txt").read_text(encoding="utf-8").strip()
)
JA = r"ぁ-んァ-ヶー一-鿿𠀀-𯿿"
KANJI = re.compile(r"[一-鿿𠀀-𯿿]")
FENCE = re.compile(r"^\s*(```|~~~)")
INLINE_CODE = re.compile(r"`[^`]+`")
URL = re.compile(r"https?://\S+")
ISSUE_REF = re.compile(r"#\d+ (?=\S)")
SENTENCE_END = r"[。\uff01\uff1f」\uff09)]"
NUMERAL = r"[0-9\uff10-\uff19一二三四五六七八九十百千万]"
RULES = [
    ("ending", re.compile(rf"(である|(?<![まな])だ)(?={SENTENCE_END}|\s*$)")),
    ("wordy", re.compile(r"(?<=[うくぐすつぬぶむる])ことができ|を実施[しすさ]")),
    ("wordy", re.compile(rf"約{NUMERAL}+\S{{0,4}}?(くらい|ぐらい|ほど|程度)")),
    (
        "spacing",
        re.compile(rf"(?<=[A-Za-z0-9]) (?=[{JA}])|(?<=[{JA}]) (?=[A-Za-z0-9])"),
    ),
    ("bold-label", re.compile(r"^\s*(?:[-*+]|\d+\.)\s+\*\*[^*]+\*\*\s*[:\uff1a]")),
    ("dash", re.compile(r"[\u2014\u2015]")),
]


def lines_to_check(text: str) -> Iterator[tuple[int, str, str]]:
    in_fence = False
    for number, line in enumerate(text.splitlines(), 1):
        if FENCE.match(line):
            in_fence = not in_fence
            continue
        if in_fence:
            continue
        masked = line
        for pattern, fill in ((URL, "x"), (INLINE_CODE, "c"), (ISSUE_REF, "#")):
            masked = pattern.sub(lambda m, f=fill: f * len(m.group()), masked)
        yield number, line, masked


def check(path: str, text: str) -> int:
    hits = 0
    for number, line, masked in lines_to_check(text):
        found = [
            (m.start(), rule)
            for rule, pattern in RULES
            for m in pattern.finditer(masked)
        ]
        found += [
            (m.start(), "non-joyo")
            for m in KANJI.finditer(masked)
            if m.group() not in JOYO
        ]
        for col, rule in sorted(found):
            excerpt = line[max(col - 10, 0) : col + 10].strip()
            print(f"{path}:{number}:{col + 1}: {rule}: {excerpt}")
            hits += 1
    return hits


def main() -> None:
    args = sys.argv[1:]
    if not args:
        sys.exit(__doc__)
    hits = 0
    for arg in args:
        if arg == "-":
            hits += check("<stdin>", sys.stdin.read())
        else:
            hits += check(arg, Path(arg).read_text(encoding="utf-8"))
    sys.exit(1 if hits else 0)


if __name__ == "__main__":
    main()
