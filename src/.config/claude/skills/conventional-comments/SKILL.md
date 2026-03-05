---
name: conventional-comments
description: Use when writing PR or code review comments to ensure consistent format, clarity, and actionability.
disable-model-invocation: true
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
| `label`        | Yes      | Comment type (see labels reference)               |
| `!`            | No       | Blocking indicator—must resolve before approval   |
| `(decoration)` | No       | Comma-separated context tags (e.g., `(security)`) |
| `subject`      | Yes      | Main message (1 line)                             |
| `discussion`   | No       | Additional reasoning or suggested fix (1-3 lines) |

Read [references/labels.md](references/labels.md) for available labels, decorations, and detailed examples.
