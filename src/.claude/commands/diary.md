---
allowed-tools: Bash(date *), Bash(git *), Edit("~/Documents/Obsidian Vault/Diary/*.md"), Read("~/Documents/Obsidian Vault/Diary/*.md"), Write("~/Documents/Obsidian Vault/Diary/*.md")
description: Append session work summary to Obsidian diary
---

# Diary

Append session summary to Obsidian diary at `~/Documents/Obsidian Vault/Diary/YYYYMMDD.md`.

## Purpose

Support "Diary-Driven Work" (日記駆動仕事術) by organizing session activities into factual entries.

## Entry Format

```markdown
### repository-name

#### HH:MM

- [What was done]
  - [Reason for decision, if applicable]

> 💭
```

- **repository-name**: basename of git root or cwd
- **HH:MM**: Current time via `date "+%H:%M"`
- **Reason**: Add only when a decision or choice was made
- **💭**: Reflection placeholder for user

## Steps

1. **Analyze**: Review conversation and `git log` for completed tasks

2. **Get Metadata**:

   ```sh
   date "+%H:%M"
   date "+%Y%m%d"
   git rev-parse --show-toplevel
   ```

3. **Read/Create**: `~/Documents/Obsidian Vault/Diary/<date>.md`

   New file template:

   ```markdown
   ## Tasks

   - [ ]

   ## Meeting

   -

   ## Memo
   ```

4. **Append**: Add new time entry under existing repository section, or create new repository section

5. **Confirm**: Show appended content

## Guidelines

- Factual, concise, past tense
- Append only - never overwrite
