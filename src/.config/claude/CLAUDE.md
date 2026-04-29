# CLAUDE.md

## Design Principles

- Boundaries (file / module / abstraction / alias / re-export): require a consumer that can be named at a concrete existing path — speculative consumers ("future code that might import this") do not count, and unjustified indirection is pure cost
- Pre-implementation self-check: am I adding indirection? can I name the consumer at a concrete path? if not, prefer inline / direct import / relative import
- Exception: package public entrypoint (file referenced by `package.json#exports`/`main`/`module`); established project conventions (repo CLAUDE.md or strong existing-codebase signal) take precedence over this rule

## Reasoning

- Code review: state impact scope or explain why a change is safe — never just "no issues found"
- Code review: distinguish surface fix (symptom) from root fix (cause); label which
- Design decisions (architecture, technology selection, large-scale refactoring): present alternatives with trade-offs using advocate/critic analysis, state biggest risk
- Underspecified requirements/scope: ask before implementing — do not proceed on silent assumptions for non-trivial commitments

## Code Style

- Comments: default to none; warranted only for hidden constraints (undocumented API quirk, required call ordering, external bug workaround) — design rationale belongs in PR description / commit message / decision log, not source files
- Ordering (code, config, documentation): semantic hierarchy (main rule → exceptions/modifiers → details) first; alphabetical only as tiebreaker among same-level peers
  - Example: CSS `display` → `overflow` → `margin`/`padding`; config: required fields → optional fields

## Communication Style

- Quantitative work volume (line counts, file counts, `+X/-Y`, "N files changed", completion %) in PR/issue bodies, commit messages, progress updates, summaries: omit — the diff or task list already shows volume. Describe impact, rationale, and risk instead
- Start responses with actionable content directly; polite/formal tone without filler ("Good question", "You're right", etc.)

## Git Conventions

- Branch: `#<number>_<type>/<description>` (e.g., `#42_feat/add-login`)
- Commit: Conventional Commits (build, chore, ci, docs, feat, fix, perf, refactor, style, test) (e.g., `feat(auth): add OAuth2 support`)
- Commit message: use plain text descriptions instead of `@` prefixed tags (`@link`, `@see`, `@todo`, `@param`) — they trigger unwanted mentions on GitHub
- Issue: `<type>(<subject>): <description>` (e.g., `bug(api): 429 responses on batch endpoint`)
