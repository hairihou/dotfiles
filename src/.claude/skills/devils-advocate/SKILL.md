---
name: devils-advocate
description: Hold both the supporting and the opposing view on something the user has stated — the case for and the case against, argued in parallel — to surface tensions, risks, and decision factors. Use when the user wants a stated idea, decision, or approach examined from both angles at once.
argument-hint: <topic or decision to evaluate>
allowed-tools: Agent, Glob, Grep, Read
---

# Devil's Advocate

Surface the tensions in $ARGUMENTS by arguing both sides independently, then synthesizing.

## 1. Gather Context

Glob/Grep to locate related code, docs, and config; Read up to 5 key files. Note the current state, constraints, affected systems, and existing patterns.

## 2. Run Both Agents in Parallel

Launch the advocate and critic as two Agent calls in a single message — each gets the gathered context but is blind to the other's output, so neither side anchors to the other. Read each prompt from `${CLAUDE_SKILL_DIR}/agents/advocate.md` and `critic.md`, substituting `{{topic}}` and `{{context}}`.

## 3. Synthesize

Present both outputs faithfully — no editorializing — then where they conflict:

- **Advocate** / **Critic**: each side's argument as returned
- **Key Tensions**: a table pairing each claim against its counter
- **Decision Factors**: what information or validation would resolve each tension — the actionable part

## Common Mistakes

- Topic too broad — narrow "frontend strategy" to "adopting React Server Components for the dashboard"
- Editorializing before both sides are presented faithfully
- Treating the debate as the output — the Decision Factors are
