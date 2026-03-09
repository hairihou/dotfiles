---
name: session-insights
description: Analyze the current conversation for inefficiencies and improvement opportunities. Use when "how did this session go", "what went wrong", "what could I have done better", or reviewing session quality. Not for personal reflection — use retrospect. Not for logging work — use diary.
disable-model-invocation: true
allowed-tools: Glob, Grep, Read
---

# Session Insights

Analyze the current conversation session and produce an improvement report.

Taxonomy and classification reference: `${CLAUDE_SKILL_DIR}/references/taxonomy.md`

## 1. Session Overview

Assess the session and output:

```markdown
## Session Overview

| Metric       | Value                                 |
| ------------ | ------------------------------------- |
| Category     | <one from taxonomy reference>         |
| Session Size | <XS/S/M/L/XL from taxonomy reference> |
| Turns        | <integer>                             |
| Tools Used   | <comma-separated list>                |
| Skills Used  | <comma-separated list, or "None">     |
```

## 2. Issue Timeline

Scan the conversation for issue types from taxonomy reference.

Output as timeline:

```markdown
## Issue Timeline

1. **[Turn <N>]** <Issue Type from taxonomy reference> (Impact: high/medium/low)
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

- Most valuable for longer sessions (16+ turns) where patterns emerge
- Be specific — cite conversation turns, not vague observations
- Focus on actionable improvements, not praise
- L/XL sessions deserve deeper analysis
- For XS/S sessions with no issues, keep the report brief
