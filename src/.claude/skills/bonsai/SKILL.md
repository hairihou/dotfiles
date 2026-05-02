---
name: bonsai
description: Maintain and groom config files in the current repository. Use when reviewing config health, pruning unused entries, fixing cross-file inconsistencies, or applying format changes after tool upgrades. Triggered also by "bonsai", "tidy up", "spring cleaning". Not for code quality review — use code-critic for that.
allowed-tools: Bash, Edit, Glob, Grep, Read
---

# Bonsai

Inspect config files in the **current repository** and report maintenance opportunities. Each run, pick one or more items from the checklist below — do not try to do everything at once.

**Scope:** the current working directory (repository) only. Do not inspect home directory dotfiles, shell setup, or global tool configs unless the user explicitly asks.

**Finding budget:** stop at 5 findings per session. A grooming session is valuable only when each item gets discussed; a 30-finding wall guarantees nothing gets fixed.

## Workflow

1. Detect the project's primary language(s) via Glob (`package.json` → JS/TS, `pyproject.toml` → Python, `Cargo.toml` → Rust, `go.mod` → Go). Use this to scope the checklist — a JS-style "dead export" check on a Rust repo is wasted work.
2. Explore the repository structure with Glob and Read. Skip checklist items that have no matching files.
3. Report findings using the output format below. **Do not edit files.**
4. If the user explicitly asks to apply changes, edit only the approved items. Do not auto-commit.

## Checklist

Pick items relevant to the current state.

### Consistency

- [ ] Config key ordering per project conventions (alphabetical within same level)
- [ ] Git config: deprecated options or missing recommended settings
- [ ] Keybinding conflicts or gaps across tools
- [ ] Value alignment across configs that share settings (themes, paths, env vars)

### Hygiene

- [ ] Commented-out code that should be removed or restored
- [ ] File ordering per project conventions
- [ ] TODO/FIXME/HACK comments
- [ ] Unnecessary blank lines or inconsistent formatting

### Pruning

- [ ] Dead or broken symlinks — `find . -xtype l -not -path '*/node_modules/*'`
- [ ] Package lists: detect duplicates or entries no longer needed — `sort <list> | uniq -d`
- [ ] Scripts that duplicate existing tools or each other — diff with `diff -q <a> <b>` after a name-based shortlist
- [ ] Unused aliases, functions, or config blocks — `grep -rL '<name>' <consumer-dirs>` to confirm no callsite
- [ ] Version manager tools no longer used — cross-reference declared tools with shell history / git log of their config files

### Upgrades

- [ ] Config format changes from tool updates (breaking changes in new versions)
- [ ] Package lists: renamed or deprecated packages
- [ ] Tool versions: flag significantly outdated entries

## Output Format

Report findings as a numbered list. Each item must include:

1. **File** — path relative to repository root
2. **Finding** — what was found and why it matters
3. **Proposed change** — the specific edit, or "remove" / "no action needed"

## Guidelines

- **Read every file individually.** Bulk reading causes misreads.
- Read before suggesting. Never propose changes to files you have not read.
- Scope changes narrowly. A bonsai session should produce a small, reviewable diff.
- Explain the "why" for each change, not just the "what".

## Common Mistakes

- **Proposing to delete config consumed by CI** — a config block with no local consumer may still be read by `.github/workflows/*.yml`, Renovate, or pre-commit. Grep CI files before flagging as dead
- **Removing TODO/FIXME without owner check** — these often encode known constraints. Run `git log -S '<TODO text>'` to find the author and original commit before suggesting removal
- **Ordering churn for its own sake** — re-sorting a 200-line config produces a noisy diff that drowns the actual fixes. Skip ordering items unless the user opted into them
- **Touching machine-local files** — `.env.local`, `*.local.*`, gitignored files belong to the user's machine, not the repo. Out of scope
