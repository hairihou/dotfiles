---
name: conventional-comments
description: Write code review comments using Conventional Comments format. (https://conventionalcomments.org) Use when reviewing code, providing feedback on pull requests, suggesting improvements, or analyzing code changes. Produces structured, actionable comments with clear intent and machine-parsable labels.
---

# Conventional Comments

Write code review comments in a structured format that makes intent clear and enables machine parsing.

## Format

```
<label> [decorations]: <subject>

[discussion]
```

- **label**: Required. Indicates the type of comment.
- **decorations**: Optional. Comma-separated context in parentheses.
- **subject**: Required. The main message.
- **discussion**: Optional. Reasoning, background, or suggested changes.

## Labels

| Label        | Description                                               |
| ------------ | --------------------------------------------------------- |
| `praise`     | Highlights something positive. Encourages good practices. |
| `nitpick`    | Trivial, preference-based. Addressing is optional.        |
| `suggestion` | Proposes an improvement with an explicit change.          |
| `issue`      | Identifies a problem that needs to be addressed.          |
| `todo`       | Small, necessary change. Less severe than an issue.       |
| `question`   | Seeks clarification or investigation.                     |
| `thought`    | An idea that occurred during review. May not need action. |
| `chore`      | Simple task that must be done before acceptance.          |
| `note`       | Information for the reader. Does not require action.      |
| `typo`       | Points out a typographical error.                         |
| `polish`     | Suggests refinement to improve code quality.              |
| `quibble`    | Similar to nitpick. A minor concern.                      |

## Decorations

| Decoration       | Description                                      |
| ---------------- | ------------------------------------------------ |
| `(non-blocking)` | Does not block approval. Addressing is optional. |
| `(blocking)`     | Must be addressed before approval.               |
| `(if-minor)`     | Only address if the change is minor.             |
| `(security)`     | Related to security concerns.                    |
| `(performance)`  | Related to performance concerns.                 |

## Examples

```
praise: Clean separation of concerns here. The logic is easy to follow.
```

```
suggestion: Consider using optional chaining here.

`user && user.profile && user.profile.name` can be simplified to `user?.profile?.name`.
```

```
issue: This function silently swallows exceptions.

Either log the error or propagate it to the caller.
```

```
nitpick (non-blocking): `data` is a bit vague. Consider renaming to `userList`.
```

```
suggestion (security): User input should not be directly embedded in SQL.

Use prepared statements to prevent SQL injection.
```

```
todo (blocking): Missing test coverage.

Add tests for edge cases (empty array, null values).
```
