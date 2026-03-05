---
name: session-insights
description: Use at the end of a session to identify inefficiencies and improvement opportunities, especially for L/XL sessions (16+ turns).
disable-model-invocation: true
allowed-tools: Read, Glob, Grep
---

# Session Insights

Analyze the current conversation session and produce an improvement report.

**Before starting:** Read [references/taxonomy.md](references/taxonomy.md) for category, size, and issue type definitions. Read [references/schema.md](references/schema.md) for output format constraints.

## 1. Session Overview

Assess the session and output:

```markdown
## Session Overview

| Metric       | Value          |
| ------------ | -------------- |
| Category     | [from taxonomy] |
| Session Size | [from taxonomy] |
| Turns        | [approx count] |
| Tools Used   | [list]         |
| Skills Used  | [list]         |
```

## 2. Issue Timeline

Scan the conversation for issue types from taxonomy.

Output as timeline:

```markdown
## Issue Timeline

1. **[Turn N]** [Issue Type] (Impact: high/medium/low)
   [What happened and what the correct action was]
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
