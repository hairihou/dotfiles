---
allowed-tools: Bash(ls:*), Bash(mkdir:*), Bash(touch:*), Read(~/Documents/Obsidian Vault/Daily/**)
description: Append session work summary to Obsidian daily note
---

# Daily

Append today's session summary to Obsidian daily note in `~/Documents/Obsidian Vault/Daily/YYYYMMDD.md`.

## Purpose

Support "Diary-Driven Work" (日記駆動仕事術) by extracting session work into daily notes.
The user writes their own diary - this command assists by organizing session activities.

## Daily Note Template (for new files)

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
### Session: HH:MM - repository-name

- [What was done 1]
- [What was done 2]
- [Technical issue solved (if any)]

> 💭
```

- **HH:MM**: Session start time (from first message in conversation or first commit time)
- **repository-name**: From current working directory (basename of git root or cwd)

Keep it factual and concise. User adds their own thoughts and feelings directly in Memo section.

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

   - Path: `~/Documents/Obsidian Vault/Daily/YYYYMMDD.md`
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
