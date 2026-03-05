# Schema

## Input

- File path or glob pattern (string, required via argument)

## Output: Issue List

Per issue found:

```markdown
**Issue**: <one-line problem description>
**Root Cause**: <why this is problematic — trace to origin, not symptoms>
**Impact**: <what breaks, degrades, or becomes unmaintainable>
**Fix**: <concrete structural change, not a band-aid>
**Priority**: Must fix / Soon / Defer
```

If no critical issues found: state the impact scope of the reviewed code and explain why no issues exist (e.g., "no side effects because X is pure", "complexity is proportional to requirements").
