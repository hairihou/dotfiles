---
name: skill-eval
description: Evaluate and tune an LLM-facing instruction doc — a skill, subagent prompt, or CLAUDE.md/rule addition — by having a fresh subagent execute it blind against frozen scenarios and iterating fixes until improvements plateau. Use right after authoring or substantially revising such a doc, or when a skill misbehaved and instruction-side ambiguity is suspected rather than model failure. Not for typo-level wording changes or personal-taste polish.
---

# Skill Eval

The author of a prompt cannot judge its quality: whoever wrote the text already holds the implicit context, so re-reading it "from the same head" cannot detect ambiguity. The only reliable detector is a bias-free executor — dispatch a fresh subagent, score the run two-sidedly, and iterate until improvements stop.

## Workflow

### 1. Consistency Check

Read the doc's trigger surface (skill `description`, rule title) and confirm the body actually covers what it claims. Fix mismatches first — otherwise an executor silently reinterprets the body to match the description and produces a false positive.

### 2. Freeze the Harness

Before any dispatch, write down in a throwaway working file:

- 2–3 realistic scenarios (at least 1 typical + 1 edge), each phrased as a user prompt that should trigger the doc.
- Per scenario, a requirements checklist of 3–7 observable items; mark at least one per scenario as `[critical]`.

Once a run has been recorded, the checklist is frozen — editing it retroactively converts the eval into a vibes check.

### 3. Blind Dispatch

Confirm the revision under test is the one a subagent will actually load (symlinks applied, live file matches the edited source). Then spawn one fresh subagent per scenario, passing the scenario prompt only — do not paste the doc, summarize it, or hint at the expected behavior. The subagent must encounter the doc cold, the way a future session would. Ask each subagent to also report: points that were unclear, decisions it filled in at its own discretion, and places the doc's structure did not fit — tagged by phase (understanding / planning / execution / output).

### 4. Two-Sided Scoring

Record per scenario:

- Pass / fail: pass only if every `[critical]` item is satisfied.
- Accuracy: satisfied / total (full = 1.0, partial = 0.5, miss = 0).
- The executor's self-reported unclear points, each as `Issue / Cause / General Fix Rule` so the same failure class is recognizable next run.
- Rework signals if visible (the executor re-deciding the same thing, redundant tool round-trips).

### 5. Minimum Fix

Edit the doc to remove the unclear points — one theme per iteration; unrelated fixes wait for the next round. Before writing a fix, state which checklist item it is meant to satisfy; fixes inferred from vibes tend not to land. If the same `General Fix Rule` recurs across iterations, the existing fix is in the wrong place (too low in the doc, too soft, ambiguous trigger) — move or strengthen it instead of adding another note.

### 6. Loop to Plateau

Re-run with a new subagent — never reuse one, it has already learned the prior text. Stop when two consecutive iterations produce zero new unclear points and accuracy improvement falls below ~5% relative.

## Anti-Patterns

- Re-reading your own draft and deciding it is clear — your head supplies the missing context.
- Editing the requirements checklist after seeing a run.
- Reusing a subagent across iterations — the eval degrades into reading comprehension of the previous version.
- Accumulating notes for a recurring failure class instead of relocating the existing fix.

## Final Report

- Doc under test and iterations run, with per-iteration pass/accuracy.
- Fix rules resolved, and residual known limitations left in the doc.
