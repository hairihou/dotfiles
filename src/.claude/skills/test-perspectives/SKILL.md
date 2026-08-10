---
name: test-perspectives
description: Use when writing or expanding tests for code with branching conditions, state transitions, input boundaries, or operational failure modes.
---

# Test Perspectives

Enumerate cases via established QA techniques before writing test code; without this step, AI-written tests skew to happy paths and miss boundaries, condition combinations, illegal transitions, and operational failures.

## Workflow

1. Pick the applicable techniques below — most code needs two or three, not all six
2. Enumerate concrete cases under one `## Test perspectives` heading, one subsection per applied technique, each a flat list or table (not prose)
3. Tie each case to the code that justifies it — a branch, transition, type, or constraint. If no such code can be located, do not invent the case; mark it `needs source verification`
4. Generate one test per case; name the test after the case, not the function under test
5. Re-read the enumeration; any case without a matching test is a gap

## Techniques

### Equivalence Partitioning

Group inputs into classes that should behave identically; pick one representative per class.

- Partition the input domain (numeric range, enum, string format, collection size) into valid and invalid classes
- State why the picked value represents its class

### Boundary Value Analysis

Test the edges of each partition where off-by-one and inclusive/exclusive errors live.

- Range `[min, max]`: `min - 1`, `min`, `min + 1`, `max - 1`, `max`, `max + 1`
- Collection size `N`: `0`, `1`, `N - 1`, `N`, `N + 1`
- Optional/nullable: present, absent, empty string, whitespace-only

### Decision Table

Use when output depends on a combination of 2+ conditions.

- Rows = conditions, columns = combinations, last row = expected output
- One test per column; mark impossible columns explicitly
- For short-circuit guards, mark unreachable downstream cells as `-` so impossible combinations are distinguishable from missed ones

| Condition      | C1  | C2  | C3  | C4  |
| -------------- | --- | --- | --- | --- |
| logged in      | Y   | Y   | N   | N   |
| has permission | Y   | N   | Y   | N   |
| → expected     | OK  | 403 | 401 | 401 |

### State Transition

Use for state machines, workflow steps, or any object with a lifecycle.

- For each `(state, event)` pair, state the next state or mark as forbidden
- Assert allowed transitions succeed and forbidden transitions are rejected

### Error Guessing

Failure patterns from production experience, not from the spec.

- Duplicate submission, double-click, retry after timeout
- Timezone, DST, locale differences
- `null` vs empty string vs whitespace vs missing key
- Concurrent writes to the same record
- Truncation at character vs byte vs grapheme boundary
- Clock skew, leap second, year boundary
- Network partial failure (request sent, response lost)

### Checklist by Surface Type

- **HTTP endpoint:** auth required, auth missing, auth wrong scope, malformed body, oversized body, unsupported content-type, idempotency, rate limit
- **Form input:** required missing, max length, min length, disallowed characters, paste of formatted text, browser autofill, double-submit
- **Background job:** retry on transient failure, dead-letter on permanent failure, idempotent on duplicate delivery, recovery after crash mid-run
- **Database write:** unique constraint, foreign key, transaction rollback, concurrent update conflict
- **External API call:** timeout, 4xx, 5xx, malformed response, schema drift

## When Not to Use

- No input partition, transition, or condition combination worth naming — typically trivial accessors and identity-like wrappers. Boundary-sensitive pure functions (clamp, normalize, parse-with-range) still warrant BVA even if syntactically single-branch
- Snapshot or golden-file tests asserting against a recorded baseline
- Property-based tests where the property covers the partition
- Hot fixes where the reproduction case is the only required test
