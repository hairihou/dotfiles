---
name: npm-update-report
description: >
  Generate npm package update investigation reports with impact assessment.
  When a PR updates package.json dependencies, investigate changelogs via web search,
  evaluate project impact, run verification commands, and output a markdown report.
  Triggers: create package update report, investigate dependency changes, check npm update impact
---

# npm Package Update Report Generator

## Workflow

1. **Identify Changes**: Extract updated packages from `package.json` diff, classify as major/minor/patch
2. **Investigate**: Web search for changelogs (major bumps, frameworks, build/test tools)
3. **Assess Impact**: Grep for package usage, evaluate breaking changes
4. **Verify**: Run available scripts (lint, typecheck, test, build) from package.json
5. **Output**: Write report to `{yyyyMMdd}.md`

## Key Rules

- Reference primary sources only (GitHub Releases, CHANGELOG.md)
- Detect package manager from lock file (package-lock.json, pnpm-lock.yaml)
- For monorepos, use workspace filters when needed

## Report Template

```markdown
# {branch-name} Package Update Report

## Summary

- Verification: PASSED / FAILED
- Updated packages: major X / minor X / patch X

## Major Changes

### {Package} (x.x.x -> y.y.y) [major/minor]

**Changes**: !Breaking: ... / New: ... / Fix: ...

**Project Impact**: Affected / Not affected (specify which features if affected)

**Reference**: [CHANGELOG](URL)

## Other Updates

| Package | Version | Type | Notes |
| ------- | ------- | ---- | ----- |

## Verification Results

{lint/typecheck/test/build output}

## Conclusion

- **Breaking Changes**: No action required / Action required
- **Recommended Action**: Ready to merge / Needs attention
```

## Formatting

- Prefix breaking changes with `!`
- Use `->` for version transitions
