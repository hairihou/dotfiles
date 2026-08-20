---
name: tdd-first
description: Pin the expected outcome down as a failing test before writing production code. Use when a change alters observable behavior — new logic, a bug fix, a modified rule. Not for config, docs, or refactors that keep behavior identical.
---

# TDD First

A test written before the code records the requirement; a test written after tends to record whatever the code happens to do. Work in small cycles, one observable behavior per cycle.

## Cycle

1. Write the narrowest test for the next behavior and run it before any production code exists
2. Write just enough production code to pass it
3. Restructure with the suite green, adding no behavior

## Signals Worth Stopping For

- The failure is not the assertion — a crash in setup, an unresolved import, or a typo. The cycle has not started: fix the test and run it again before writing production code
- A brand-new test goes green on its first run: it captures nothing new — rework the test, not the plan
- You are tempted to adjust a failing test until it passes: legitimate only when the test itself encodes the requirement wrongly, and say so before touching it

## No Test Seam

When nothing in the harness can observe the behavior, say so and propose a manual verification plan rather than quietly dropping the discipline.
