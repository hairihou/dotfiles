---
name: decision-log
description: Persist a decision that has just been settled — the alternatives rejected, the reasoning, the consequences accepted, and the condition for revisiting it — into one database shared by every repository, and retrieve past ones from any of them. Use at the moment a design, architecture, or tooling choice stops being weighed and becomes what will be done, and whenever the alternatives or rationale behind an earlier choice are asked for, including a choice settled while working somewhere else. Not for choices without meaningful trade-offs.
argument-hint: '[search|supersede <id>|delete <id>]'
allowed-tools: Bash
---

# Decision Log

One record shared across every repository. `repository` is a column, not a partition: search spans all repos unless `--repo` narrows it, so a decision made here stays reachable from anywhere else.

## Context

- Date: !`date "+%Y%m%d"`
- Repository: !`git rev-parse --show-toplevel` (use basename only, e.g., `dotfiles` not the full path)
- DB: !`uv run --script ${CLAUDE_SKILL_DIR}/scripts/db.py init`
- Summary: !`uv run --script ${CLAUDE_SKILL_DIR}/scripts/db.py summary`

Script: `${CLAUDE_SKILL_DIR}/scripts/db.py` — pass single-quoted arguments, escaping inner quotes as `'it'\''s'`.

## Mode: Record (default)

When `$ARGUMENTS` starts with none of `search`, `supersede`, `delete`.

1. Find the most recent decision in the conversation where alternatives were actually weighed, and extract every field below. A record without its rejected alternatives loses most of its value — that is the part nothing else preserves
2. Present the extracted record via AskUserQuestion (`["OK", "Revise"]`), revising and re-confirming until approved
3. Insert:

   ```sh
   uv run --script ${CLAUDE_SKILL_DIR}/scripts/db.py insert '<date>' '<repo>' '<topic>' '<chosen>' '<alternatives>' '<reasoning>' --consequences '<consequences>' --confidence <level> --reevaluate-when '<condition>'
   ```

   Omit the optional flags that do not apply.

### Fields

Write `chosen`, `alternatives`, and `reasoning` in plain English, concise but complete.

- **topic**: kebab-case label, not a sentence (`database-selection`, not `We decided to use PostgreSQL`)
- **reasoning** is why this won; **consequences** is what follows from it — operational impact, trade-offs accepted, follow-up work required
- **confidence**: `high` = clear winner after research, `medium` = alternatives were close, `low` = best guess under uncertainty or time pressure. Do not default to `high`
- **reevaluate_when**: the specific condition that should trigger revisiting (e.g. "latency exceeds 200ms", "library reaches v2.0")
- **outcome**: left empty at insert; fill in later with `update-outcome <id> '<outcome>'` once results are known

## Mode: Supersede

When `$ARGUMENTS` starts with `supersede`. An accepted decision is never edited — supersede it, which marks the old record and links it to the new one.

Locate the target with search (`detail <id>` for full context), then follow the Record flow, additionally showing which decision is being superseded and why.

```sh
uv run --script ${CLAUDE_SKILL_DIR}/scripts/db.py supersede <old-id> '<date>' '<repo>' '<topic>' '<chosen>' '<alternatives>' '<reasoning>' --consequences '<consequences>' --confidence <level> --reevaluate-when '<condition>'
```

## Mode: Delete

When `$ARGUMENTS` starts with `delete`. Only for records that should never have existed: mis-recorded entries (trivial, duplicate, wrong repo) or sensitive content that must not persist. A decision that changed is not a mistake — supersede it instead.

Show `detail <id>` and confirm via AskUserQuestion before running `db.py delete <id>`. A single ID only: bulk deletion by date range or repo is intentionally unsupported, so decline such requests and offer per-record review. Deleting a record that had superseded another restores the predecessor to `accepted`.

## Mode: Search

When `$ARGUMENTS` starts with `search`. Infer what is being looked for from conversation context, then query with the documented flags only — inventing others (`--head`, `--limit`, `--recent`) fails. For "recent decisions", pass `--from <YYYYMMDD>`.

- `search` filters: `--repo`, `--match`, `--from`, `--to`, `--status`
- Other subcommands: `detail <id>`, `update-outcome <id> '<outcome>'`
- When unsure, run `db.py search --help` first
