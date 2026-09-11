# CLAUDE.md

## Design Principles

- Boundaries (file / module / abstraction / alias / re-export): add one only when a consumer can be named at a concrete existing path; speculative consumers ("future code that might import this") do not count. Otherwise prefer inline / direct import / relative import
  - **Exception:** package public entrypoint (the file/symbol designated by the language's packaging convention as the external API surface)
- Dependency selection (library / CLI tool / GitHub Action / plugin): check the latest release date before proposing, never from recall; reject anything over a year old. A project that stopped shipping releases will not ship the fix you need
  - **Exception:** no maintained alternative and not reasonably self-written. State the staleness when proposing it

## Reasoning

- Code review (never default to "no issues found"):
  - assess impact scope; name what the change's safety depends on and tag its evidence as `[cited]` (`file:line`), `[reasoned]` (failure path unreachable), or `[executed]` (ran the code). Report anything below `[executed]` as unconfirmed
  - separate surface fix (symptom) from root fix (cause); tag each proposed fix as `[surface]` or `[root]`
- Design decisions (architecture, technology selection, large-scale refactoring): compare at least 2 named alternatives with explicit pros/cons, identify the biggest risk before committing

## Code Style

- Comments: default to none. Never restate the code or what the signature declares (parameter names, types, return values); warranted only for hidden constraints (undocumented API quirk, required call ordering, external bug workaround). State the constraint. Design rationale goes in PR / commit / decision log, not source
  - Referenced issue / PR / doc: full URL, never a bare issue number
- Ordering (code, documentation): semantic hierarchy (main rule → exceptions/modifiers → details) first; alphabetical only as tiebreaker among same-level peers
  - Example: core behavior → edge cases

## Communication Style

- Quantitative work volume (line counts, file counts, `+X/-Y`, completion %) in PR/issue bodies, commit messages, progress updates, summaries: omit. The diff or task list already shows volume. Describe impact, rationale, and risk instead

## Git Conventions

- Type vocabulary (shared across Issue / Branch / Commit): Conventional Commits (build, chore, ci, docs, feat, fix, perf, refactor, style, test)
- Issue / Commit: `<type>(<scope>): <description>` (e.g., `fix(api): 429 responses on batch endpoint`)
- Issue: `--assignee @me` only when the issue will be worked on immediately; leave backlog/idea issues unassigned
- Branch: `[#<number>_]<type>/<description>`. Issue number prefix when an issue exists, omit otherwise (e.g., `#42_feat/add-login`, `fix/cert-expiry`)
- GitHub-rendered text (commit message, PR / issue body, review comments): no `@`-prefixed words (`@name`, doc tags like `@todo`, npm scopes like `@scope/pkg`). GitHub renders them as mentions and notifies unrelated users/orgs; write the bare name instead
  - **Exception:** deliberate mentions of a specific user/team
