---
name: handoff
description: Write a handoff document into the repository's .git directory so a fresh session with zero context can resume the current work. Use when the user wants to wrap up the current session and continue in a new one, or when context is running low mid-task and the work must transfer. Not for durable decision records, routine progress reports, or in-session summaries.
argument-hint: '[note for the next session]'
allowed-tools: Read, Write, Bash, TaskList
---

# Handoff

One-shot transfer of in-progress work from this session to the next. The document is the only thing the next session sees — anything not written here is lost.

## Context

- Date: !`date "+%Y-%m-%d"`
- Destination: !`echo "$(git rev-parse --absolute-git-dir 2>/dev/null || echo "$HOME/.claude/handoffs/$(basename "$PWD")")/handoff.md"`

## Steps

1. **Collect**: current branch and working-tree state (`git status --short`), in-progress tasks, the active plan file if one exists, and from the conversation: adopted approaches, rejected alternatives with reasons, constraints established during the session, and work that is done but unverified. If the user passed a note as argument, incorporate it into the relevant section verbatim.
2. **Write** the destination file from Context — inside `.git/` it can never be committed regardless of ignore rules; create parent directories if missing, overwrite any existing handoff (a stale handoff is worse than none) — with exactly these headings in this order:
   - `# Handoff (<date>)`
   - `## Goal` — the overall task and its definition of done
   - `## Current State` — branch, uncommitted files, what is done, what is in progress, what is implemented but unverified
   - `## Decisions` — adopted approaches, each with the reason
   - `## Do Not Redo` — rejected alternatives and dead ends, each with why it was rejected
   - `## Constraints` — rules established during the session, blockers, environment quirks
   - `## Next Steps` — concrete next actions with file paths, most immediate first
3. **Verify**: re-read the file, check that every heading exists and every statement passes the zero-context test below. Fix and re-verify until it does.
4. **Report** to the user: the absolute file path, and the resume instruction — start a new session and ask it to read that path and continue from Next Steps.

## Zero-Context Test

The reader knows nothing about this conversation.

- No references to the conversation ("as discussed", "the earlier approach", "you said")
- Every file is named by repo-relative path
- Every rejected alternative carries its reason — a bare "tried X" invites retrying X
- Verified and unverified are explicitly separated ("tests pass" vs "compiles, not yet run")

## Common Mistakes

- Writing a progress report addressed to the user instead of instructions addressed to the next session
- Recording only the chosen approach — the value of Do Not Redo is knowing what to skip
- Vague next steps ("continue the refactor") instead of actionable ones ("apply the same rename in src/api/client.ts")
- Padding sections to look complete — write "none" when a section is genuinely empty
