---
name: conventional-comments
description: Use when writing PR or code review comments to ensure consistent format, clarity, and actionability.
---

# Conventional Comments

Write code review comments in Conventional Comments format (<https://conventionalcomments.org>).

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

| Label        | Description                                          |
| ------------ | ---------------------------------------------------- |
| `issue`      | Identifies a problem that needs to be addressed.     |
| `note`       | Information for the reader. Does not require action. |
| `question`   | Seeks clarification or investigation.                |
| `suggestion` | Proposes an improvement with an explicit change.     |
| `todo`       | Small, necessary change. Less severe than an issue.  |
| `typo`       | Points out a typographical error.                    |

**Do NOT use**: `praise`, `nitpick`, `quibble` — focus on actionable feedback only.

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
