---
name: socratic
description: Interview the user one question at a time to turn a fuzzy requirement or plan into a precise, implementation-ready design, keeping the user in the lead. Use before implementation when requirements are underspecified, or when the user wants a plan challenged decision-by-decision.
argument-hint: <requirement or plan to interrogate>
allowed-tools: Glob, Grep, Read
---

# Socratic

Interrogate a requirement or plan until you and the user share an implementation-ready understanding. The user stays in the lead — this is the inverse of plan mode: never present a finished plan for rubber-stamping.

Target: $ARGUMENTS

- Ask one question at a time; wait for the answer before the next. Batching hands the design back as homework.
- Give each question a recommended answer with a one-line reason. The user takes it, refines it, or rejects it.
- If the codebase already settles a question, investigate and report instead of asking.
- Walk the decision tree depth-first, settling each decision before the ones that depend on it.
- Park questions that need a prototype or real data — name them, set them aside, keep going.

Stop when no unresolved branch would change the implementation. Recap the decisions; don't drift into implementation. If a decision was hard to reverse and a real trade-off, suggest the decision-log skill.
