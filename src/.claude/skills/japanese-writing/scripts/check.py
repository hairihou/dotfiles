#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.14"
# ///
"""Flag mechanical notation issues in Japanese prose (Markdown or plain text).

Usage:
    check.py <file>...    check files
    check.py -            read the text from stdin

Rows are `path:line:col: rule: excerpt`, followed by one fix line per rule
that fired. Exits 1 when any row is printed.
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
HINTS = {
    "ending": "文末を「だ」「である」で結ばず、述語を動詞に言い換える"
    " (原因は設定だ -> 原因は設定にある、確認が必要だ -> 確認が要る)",
    "wordy": "短い形に直す"
    " (利用することができる -> 利用できる、調査を実施した -> 調査した、"
    "約20名くらい -> 約20名)",
    "spacing": "スペースを詰める (APIで取得、3件)。"
    "既存の文書を直すときも詰める。既存の文書へ文を書き足すときに限り、"
    "その文書がスペースを空けて書いていれば、書き足す文もそれに合わせる",
    "bold-label": "太字とラベルを外し、ラベルの意味を説明の文に入れる"
    " (- **応答の遅さ**: ピーク時は3秒かかる -> ピーク時は応答に3秒かかる)",
    "dash": "文を分け、文どうしの関係を接続詞か語順で示す",
    "word": "比喩や大づかみな語を、指している物事の名前か数値に直す"
    " (道具 -> ツール、仕事 -> 処理、部品 -> 要素、床 -> 3:1以上、"
    "v2版 -> v2、macOS版 -> macOS向け)",
    "abbrev": "略さずに書く (repo -> リポジトリ)",
    "non-joyo": "仮名で書く (揃える -> そろえる)。固有名詞と引用した原文の語は変えない",
}
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
    ("word", re.compile(r"道具|仕事|部品|床|(?<!修正)(?<!最新)版")),
    ("abbrev", re.compile(r"(?<![A-Za-z])[Rr]epos?(?![A-Za-z])")),
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
        for pattern, fill in ((URL, "x"), (INLINE_CODE, "_"), (ISSUE_REF, "#")):
            masked = pattern.sub(lambda m, f=fill: f * len(m.group()), masked)
        yield number, line, masked


def check(path: str, text: str) -> set[str]:
    fired: set[str] = set()
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
            fired.add(rule)
    return fired


def main() -> None:
    args = sys.argv[1:]
    if not args:
        sys.exit(__doc__)
    fired: set[str] = set()
    for arg in args:
        text = sys.stdin.read() if arg == "-" else Path(arg).read_text(encoding="utf-8")
        fired |= check("<stdin>" if arg == "-" else arg, text)
    for rule, hint in HINTS.items():
        if rule in fired:
            print(f"fix {rule}: {hint}")
    sys.exit(1 if fired else 0)


if __name__ == "__main__":
    main()
