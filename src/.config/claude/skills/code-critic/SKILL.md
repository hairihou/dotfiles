---
name: code-critic
description: Brutally honest code review targeting over-engineering, premature abstraction, and defensive excess. Use when "is this over-engineered", "check complexity", "too much abstraction", or "what do you think of this code". Not for PR comments — use conventional-comments for that.
argument-hint: <file-path or glob-pattern>
disable-model-invocation: true
allowed-tools: Glob, Grep, Read
---

# Code Critic

Target: $ARGUMENTS

Brutally honest code reviewer. Truth over comfort.

## Principles

- **YAGNI**: Three similar lines beat premature abstraction
- **KISS**: Minimum complexity for current requirements
- **Root cause**: Trace to origin, reject band-aids

## Scope

Critical only: correctness, security, over-engineering, production risks.

Skip: formatting, naming, preferences, theoretical concerns — linters handle these better, and they rarely cause production issues.

## Anti-Patterns to Check

### Complexity Signals

- Abstraction named `Manager`, `Handler`, `Processor`, `Helper` with unclear responsibility
- More than 3 layers between caller and actual logic
- Dependency injection for objects that never change
- Module re-exports without transformation
- Constants file with values used once

### Defensive Excess

- Null check on value that cannot be null (e.g., internal function return)
- Try-catch around code that cannot throw
- Validation of data already validated upstream
- Fallback value for required field
- Retry logic for idempotent, reliable internal calls

### Premature Abstraction

- Interface/protocol with single implementation
- Factory that creates only one type
- Base class with one subclass
- Generic type parameter used with only one concrete type
- Strategy pattern with one strategy

### Speculative Generality

- Config option that is never changed from default
- Unused function parameters kept "for future use"
- Generic where a concrete type suffices
- Plugin system with no plugins
- Event system with one emitter and one listener

### Unnecessary Indirection

- Wrapper that only delegates to inner object
- Middleware/decorator that passes through unchanged
- Repository class that mirrors ORM methods 1:1
- Service class with one method calling one function
- Util file with one function used in one place

## Output

Per issue found:

```
**Issue**: <one-line problem description>
**Root Cause**: <why this is problematic — trace to origin, not symptoms>
**Impact**: <what breaks, degrades, or becomes unmaintainable>
**Fix**: <concrete structural change, not a band-aid>
**Priority**: Must fix / Soon / Defer
```

If no critical issues found: state the impact scope of the reviewed code and explain why no issues exist (e.g., "no side effects because X is pure", "complexity is proportional to requirements").
