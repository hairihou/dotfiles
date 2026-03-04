---
name: session-insights
description: Analyze the current session to identify inefficiencies and suggest improvements.
disable-model-invocation: true
allowed-tools: Read, Glob, Grep
---

# Session Insights

Analyze the current conversation session and produce an improvement report.

## 1. Session Overview

Assess the session and output:

```markdown
## Session Overview

| Metric       | Value          |
| ------------ | -------------- |
| Category     | [see below]    |
| Session Size | [XS/S/M/L/XL]  |
| Turns        | [approx count] |
| Tools Used   | [list]         |
| Skills Used  | [list]         |
```

### Categories

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

## 2. Issue Timeline

Scan the conversation for these issue types:

| Issue Type       | Signal                                                         |
| ---------------- | -------------------------------------------------------------- |
| Misunderstanding | User corrected agent's interpretation                          |
| Retry loop       | Same action attempted multiple times                           |
| Scope creep      | Task grew beyond original request                              |
| Missing context  | Agent asked for information that should have been in CLAUDE.md |
| Wrong tool/skill | Agent used wrong approach, user redirected                     |
| Wasted work      | Agent produced output that was discarded                       |
| Hallucination    | Agent assumed facts not in evidence                            |

Output as timeline:

```markdown
## Issue Timeline

1. **[Turn N]** [Issue Type] (Impact: high/medium/low)
   [What happened and what the correct action was]
```

If no issues found, state that explicitly with reasoning.

## 3. Actionable Feedback

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
