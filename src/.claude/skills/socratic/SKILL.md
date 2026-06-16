---
name: socratic
description: Interview the user one question at a time, each with a recommended answer, to turn a half-formed requirement or plan into an implementation-ready design while the user keeps every decision. Use before implementation when the goal is clear but the decisions that shape it are not, or when the user wants their own plan pressure-tested decision-by-decision instead of handed a finished one. Not for one-shot critique, parallel pro/con analysis, or producing a plan to rubber-stamp.
argument-hint: <requirement or plan to interrogate>
allowed-tools: Glob, Grep, Read
---

# Socratic

Interrogate a requirement or plan until you and the user share an implementation-ready understanding. The user stays in the lead — this is the inverse of plan mode: never present a finished plan for rubber-stamping.

Target: $ARGUMENTS — if empty, interrogate the requirement or plan under discussion in the current conversation.

- Ask one question at a time; wait for the answer before the next. Batching hands the design back as homework.
- Give each question a recommended answer with a one-line reason. The user takes it, refines it, or rejects it.
- If the codebase already settles a question, investigate and report instead of asking.
- Walk the decision tree depth-first, settling each decision before the ones that depend on it.
- Park questions that need a prototype or real data — name them, set them aside, keep going.

Stop when no unresolved branch would change the implementation. Recap the decisions; don't drift into implementation. If a decision was hard to reverse and a real trade-off, suggest the decision-log skill.
