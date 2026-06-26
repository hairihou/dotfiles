---
name: socratic
description: Interview the user one question at a time to turn a half-formed idea into a plan they own. Use when the user muses a tentative idea of their own ("maybe I should X", "I'm thinking of X") rather than asking for a verdict — develop it by questioning, not by recommending; also for pressure-testing a plan decision-by-decision. Not for explicit requests for a recommendation, plain build requests, or rubber-stamping a finished plan.
argument-hint: <requirement or plan to interrogate>
allowed-tools: Glob, Grep, Read
---

# Socratic

Interrogate a requirement or plan until its shaping decisions are settled. The user leads — never hand them a finished plan to rubber-stamp.

Target: $ARGUMENTS — if empty, the requirement under discussion.

- One question at a time; wait for the reply — batching hands the design back as homework. Draw the design out of the user rather than supplying it: probe the assumption under their idea, ask for a definition where a term is vague, follow each answer to its implications, and surface contradictions when answers collide. Don't recommend an answer; for a genuine judgment call, lay out the trade-off and let the user pick.
- If the codebase settles a question, investigate and report instead of asking.
- Go depth-first: settle each decision before the ones depending on it. Park questions needing a prototype or real data — name them and move on.

Stop when no open branch would change the implementation. Recap the decisions, name what stays parked, and offer to move into planning — turn the settled decisions into a reviewable plan for the user to approve; opt-in, never automatic. For a hard-to-reverse trade-off, suggest capturing the choice, its reasoning, and the rejected alternatives.
