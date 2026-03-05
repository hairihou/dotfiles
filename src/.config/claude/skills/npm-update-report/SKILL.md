---
name: npm-update-report
description: Use for periodic dependency maintenance, when security vulnerabilities are reported, or when outdated packages need assessment.
disable-model-invocation: true
allowed-tools: Bash(npm:*), Bash(pnpm:*), Bash(yarn:*), Bash(node:*), Bash(python*), Grep, Read, WebSearch
---

# Package Update Report

## Context

- Lock files: !`ls package-lock.json pnpm-lock.yaml yarn.lock 2>/dev/null`
- Available scripts: !`node -e "const p=require('./package.json');console.log(Object.keys(p.scripts||{}).join(', '))" 2>/dev/null`

## Workflow

| Step | Action           | Details                                                            |
| ---- | ---------------- | ------------------------------------------------------------------ |
| 1    | Detect PM        | Identify PM from lockfile (see command table below)                |
| 2    | Check outdated   | List packages with available updates                               |
| 3    | Update packages  | Update according to strategy below                                 |
| 4    | Classify changes | Extract diff from `package.json`, classify as major/minor/patch    |
| 5    | Investigate      | Web search changelogs for major/minor bumps and key packages       |
| 6    | Assess impact    | Grep for package usage, evaluate breaking changes                  |
| 7    | Audit            | Run security audit, include advisory URLs for vulnerabilities      |
| 8    | Verify           | Run `python scripts/run-verification.py <pm>` — outputs PASS/FAIL/SKIP per script |
| 9    | Output           | Follow [references/report-template.md](references/report-template.md) and [references/schema.md](references/schema.md) |

## Package Manager Detection

Detect PM from lockfile per CLAUDE.md rules. If no lockfile found, stop and inform user.

**Monorepo workspace commands:** `pnpm --filter {pkg}`, `npm -w {pkg}`, `yarn workspace {pkg}`

## Update Strategy

| Type  | Action                                |
| ----- | ------------------------------------- |
| Patch | Auto-update via `{pm} update`         |
| Minor | Auto-update, investigate key packages |
| Major | Confirm with user before update       |

## Investigation Criteria

**Sources:** GitHub Releases, CHANGELOG.md, official blogs only

**Always investigate:**

- Major version bumps (breaking changes likely)
- Minor bumps of: frameworks (React, Vue, Next.js), build tools (Vite, esbuild), test tools (Vitest, Jest)

**Investigate if verification fails:**

- Any package that may be related to the failure

**Skip:** Patch-only updates with passing verification

## Error Handling

- **No lockfile found** → stop, inform user to run package manager install first
- **`outdated` command returns empty** → report "all packages up to date", skip remaining steps
- **Verification script not found** (e.g., no `test` script) → skip that check, note in report
- **Major update causes verification failure** → revert that specific package, note in report as "requires manual migration"

## Verification Failure Handling

If verification fails:

1. Identify failing script and error message
2. Search for related packages in the error
3. Investigate those packages' changelogs for breaking changes
4. Document findings in report under "Verification Results"
5. Set conclusion to "Needs attention" with specific action items
