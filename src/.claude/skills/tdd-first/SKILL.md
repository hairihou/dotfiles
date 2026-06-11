---
name: tdd-first
description: Pin the expected outcome down as a failing test before writing production code. Use when a change alters observable behavior — new logic, a bug fix, a modified rule. Not for config, docs, or refactors that keep behavior identical.
---

# TDD First

A test written before the code records the requirement; a test written after tends to record whatever the code happens to do. Work in small cycles, one observable behavior per cycle.

## Cycle

1. Write the narrowest test that captures the next behavior, run it, and inspect the failure: the assertion itself must be what fails. A crash in setup, an unresolved import, or a typo means the cycle has not started yet
2. Make it pass with just enough production code — anything the test does not force stays out until a later cycle forces it
3. With the suite green, improve structure freely, introducing no new behavior while doing so

## Signals Worth Stopping For

- A brand-new test goes green on its first run: it captures nothing new — rework the test, not the plan
- You are tempted to adjust a failing test until it passes: legitimate only when the test itself encodes the requirement wrongly, and say so before touching it

## No Test Seam

When nothing in the harness can observe the behavior, say so and propose a manual verification plan rather than quietly dropping the discipline.
