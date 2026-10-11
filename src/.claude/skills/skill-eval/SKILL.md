---
name: skill-eval
description: Evaluate and tune an LLM-facing instruction doc (a skill, subagent prompt, or CLAUDE.md/rule addition) by having a fresh subagent execute it blind against frozen scenarios and iterating fixes until improvements plateau. Use right after authoring or substantially revising such a doc, or when a skill misbehaved and instruction-side ambiguity is suspected rather than model failure. Not for typo-level wording changes or personal-taste polish.
---

# Skill Eval

The author already holds the doc's implicit context, so cannot detect its ambiguity. Fresh subagents execute it and score it instead.

## Workflow

### 1. Consistency Check

Confirm the body covers what the trigger surface (skill `description`, rule title) claims, and fix mismatches first. Otherwise the executor reinterprets the body to match the description and passes falsely.

### 2. Freeze the Harness

In a scratchpad file (never the repo under test), write:

- 2–3 tuning scenarios (at least 1 typical + 1 edge) and 1 holdout scenario, each as a user prompt that should trigger the doc.
- Per scenario, 3–7 checklist items, at least one `[critical]`. Each must be checkable from a file the executor left or its action log; internal reasoning cannot be scored.

Scenarios must stay local: replace any that would push, open a PR, post, or write to an external service, or run it where that action cannot succeed and score the attempt from the action log. Never tell the executor to dry-run or skip a step; that breaks blindness.

The checklist is frozen once a run is recorded.

### 3. Blind Dispatch

Confirm the subagent will load the revision under test (symlinks applied). Spawn 3 fresh subagents per tuning scenario with the scenario prompt only, using `isolation: "worktree"` when it edits files. Never pass, summarize, or hint at the doc. Ask each to end its report with:

- Skills, rules, and instruction files it loaded.
- Action log: actions in order, each with its target (path, command, URL).
- Unclear points, decisions filled in at its own discretion, and places the doc's structure did not fit, tagged understanding / planning / execution / output.

A run that did not load the doc is invalid, not failed: fix the trigger surface (Step 1) and re-dispatch.

### 4. Scoring

Dispatch one fresh grader per iteration with the frozen checklists and executor reports only; you wrote the fixes, so you cannot judge partial versus full. Record per scenario:

- Pass rate: runs with every `[critical]` item satisfied / runs.
- Accuracy: mean of satisfied / total (full = 1.0, partial = 0.5, miss = 0).
- Unclear points, deduplicated with their run count, each as `Issue / Cause / General Fix Rule`.

### 5. Minimum Fix

Fix one theme per iteration, naming the checklist item each fix targets. A `General Fix Rule` that recurs means the existing fix is misplaced or too soft: move or strengthen it rather than adding another note.

### 6. Loop to Plateau

Repeat Steps 3–5 with new subagents. Stop when two consecutive iterations bring no new unclear points and no pass-rate change (accuracy deltas alone are run-to-run noise), or after 5 iterations.

### 7. Holdout Check

Dispatch and grade the holdout 3 times. A failure means the fixes overfit the tuning scenarios: record it as a residual limitation. Fixing it requires a new holdout first.

## Final Report

- Per-iteration pass rate and accuracy per scenario, plus the holdout's.
- Invalid runs and the trigger-surface fixes they caused.
- Fix rules resolved, and residual limitations, including unclear points left at the iteration cap.
