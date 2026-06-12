---
name: subagent-driven
description: Execute planned, multi-step implementation work by orchestrating subagents — implementation and review run in forked contexts while the main conversation holds only the plan and results. Use when work spans multiple semi-independent tasks, or when implementing inline would pull many files into the main context. Not for single-file edits, quick fixes, or pure investigation.
---

# Subagent-Driven

The main conversation acts as orchestrator: it owns the task list, curates per-task context, and accepts or rejects results. Reading source trees and writing code happen in subagent contexts, so the main context stays small enough to survive the whole plan without compaction.

## Orchestrator Discipline

- Derive the task list in the main loop from the plan or requirements; never hand a subagent the whole plan to read
- Dispatch each task with curated context only: goal, acceptance criteria, relevant file paths, constraints
- Instruct the implementer to return open questions instead of guessing when the provided context is insufficient
- Exploration that informs planning goes to a read-only Explore agent that returns conclusions, not file contents
- Do not re-read or re-verify in the main loop what a subagent already verified — that re-pollutes the context the delegation saved

## Per-Task Loop

1. An implementer subagent makes the change and reports what changed and how it was verified (actual test output, not claims)
2. Spec-compliance review by a fresh reviewer agent against the task's acceptance criteria — this comes first because code that fails spec gets rewritten, wasting any quality polish on it
3. Code-quality review only after spec compliance passes
4. Issues go back to the same implementer (continue it via SendMessage so it keeps its context), then re-review
5. A task with open issues blocks dependent tasks; run implementers in parallel only on disjoint file sets, with worktree isolation if they might collide

## Scale Gate

If the work fits one or two files and a single dispatch, implement directly — orchestration overhead (agent setup, re-reading) exceeds the context it would save.

## Final Pass

After all tasks complete, run one reviewer over the full diff: per-task reviews cannot see cross-task seams.
