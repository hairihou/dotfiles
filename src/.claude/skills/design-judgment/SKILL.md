---
name: design-judgment
description: Use when about to commit to a non-trivial design choice — picking an architecture, technology, abstraction layer, or extension point — or self-reviewing freshly generated code that introduces such structure.
---

# Design Judgment

## Overview

Decision Quality (DQ) treats a design choice as six elements — Frame, Alternatives, Information, Values, Sound Reasoning, Commitment — and the weakest one bounds overall quality. In practice, most design failures collapse to two issues: the wrong **dominant axis** for the current Frame, and unrecognized **anti-patterns** that follow from that mismatch.

This skill is the axis vocabulary plus the named patterns. Use it to spot the failure before committing code, right after an agent emits structure, or when a design discussion stalls without a clear reason. Skip for mechanical edits, single-function bug fixes, and changes following an established convention with no new design surface.

## Loop

1. **Frame**: state the decision in one sentence.
2. **Pick the dominant axis** — exactly one of the 8 below. Demote the rest to secondary conditions with explicit minimum thresholds.
3. **Scan the patterns** (`references/patterns.md`). If the draft matches one, check its "when deliberate" criteria. If they are not met, the draft itself **is** the failure.
4. **Commit explicitly**: record the dominant axis and the rejected alternatives so the next change can re-frame instead of inheriting silently.

## The 8 Evaluation Axes

| Axis | Reads as |
|------|----------|
| Purpose fit | Solves the actual user/business problem |
| Constraint fit | Satisfies functional + non-functional requirements |
| Feasibility (technical) | Works on the chosen stack |
| Feasibility (organizational) | THIS team can operate, maintain, evolve it |
| Quality impact | Effect on -ilities (maintainability, operability, evolvability, etc.) |
| Time effect | Cost now vs. cost later — read short and long horizons separately |
| Risk / uncertainty | What could break, with what probability and blast radius |
| Coherence | Fit with surrounding architecture, conventions, ADRs |
| Agreement | Stakeholders can commit to executing it |

Feasibility is one axis with two layers. SIer-style failures cluster around the organizational layer; pure-engineering teams more often miss the technical one.

## The 16 Anti-Patterns

Names only — full axis bias, examples, and "when deliberate" criteria live in `references/patterns.md`.

1. Reinventing the Wheel
2. Sledgehammer for a Nut
3. Design Beyond Org Capability
4. Skill-Fear Downgrade
5. Stopgap Fix
6. Premature Success ("Execution Hallucination")
7. Premature Implementation Start
8. Premature Abstraction
9. Constraints Bolted On
10. Over-Deference to Legacy
11. Acceptance Criteria in Name Only
12. Cross-Boundary Implementation
13. Best-Practice Imposition over Local Convention
14. Reimplementation Without Lookup
15. Hallucinated Dependency
16. Speculative Extension Point

## Notation in patterns.md

Each pattern lists its **axis bias** — how the decider has weighted each axis when arriving at the failing draft:

- `↑` overweighted
- `↓` underweighted
- `unobservable` — information needed to evaluate the axis is missing

The same axis can be split by horizon. `time(short)↑ / time(long)↓` reads as "overweighting short-term, underweighting long-term."
