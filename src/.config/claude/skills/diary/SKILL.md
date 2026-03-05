---
name: diary
description: Use at the end of a work session to capture completed tasks, decisions, and learnings in Obsidian daily note.
disable-model-invocation: true
allowed-tools: Bash(date *), Bash(git *), Edit("~/Documents/Obsidian Vault/Diary/*.md"), Read("~/Documents/Obsidian Vault/Diary/*.md"), Write("~/Documents/Obsidian Vault/Diary/*.md")
---

# Diary

## Context

- Date: !`date "+%Y%m%d"`
- Time: !`date "+%H:%M"`
- Repository: !`git rev-parse --show-toplevel`

Target: `~/Documents/Obsidian Vault/Diary/YYYYMMDD.md`

## Entry Format

```markdown
### repository-name

#### HH:MM

- [What was done]
  - [Reason for decision, if applicable]

> 💭
```

- **repository-name**: basename of git root (extract from command output, do not use `basename` command)
- **HH:MM**: Current time via `date "+%H:%M"`
- **Reason**: Add only when a decision or choice was made
- **💭**: Reflection placeholder for user

## Steps

1. **Analyze**: Review conversation and `git log` for completed tasks

2. **Read/Create**: `~/Documents/Obsidian Vault/Diary/<date>.md`

   New file template:

   ```markdown
   ## Tasks

   - [ ]

   ## Meeting

   -

   ## Memo
   ```

3. **Append**: Add new time entry under existing repository section, or create new repository section

4. **Confirm**: Show appended content

## Error Handling

- If `~/Documents/Obsidian Vault/Diary/` does not exist, stop and inform the user. Do not create the vault directory structure — the user may need to set up Obsidian first.
- If the daily note exists but has unexpected format, append at the end rather than guessing structure.

## Guidelines

- Factual, concise, past tense
- Append only - never overwrite
