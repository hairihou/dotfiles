---
name: diff-tour
description: Use when the user wants a rich, teaching-quality explanation of a code change, diff, branch, or PR — a guided tour that builds intuition, not a terse summary. Produces a self-contained HTML page. Not for one-line diff summaries or inline review comments.
allowed-tools: Bash, Glob, Grep, Read, Write
---

# Diff Tour

Explain a code change as one self-contained HTML page. Resolve what "the change" is (working diff, branch vs base, commit range, PR — ask if unclear), then read the diff and the surrounding code so the page reflects the real system, not just the hunks.

## Page

One scrollable page, table of contents, no top-level tabs:

- **Background** — the system the change touches: deep enough for a newcomer (skippable), then narrowing to what this change affects.
- **Intuition** — the core idea via concrete toy-data examples and diagrams, not every detail.
- **Code** — a high-level tour of the changes, ordered so each builds on the last, not by file.
- **Quiz** — five medium questions that need real understanding (no trick questions); on click, mark right/wrong and explain why.

Diagrams from styled HTML (boxes, flex/grid), never ASCII; reuse a couple of families such as a UI mockup and a data-flow diagram with example data. Callouts for key concepts and edge cases.

## Output

- One `.html` file, inline CSS/JS, mobile-readable.
- Save outside the repo, filename prefixed with today's date (`date +%F`) so files stay time-sorted, e.g. `/tmp/2026-01-12-walkthrough-<slug>.html`; print the path.
- Code blocks in `<pre>` (or a `div` with `white-space: pre`/`pre-wrap`, else newlines collapse) — verify before saving.
