# Schema

## Input

- Current conversation session (implicit context)
- No arguments required

## Output: Analysis Report

### 1. Session Overview (required)

```markdown
| Metric       | Value                                          |
| ------------ | ---------------------------------------------- |
| Category     | <one from taxonomy>                            |
| Session Size | <XS/S/M/L/XL from taxonomy>                   |
| Turns        | <integer>                                      |
| Tools Used   | <comma-separated list>                         |
| Skills Used  | <comma-separated list, or "None">              |
```

### 2. Issue Timeline (required — always include section header)

Per issue:

```markdown
1. **[Turn <N>]** <Issue Type from taxonomy> (Impact: high/medium/low)
   <What happened> → <What the correct action was>
```

If no issues: "No issues identified. <one-sentence reasoning why session was efficient>"

### 3. Actionable Feedback (required)

Each subsection is optional but at least one must be present:

- **Improved Prompt**: rewritten initial request + list of changes with rationale
- **CLAUDE.md / Rules**: specific rule text + target file path
- **Skill Feedback**: skill name + problem + improvement, or "Missing skill" + description

### 4. Knowledge Usage (required)

```markdown
### Applied
- <rule/instruction> — <how it helped>

### Missed
- <rule/instruction> — <when it should have been applied>

### Misleading
- <rule/instruction> — <what went wrong, consider updating>
```

Each category may be empty with "None" if not applicable.
