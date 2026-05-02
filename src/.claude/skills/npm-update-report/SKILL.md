---
name: npm-update-report
description: Update package dependencies with vulnerability assessment and verification. Use when asked to check outdated packages, bump dependencies, run audit, do periodic dependency maintenance, or when security vulnerabilities are reported.
disable-model-invocation: true
allowed-tools: Bash, Grep, Read, WebSearch
---

# npm Update Report

## Context

- Lock files: !`ls package-lock.json pnpm-lock.yaml yarn.lock 2>/dev/null`
- Available scripts: !`node -e "const p=require('./package.json');console.log(Object.keys(p.scripts||{}).join(', '))" 2>/dev/null`

## Workflow

| Step | Action           | Details                                                                           |
| ---- | ---------------- | --------------------------------------------------------------------------------- |
| 1    | Detect PM        | Identify PM from lockfile (see command table below)                               |
| 2    | Check outdated   | List packages with available updates                                              |
| 3    | Update packages  | Update according to strategy below                                                |
| 4    | Classify changes | Extract diff from `package.json`, classify as major/minor/patch                   |
| 5    | Investigate      | Web search changelogs for major/minor bumps and key packages                      |
| 6    | Assess impact    | Grep for package usage, evaluate breaking changes                                 |
| 7    | Audit            | Run security audit, include advisory URLs for vulnerabilities                     |
| 8    | Verify           | Run `${CLAUDE_SKILL_DIR}/scripts/run-verification.py <pm>` — outputs PASS/FAIL/SKIP per script |
| 9    | Output           | Follow report template in `${CLAUDE_SKILL_DIR}/references/report-template.md`     |

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

**Search hygiene:** Cache results within the run. Never WebSearch the same `<package>@<version>` twice in one report — collect findings in working memory and reuse

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

## Audit Severity Threshold

Report `moderate` and above by default. Suppress `low` and `info` unless the user explicitly asked for an exhaustive audit — they generate noise that drowns the actionable findings.

## Common Mistakes

- **PASS without verification** — reporting success without running the verification script. The Update step modifies the lockfile; PASS is meaningful only after Step 8 has executed
- **Peer dep blindness** — a package's own changelog rarely lists breaking changes that propagate from a peer dep bump. When `npm ls` warns about peer mismatches, treat it as a real signal, not noise
- **Monorepo root-only update** — running `pnpm update` at the root leaves workspace packages on stale versions. Always iterate per-workspace or use the recursive flag
- **Unpinning during update** — `npm update` can rewrite `^1.2.3` to `^1.5.0` in package.json. Verify the diff matches the intended scope; revert range widening that wasn't requested
