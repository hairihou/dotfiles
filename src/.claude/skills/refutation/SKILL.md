---
name: refutation
description: Verify a finished artifact by dispatching an independent skeptic that never saw it being made, tasked with refuting it, grounding every factual claim in a primary source, and reporting findings with severity and confidence. Use when a deliverable (document, plan, analysis, code change, decision) should be challenged rather than polished, above all one produced in the current session. Not for wording, style, or "does this look OK" passes.
argument-hint: <artifact path or description>
allowed-tools: Agent, Glob, Grep, Read, WebFetch, WebSearch
---

# Refutation

Verify $ARGUMENTS by refutation, not review.

A reviewer who holds the creation context cannot find the flaw the context conceals. Independence is the mechanism, so it is not optional: the skeptic runs as a subagent, or the run is worthless.

## 1. Isolate the Artifact

Identify what is under test and reduce it to what a stranger could read on its own: file paths, or the artifact text itself. If it exists only in conversation, write it to a working file first.

Pass nothing about how it came to be. No session history, no author intent, no "X was chosen because Y", no summary of your own. A summary carries the author's framing, which is the thing being tested.

## 2. Dispatch the Skeptic

One Agent call. Read the prompt from `${CLAUDE_SKILL_DIR}/agents/skeptic.md` and substitute `{{artifact}}`.

## 3. Present, Do Not Decide

Report the findings ordered by severity, each with its evidence and confidence as returned. Do not accept, dismiss, merge, or act on any of them, and do not edit the artifact. Adoption, partial adoption, and rejection are the user's call, and the findings are material for that call.

Where a finding is Low confidence, keep the skeptic's note on what would settle it. That is the next action if the user wants one.

## Common Mistakes

- Running the skeptic in the current context instead of a subagent, which yields self-review under another name
- Handing the skeptic a summary, or the rationale behind the artifact
- Fixing findings before the user has seen them
- Passing through a factual claim that cites no source consulted
