---
allowed-tools: Bash(git rev-parse:*), Bash(ls:*), Bash(mkdir:*), Bash(touch:*), Read(~/Documents/Obsidian Vault/Diary/**), Update(~/Documents/Obsidian Vault/Diary/**), Write(~/Documents/Obsidian Vault/Diary/**)
description: Append session work summary to Obsidian diary
---

# Diary

Append today's session summary to Obsidian diary in `~/Documents/Obsidian Vault/Diary/YYYYMMDD.md`.

## Purpose

Support "Diary-Driven Work" (日記駆動仕事術) by extracting session work into diary entries.
The user writes their own diary - this command assists by organizing session activities.

## Diary Template (for new files)

```markdown
## Tasks

- [ ]

## Meeting

-

## Memo
```

Note: No h1 header needed - Obsidian shows filename as title.

## Session Entry Format (appended to Memo section)

```markdown
### repository-name

#### HH:MM

- [What was done 1]
- [What was done 2]

> 💭
```

- **repository-name**: From current working directory (basename of git root or cwd)
- **HH:MM**: Session start time - MUST verify with `date "+%H:%M"` command

Keep it factual and concise. User adds their own thoughts and feelings directly in Memo section.

### Same Repository Rule

If a session entry for the **same repository** already exists in the Memo section:

- Do NOT create a new `### repository-name` heading
- Add a new `#### HH:MM` subheading under the existing repository heading
- Keep entries chronologically ordered within the repository

## Steps

1. **Analyze Session**: Review conversation to extract:

   - Completed tasks and their outcomes
   - Technical challenges and solutions
   - Files created or modified

2. **Prepare Content**: Format as factual bullet points:

   - Action-oriented, past tense ("Implemented X", "Fixed Y")
   - Include file paths for significant changes
   - Note unresolved issues or next steps if any

3. **Check File**: Determine target file path:

   - Path: `~/Documents/Obsidian Vault/Diary/YYYYMMDD.md`
   - If new: create with full template (Tasks/Meeting/Memo sections)
   - If exists: append to Memo section

4. **Append Content**: Add session entry to Memo section:

   - Find `## Memo` section
   - Append session entry at the end of Memo section

5. **Confirm**: Show what was appended and file location

## Guidelines

- Keep entries factual and concise - user adds their own reflections
- Never overwrite existing content - always append
- Do not include emotions or opinions - that's the user's job
