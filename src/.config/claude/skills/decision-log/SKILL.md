---
name: decision-log
description: Record or search technical decisions. Default mode records the most recent decision from conversation. Use with "search" argument to query past decisions.
disable-model-invocation: true
allowed-tools: AskUserQuestion, Bash(python:*), Bash(date:*), Bash(git rev-parse:*)
---

# Decision Log

## Context

- Date: !`date "+%Y%m%d"`
- Repository: !`git rev-parse --show-toplevel` (use basename only, e.g., `dotfiles` not the full path)
- DB: !`python ~/.config/claude/skills/decision-log/scripts/db.py init`
- Summary: !`python ~/.config/claude/skills/decision-log/scripts/db.py summary`

Script: `~/.config/claude/skills/decision-log/scripts/db.py`

## Mode: Record (default)

Use when no argument is provided or argument is not "search".

### Steps

1. **Analyze**: Review conversation for the most recent design/architecture/technology decision
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
   python ~/.config/claude/skills/decision-log/scripts/db.py insert '<date>' '<repo>' '<topic>' '<chosen>' '<alternatives>' '<reasoning>'
   ```

5. The script prints the inserted row.

## Mode: Search

Use when argument contains "search".

### Steps

1. **Parse intent**: Understand what the user is looking for from conversation context
2. **Build and run query**:

   ```sh
   # All decisions for current repo
   python ~/.config/claude/skills/decision-log/scripts/db.py search --repo '<repo>'

   # Full-text search
   python ~/.config/claude/skills/decision-log/scripts/db.py search --match '<keyword>'

   # Date range
   python ~/.config/claude/skills/decision-log/scripts/db.py search --from '<start>' --to '<end>'

   # Combined filters
   python ~/.config/claude/skills/decision-log/scripts/db.py search --repo '<repo>' --match '<keyword>'

   # Full detail for a specific decision
   python ~/.config/claude/skills/decision-log/scripts/db.py detail <id>

   # Update outcome
   python ~/.config/claude/skills/decision-log/scripts/db.py update-outcome <id> '<outcome>'
   ```

3. **Format**: Present results in a readable format

## Guidelines

- **topic**: Use kebab-case short labels (e.g., `db-architecture`, `cache-strategy`, `auth-flow`)
- **chosen/alternatives/reasoning**: Write in plain English, concise but complete
- **outcome**: Update later via search mode when results are known
- Escape single quotes in shell arguments: `'it'\''s'`
