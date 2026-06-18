---
name: socratic
description: Interview the user one question at a time, each with a recommended answer where one is defensible, to turn a half-formed requirement or undecided approach into an implementation-ready design while the user keeps every decision. Use when unsettled decisions remain and the user signals they want to think a plan through together rather than have it built outright; also when they want their own plan pressure-tested decision-by-decision. Not for plain build requests, one-shot critique, parallel pro/con analysis, or rubber-stamping a finished plan.
argument-hint: <requirement or plan to interrogate>
allowed-tools: Glob, Grep, Read
---

# Socratic

Interrogate a requirement or plan until its shaping decisions are settled. The user leads — never hand them a finished plan to rubber-stamp.

Target: $ARGUMENTS — if empty, the requirement under discussion.

- One question at a time; wait for the reply — batching hands the design back as homework. Recommend an answer only where a defensible default exists, with the reason behind it; for a genuine judgment call, lay out the trade-off instead of a pick.
- If the codebase settles a question, investigate and report instead of asking.
- Go depth-first: settle each decision before the ones depending on it. Park questions needing a prototype or real data — name them and move on.

Stop when no open branch would change the implementation. Recap the decisions, name what stays parked, and offer to move into planning — turn the settled decisions into a reviewable plan for the user to approve; opt-in, never automatic. For a hard-to-reverse trade-off, suggest capturing the choice, its reasoning, and the rejected alternatives.
