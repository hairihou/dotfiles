---
name: decision-log
description: Use when a decision with alternatives is finalized — design, process, tooling, workflow, or otherwise. Also trigger when the conversation includes comparing options and one is chosen or recommended, or when recalling past decisions.
argument-hint: "[search]"
allowed-tools: AskUserQuestion, Bash(date *), Bash(git *), Bash(python *)
---

# Decision Log

Persistent decision record with alternatives and reasoning. Enables retrospective review of past choices and their outcomes.

## Context

- Date: !`date "+%Y%m%d"`
- Repository: !`git rev-parse --show-toplevel` (use basename only, e.g., `dotfiles` not the full path)
- DB: !`python ${CLAUDE_SKILL_DIR}/scripts/db.py init`
- Summary: !`python ${CLAUDE_SKILL_DIR}/scripts/db.py summary`

Script: `${CLAUDE_SKILL_DIR}/scripts/db.py`

## Mode: Record (default)

Use when no argument is provided or argument is not "search".

### Steps

1. **Analyze**: Review conversation for the most recent decision where alternatives were considered
2. **Extract**: Identify topic, chosen approach, alternatives considered, and reasoning
3. **Confirm**: Use AskUserQuestion to present the decision and get approval. Format the question as:

   ```
   Decision Record
   - Date: <date>
   - Repository: <repo-basename>
   - Topic: <short-label>
   - Chosen: <approach>
   - Alternatives: <other options considered>
   - Reasoning: <why this was chosen>
   ```

   Suggested responses: ["OK", "Revise"]
   If the user wants changes, revise and re-confirm.

4. **Insert**:

   ```sh
   python ${CLAUDE_SKILL_DIR}/scripts/db.py insert '<date>' '<repo>' '<topic>' '<chosen>' '<alternatives>' '<reasoning>'
   ```

5. The script prints the inserted row.

## Mode: Search

Use when argument contains "search".

### Steps

1. **Parse intent**: Understand what the user is looking for from conversation context
2. **Build and run query**: Run `python ${CLAUDE_SKILL_DIR}/scripts/db.py search --help` for available filters (`--repo`, `--match`, `--from`, `--to`). Also supports `detail <id>` and `update-outcome <id> '<outcome>'`.
3. **Format**: Present results in a readable format

## Guidelines

- **topic**: Use kebab-case short labels (e.g., `db-architecture`, `cache-strategy`, `skill-trigger-method`)
- **chosen/alternatives/reasoning**: Write in plain English, concise but complete
- **outcome**: Update later via search mode when results are known
- Escape single quotes in shell arguments: `'it'\''s'`

## Common Mistakes

- Writing a sentence as topic instead of a kebab-case label (e.g., `We decided to use PostgreSQL` → `database-selection`)
- Recording only the chosen approach without alternatives — the value is in knowing what was rejected and why
- Recording trivial decisions (variable naming, minor formatting) — only record decisions where alternatives had meaningful trade-offs
