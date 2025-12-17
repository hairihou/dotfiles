---
allowed-tools: Bash(basename:*), Bash(date:*), Bash(git log:*), Bash(git rev-parse --show-toplevel:*), Bash(pwd:*), Edit("~/Documents/Obsidian Vault/Diary/**"), Read("~/Documents/Obsidian Vault/Diary/**"), Write("~/Documents/Obsidian Vault/Diary/**")
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

> 💭
```

- **repository-name**: basename of git root or cwd
- **HH:MM**: Current time via `date "+%H:%M"`
- **💭**: Placeholder for user's own reflections

## Steps

1. **Analyze Session**: Review conversation and `git log` to extract completed tasks, challenges, and modified files

2. **Get Metadata**:

   - Time: `date "+%H:%M"`
   - Date: `date "+%Y%m%d"` (for filename)
   - Repo: Run `git rev-parse --show-toplevel` first, then run `basename <result>` separately (use `pwd` if not a git repo). Do NOT use subshell expansion like `$(...)` - run each command independently.

3. **Check Target File**: `~/Documents/Obsidian Vault/Diary/<date>.md`

   - If new: create with template below
   - If exists: read and append to Memo section

4. **Append Entry**: Add under `## Memo` section

   - Same repo exists → add new `#### HH:MM` under existing `### repo` heading
   - New repo → add new `### repo` heading

5. **Confirm**: Show appended content and file path

## New File Template

```markdown
## Tasks

- [ ]

## Meeting

-

## Memo
```

## Guidelines

- Factual, concise, action-oriented (past tense)
- Never overwrite - always append
- No emotions or opinions - user adds their own
