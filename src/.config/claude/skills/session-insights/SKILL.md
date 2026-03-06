---
name: session-insights
description: Use at the end of a session to identify inefficiencies and improvement opportunities, especially for L/XL sessions (16+ turns).
disable-model-invocation: true
allowed-tools: Read, Glob, Grep
---

# Session Insights

Analyze the current conversation session and produce an improvement report.

## Taxonomy

### Session Categories

Classify into one of: Feature Development, Bug Fix, Code Review, Refactoring, Test, CI/CD, Documentation, Configuration, Research, Coaching

### Session Size

| Size | Criteria                                      |
| ---- | --------------------------------------------- |
| XS   | 1-3 turns, single focused task                |
| S    | 4-8 turns, straightforward task               |
| M    | 9-15 turns, moderate complexity               |
| L    | 16-25 turns, multiple subtasks or corrections |
| XL   | 26+ turns, significant scope or difficulties  |

L/XL sessions indicate potential inefficiencies worth analyzing.

### Issue Types

| Issue Type       | Signal                                                         |
| ---------------- | -------------------------------------------------------------- |
| Misunderstanding | User corrected agent's interpretation                          |
| Retry loop       | Same action attempted multiple times                           |
| Scope creep      | Task grew beyond original request                              |
| Missing context  | Agent asked for information that should have been in CLAUDE.md |
| Wrong tool/skill | Agent used wrong approach, user redirected                     |
| Wasted work      | Agent produced output that was discarded                       |
| Hallucination    | Agent assumed facts not in evidence                            |

### Feedback Types

#### Prompt Improvement

Rewrite the user's initial request to prevent issues observed in the session.

#### CLAUDE.md / Rules Suggestions

Rules or preferences that would prevent issues. Only suggest additions that would prevent issues observed in THIS session.

#### Skill Suggestions

Skills that were missing, underperformed, or misused.

### Knowledge Usage Categories

| Category   | Description                                                       |
| ---------- | ----------------------------------------------------------------- |
| Applied    | Rule/instruction that was followed and helped                     |
| Missed     | Rule/instruction that existed but was not applied when it should  |
| Misleading | Rule/instruction that caused incorrect behavior — consider update |

## Schema

### Input

- Current conversation session (implicit context)
- No arguments required

### Output

The report consists of four required sections. At least one Actionable Feedback subsection must be present. Each Knowledge Usage category may be "None" if not applicable.

## 1. Session Overview

Assess the session and output:

```markdown
## Session Overview

| Metric       | Value                                     |
| ------------ | ----------------------------------------- |
| Category     | <one from taxonomy>                       |
| Session Size | <XS/S/M/L/XL from taxonomy>              |
| Turns        | <integer>                                 |
| Tools Used   | <comma-separated list>                    |
| Skills Used  | <comma-separated list, or "None">         |
```

## 2. Issue Timeline

Scan the conversation for issue types from taxonomy.

Output as timeline:

```markdown
## Issue Timeline

1. **[Turn <N>]** <Issue Type from taxonomy> (Impact: high/medium/low)
   <What happened> → <What the correct action was>
```

If no issues found: "No issues identified. [one-sentence reasoning why session was efficient]"

## 3. Actionable Feedback

At least one of the following subsections must be present. Omit subsections only when genuinely not applicable.

### Prompt Improvement

If the initial prompt could have prevented issues:

```markdown
### Improved Prompt

> [Rewritten version of the user's initial request]

**Changes:**

- [What was added/clarified and why]
```

### CLAUDE.md / Rules Suggestions

If the session revealed missing conventions, preferences, or patterns:

```markdown
### Suggested Additions

**CLAUDE.md:**

- [Rule or preference to add]

**.claude/rules/[topic].md:**

- [Rule to add, with paths pattern]
```

Only suggest additions that would prevent issues observed in THIS session. Do not suggest generic improvements.

### Skill Suggestions

If a skill was missing, underperformed, or misused:

```markdown
### Skill Feedback

- **[skill-name]**: [What went wrong and how to improve the skill]
- **Missing skill**: [Description of a skill that would have helped]
```

## 4. Knowledge Usage

Review which CLAUDE.md rules and .claude/rules/ were relevant:

```markdown
## Knowledge Usage

### Applied

- [Rule/instruction that was followed and helped]

### Missed

- [Rule/instruction that existed but was not applied when it should have been]

### Misleading

- [Rule/instruction that caused incorrect behavior — consider updating]
```

Read CLAUDE.md and relevant .claude/rules/ files to cross-reference.

## Guidelines

- Be specific — cite conversation turns, not vague observations
- Focus on actionable improvements, not praise
- L/XL sessions deserve deeper analysis
- For XS/S sessions with no issues, keep the report brief
