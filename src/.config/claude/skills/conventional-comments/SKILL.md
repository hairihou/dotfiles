---
name: conventional-comments
description: Format code review comments using Conventional Comments labels and decorations. Use when writing inline review comments on a PR diff. Not for creating PRs — use pr for that. Not for complexity analysis — use code-critic for that.
allowed-tools: Bash(gh *), Read
---

# Conventional Comments

## Workflow

1. Read the full diff before writing any comments.
2. Identify blocking issues (`issue!`, `suggestion!`) first — these gate approval.
3. Add non-blocking feedback (`suggestion`, `todo`, `question`, `note`) after.

## Format

```
<label>[!] [(decorations)]: <subject>

[discussion]
```

| Part           | Required | Description                                       |
| -------------- | -------- | ------------------------------------------------- |
| `label`        | Yes      | Comment type (see labels below)                   |
| `!`            | No       | Blocking indicator—must resolve before approval   |
| `(decoration)` | No       | Comma-separated context tags (e.g., `(security)`) |
| `subject`      | Yes      | Main message (1 line)                             |
| `discussion`   | No       | Additional reasoning or suggested fix (1-3 lines) |

## Labels

| Label        | Description                                          | When to use                                                         |
| ------------ | ---------------------------------------------------- | ------------------------------------------------------------------- |
| `issue`      | Identifies a problem that needs to be addressed.     | Bugs, logic errors, broken contracts. Will cause failures if left.  |
| `suggestion` | Proposes an improvement with an explicit change.     | Better approaches exist. Always include the concrete alternative.   |
| `todo`       | Small, necessary change. Less severe than an issue.  | Missing null checks, missing edge cases, incomplete cleanup.        |
| `question`   | Seeks clarification or investigation.                | Intent is unclear from the code alone. Not rhetorical.              |
| `note`       | Information for the reader. Does not require action. | Related code elsewhere, upcoming changes, context the author lacks. |
| `typo`       | Points out a typographical error.                    | Misspelled identifiers, comments, or strings.                       |

**Do NOT use**: `praise`, `nitpick`, `quibble` — focus on actionable feedback only.

### Label boundaries

- **issue vs. todo**: `issue` breaks correctness or contracts. `todo` is a gap that should be closed but is not immediately harmful.
- **suggestion vs. todo**: `suggestion` offers a better approach (include the alternative). `todo` points out something missing (no alternative needed).
- **question vs. note**: `question` expects a response. `note` does not.

## Anti-patterns

- **Restating the diff.** "This adds a new function" — the reviewer can see that. State the consequence or concern instead.
- **Suggestion without alternative.** "This could be improved" — how? Always include the concrete change.
- **Rhetorical question.** "Do we really need this?" — if you know the answer, use `suggestion` or `issue` instead.
- **Commenting on the obvious.** If the code is self-explanatory and correct, no comment is needed. Silence is a valid review output.

## Decorations

| Decoration      | Use when                                     |
| --------------- | -------------------------------------------- |
| `(a11y)`        | Comment relates to accessibility.            |
| `(performance)` | Comment relates to performance impact.       |
| `(security)`    | Comment relates to security vulnerabilities. |
| `(ux)`          | Comment relates to user experience.          |

## Examples

### Basic suggestion

```
suggestion: Consider using optional chaining here.

`user && user.profile && user.profile.name` can be simplified to `user?.profile?.name`.
```

### Blocking issue

```
issue!: This function silently swallows exceptions.

Either log the error or propagate it to the caller.
```

### With security decoration

```
suggestion! (security): User input should not be directly embedded in SQL.

Use prepared statements to prevent SQL injection.
```

### With performance decoration

```
issue (performance): This query runs inside a loop causing N+1 problem.

Batch the IDs and fetch all records in a single query.
```

### Simple todo

```
todo: Add null check before accessing `user.email`.
```

### Question

```
question: Is this timeout value intentional?

300ms seems short for API calls that may span regions.
```

### Note (informational)

```
note: This pattern is also used in `auth-service.ts:45`.
```
