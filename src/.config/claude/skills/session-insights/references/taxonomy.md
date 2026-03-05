# Session Insights Taxonomy

## Session Categories

Classify into one of: Feature Development, Bug Fix, Code Review, Refactoring, Test, CI/CD, Documentation, Configuration, Research, Coaching

## Session Size

| Size | Criteria                                      |
| ---- | --------------------------------------------- |
| XS   | 1-3 turns, single focused task                |
| S    | 4-8 turns, straightforward task               |
| M    | 9-15 turns, moderate complexity               |
| L    | 16-25 turns, multiple subtasks or corrections |
| XL   | 26+ turns, significant scope or difficulties  |

L/XL sessions indicate potential inefficiencies worth analyzing.

## Issue Types

| Issue Type       | Signal                                                         |
| ---------------- | -------------------------------------------------------------- |
| Misunderstanding | User corrected agent's interpretation                          |
| Retry loop       | Same action attempted multiple times                           |
| Scope creep      | Task grew beyond original request                              |
| Missing context  | Agent asked for information that should have been in CLAUDE.md |
| Wrong tool/skill | Agent used wrong approach, user redirected                     |
| Wasted work      | Agent produced output that was discarded                       |
| Hallucination    | Agent assumed facts not in evidence                            |

## Feedback Types

### Prompt Improvement

Rewrite the user's initial request to prevent issues observed in the session.

### CLAUDE.md / Rules Suggestions

Rules or preferences that would prevent issues. Only suggest additions that would prevent issues observed in THIS session.

### Skill Suggestions

Skills that were missing, underperformed, or misused.

### Knowledge Usage Categories

| Category   | Description                                                       |
| ---------- | ----------------------------------------------------------------- |
| Applied    | Rule/instruction that was followed and helped                     |
| Missed     | Rule/instruction that existed but was not applied when it should  |
| Misleading | Rule/instruction that caused incorrect behavior — consider update |
