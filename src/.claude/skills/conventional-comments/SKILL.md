---
name: conventional-comments
description: Format code review comments using Conventional Comments labels and decorations. Use when reviewing a PR diff and leaving inline feedback. Not for opening a PR, not for standalone code critique.
allowed-tools: Bash, Read
---

# Conventional Comments

Follow conventionalcomments.org spec: `<label> [decorations]: <subject>`. Local conventions below.

## Workflow

1. Read the full diff before writing any comments.
2. Address blocking comments first — they gate approval.
3. Add non-blocking feedback after.

## Local conventions

- **Forbidden labels**: `praise`, `nitpick`, `quibble` — actionable feedback only. Use `issue`, `suggestion`, `todo`, `question`, `note`, `typo`.
- **Blocking indicator**: append `!` directly before `:` (e.g., `issue(security)!:`). Local extension to the spec — use this in place of the `(blocking)` / `(non-blocking)` decoration. Absence of `!` means non-blocking.
- **Domain decorations**: `(a11y)`, `(performance)`, `(security)`, `(ux)`.
- Silence is a valid review output — no comment if the code is self-explanatory and correct.

## Label boundaries

- `issue` breaks correctness or contracts. `todo` is a gap that should be closed but is not immediately harmful.
- `suggestion` offers a better approach (include the alternative). `todo` points out something missing.
- `question` expects a response. `note` does not.

## Anti-patterns

- **Restating the diff.** State the consequence, not the change.
- **Suggestion without alternative.** Always include the concrete change.
- **Rhetorical question.** If you know the answer, use `suggestion` or `issue`.

## Example (combining local conventions)

```
issue(security)!: User input embedded directly in SQL.

Use prepared statements to prevent SQL injection.
```
