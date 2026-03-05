# Schema

## Input

- Working directory with `package.json` and lockfile
- No arguments required

## Output: Report

### Summary (required)

```markdown
| Metric          | Value                   |
| --------------- | ----------------------- |
| Verification    | Pass / Fail             |
| Vulnerabilities | <count> (<severity>)    |
| Major updates   | <count>                 |
| Minor updates   | <count>                 |
| Patch updates   | <count>                 |
```

### Notable Changes (required)

Per package with major or investigated minor update:

```markdown
#### <package-name>: <old-version> → <new-version> (<major|minor>)

- **Breaking changes:** <list or "None">
- **Migration required:** Yes / No
- **Usage in project:** <grep results summary>
- **Source:** <changelog URL>
```

### Other Updates (required)

```markdown
| Package | Old | New | Type  |
| ------- | --- | --- | ----- |
| <name>  | x.y | x.z | patch |
```

### Security Audit (required)

```markdown
| Severity | Package | Advisory | Fix |
| -------- | ------- | -------- | --- |
```

If no vulnerabilities: "No vulnerabilities found."

### Verification Results (required)

Per script run (lint, typecheck, test, build):

```markdown
- **<script>**: Pass / Fail
  - [If fail: error summary]
```

### Conclusion (required)

```markdown
**Status:** Ready to merge / Needs attention

**Action items:**
- [ ] <specific action>
```
