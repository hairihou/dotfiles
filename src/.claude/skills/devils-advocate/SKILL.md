---
name: devils-advocate
description: Examine a direction the user has already settled on from both sides at once, each side argued by an independent agent that sees neither the other nor the assessment forming in this conversation. Use before answering someone who presents a course as decided and asks whether to proceed — whether the answer taking shape is agreement or rejection, and above all when the course is the user's own and agreeing would cost nothing — to surface what it rests on and what would settle it. Not for an option still being floated, where no course has been chosen yet. Reports whichever side holds, including when only one does.
argument-hint: <topic or decision to evaluate>
allowed-tools: Agent
---

# Devil's Advocate

Agreement reached inside this conversation is worth little: the reasoning that led here also shapes what now looks convincing. Both examinations therefore run as separate agents that receive the proposal and the evidence, never this conversation's leaning. Independence is the mechanism, so it is not optional.

Whether to run is not decided by your own read of the proposal. An answer that already feels settled, in either direction, is the assessment under test — not a reason to skip.

## 1. Frame

Narrow $ARGUMENTS to one decidable proposition — "adopting React Server Components for the dashboard", not "frontend strategy". Then gather only what makes claims checkable: the files, config, and constraints against which a claim would be verified. Do not settle on a view while gathering, and do not carry one into the next step.

## 2. Dispatch

Launch both agents in a single message so neither anchors on the other, reading their prompts from `${CLAUDE_SKILL_DIR}/agents/advocate.md` and `critic.md` with `{{topic}}` and `{{context}}` substituted. What goes into `{{context}}` is the evidence, not any conclusion drawn from it, and both receive the same evidence — an asymmetry produced by feeding one side less is manufactured rather than found.

## 3. Report

Present each side as it was returned, without editorializing, then:

- **Key Tensions** — each claim paired against the counter that meets it
- **Decision Factors** — what would resolve each tension: a measurement, a document to read, a trial to run. This is the deliverable; the debate itself is not

When a side does not hold up, say so and stop pairing. Balance manufactured out of a one-sided result hides the answer that was already there. When both hold, the disagreement is real, and the factors are what break it.
