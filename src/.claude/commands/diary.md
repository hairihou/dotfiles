---
allowed-tools: Bash(date:*), Bash(git:*), Edit("~/Documents/Obsidian Vault/Diary/**"), Read("~/Documents/Obsidian Vault/Diary/**"), Write("~/Documents/Obsidian Vault/Diary/**")
description: Append session work summary to Obsidian diary
---

# Diary

Append session summary to Obsidian diary at `~/Documents/Obsidian Vault/Diary/YYYYMMDD.md`.

## Purpose

Support "Diary-Driven Work" (日記駆動仕事術) by organizing session activities into factual entries.

## Entry Format

### New Repository

```markdown
### repository-name

#### HH:MM

- [What was done]

> 💭
```

### Adding to Existing Repository

```markdown
### repository-name

#### HH:MM (existing)

- [Previous work]

> 💭

#### HH:MM (new)

- [What was done]

> 💭
```

- **repository-name**: basename of git root or cwd
- **HH:MM**: Current time via `date "+%H:%M"`
- **💭**: Each time entry gets its own reflection placeholder

## Steps

1. **Analyze**: Review conversation and `git log` for completed tasks

2. **Get Metadata**:

   ```sh
   date "+%H:%M"
   date "+%Y%m%d"
   git rev-parse --show-toplevel | xargs basename
   ```

3. **Read/Create**: `~/Documents/Obsidian Vault/Diary/<date>.md`

4. **Append**: Follow Entry Format above

5. **Confirm**: Show appended content

## New File Template

```markdown
## Tasks

- [ ]

## Meeting

-

## Memo
```

## Guidelines

- Factual, concise, past tense
- Append only - never overwrite
