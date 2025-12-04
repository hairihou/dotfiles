---
name: conventional-comments
description: Write code review comments using Conventional Comments format. (https://conventionalcomments.org) Use when reviewing code, providing feedback on pull requests, suggesting improvements, or analyzing code changes. Produces structured, actionable comments with clear intent and machine-parsable labels.
---

# Conventional Comments

Write code review comments in a structured format that makes intent clear and enables machine parsing.

## Instructions

- Do NOT use praise, nitpick, or quibble labels. Focus only on actionable feedback.
- Every comment must be actionable or informative.
- Be concise. Omit unnecessary discussion.

### Format

```
<label>[!] [decorations]: <subject>

[discussion]
```

- **label**: Required. Indicates the type of comment.
- **`!` suffix**: Optional. Indicates blocking—must be addressed before approval.
- **decorations**: Optional. Comma-separated context in parentheses.
- **subject**: Required. The main message.
- **discussion**: Optional. Reasoning or suggested changes.

### Labels

| Label        | Description                                          |
| ------------ | ---------------------------------------------------- |
| `issue`      | Identifies a problem that needs to be addressed.     |
| `suggestion` | Proposes an improvement with an explicit change.     |
| `todo`       | Small, necessary change. Less severe than an issue.  |
| `question`   | Seeks clarification or investigation.                |
| `note`       | Information for the reader. Does not require action. |
| `typo`       | Points out a typographical error.                    |

### Decorations

| Decoration      | Description                      |
| --------------- | -------------------------------- |
| `(security)`    | Related to security concerns.    |
| `(performance)` | Related to performance concerns. |

## Examples

```
suggestion: Consider using optional chaining here.

`user && user.profile && user.profile.name` can be simplified to `user?.profile?.name`.
```

```
issue!: This function silently swallows exceptions.

Either log the error or propagate it to the caller.
```

```
suggestion! (security): User input should not be directly embedded in SQL.

Use prepared statements to prevent SQL injection.
```

```
todo!: Missing test coverage.

Add tests for edge cases (empty array, null values).
```
