---
name: decision-log
description: Use when discussing trade-offs, comparing alternatives, choosing between options, making design/architecture/tooling/workflow decisions, or answering "which should I use?" questions. Also trigger when a decision is finalized, when reviewing or recalling past decisions, or when the user asks "why did we choose X?"
argument-hint: "[search|supersede <id>]"
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
2. **Extract**: Identify topic, chosen approach, alternatives, reasoning, consequences, confidence, and reevaluation trigger
3. **Confirm**: Use AskUserQuestion to present the decision and get approval. Format the question as:

   ```text
   Decision Record
   - Date: <date>
   - Repository: <repo-basename>
   - Topic: <short-label>
   - Chosen: <approach>
   - Alternatives: <other options considered>
   - Reasoning: <why this was chosen>
   - Consequences: <expected impact — what happens as a result>
   - Confidence: <high|medium|low>
   - Reevaluate when: <condition that should trigger revisiting this decision>
   ```

   Suggested responses: ["OK", "Revise"]
   If the user wants changes, revise and re-confirm.

4. **Insert**:

   ```sh
   python ${CLAUDE_SKILL_DIR}/scripts/db.py insert '<date>' '<repo>' '<topic>' '<chosen>' '<alternatives>' '<reasoning>' --consequences '<consequences>' --confidence <level> --reevaluate-when '<condition>'
   ```

   Omit `--consequences`, `--confidence`, or `--reevaluate-when` if not applicable.

5. The script prints the inserted record.

## Mode: Supersede

Use when argument starts with "supersede". Never edit an accepted decision — supersede it instead.

### Steps

1. Find the decision to supersede via search (`detail <id>` for full context)
2. Follow the same Extract → Confirm flow as Record mode, but also show which decision is being superseded and why
3. **Insert**:

   ```sh
   python ${CLAUDE_SKILL_DIR}/scripts/db.py supersede <old-id> '<date>' '<repo>' '<topic>' '<chosen>' '<alternatives>' '<reasoning>' --consequences '<consequences>' --confidence <level> --reevaluate-when '<condition>'
   ```

4. The script marks the old decision as `superseded` and links it to the new one.

## Mode: Search

Use when argument contains "search".

### Steps

1. **Parse intent**: Understand what the user is looking for from conversation context
2. **Build and run query**: Run `python ${CLAUDE_SKILL_DIR}/scripts/db.py search --help` for available filters (`--repo`, `--match`, `--from`, `--to`, `--status`). Also supports `detail <id>` and `update-outcome <id> '<outcome>'`.
3. **Format**: Present results in a readable format

## Guidelines

- **chosen/alternatives/reasoning**: Write in plain English, concise but complete
- **topic**: Use kebab-case short labels (e.g., `db-architecture`, `cache-strategy`, `skill-trigger-method`)
- **confidence**: `high` = well-researched with clear winner, `medium` = reasonable choice but alternatives are close, `low` = best guess under uncertainty or time pressure
- **consequences**: What happens as a result of this decision — operational impact, trade-offs accepted, follow-up work required. Distinct from reasoning (why) — consequences describe what follows (then what)
- **reevaluate_when**: The specific condition that should trigger revisiting this decision (e.g., "team grows past 5 people", "latency exceeds 200ms", "library reaches v2.0")
- **outcome**: Update later via search mode when results are known
- **supersede**: When a decision changes, never modify the original — use supersede mode to preserve history
- Escape single quotes in shell arguments: `'it'\''s'`

## Common Mistakes

- Writing a sentence as topic instead of a kebab-case label (e.g., `We decided to use PostgreSQL` → `database-selection`)
- Recording only the chosen approach without alternatives — the value is in knowing what was rejected and why
- Recording trivial decisions (variable naming, minor formatting) — only record decisions where alternatives had meaningful trade-offs
- Confusing reasoning with consequences: reasoning = "Redis is faster for our access pattern" / consequences = "adds operational dependency on Redis, need monitoring"
- Setting confidence to high by default — be honest about uncertainty
