---
name: devils-advocate
description: Run advocate and critic subagents in parallel for design decisions. Use when asked to "evaluate a decision", "devils advocate", "challenge this approach", or when making architecture/technology choices that need structured critical analysis.
argument-hint: <topic or decision to evaluate>
---

# Devil's Advocate

Topic: $ARGUMENTS

## 1. Gather Context

Read relevant code, documentation, and configuration to understand the decision space. Identify:

- Current state and constraints
- Stakeholders and affected systems
- Prior art or existing patterns in the codebase

## 2. Run Parallel Sub-agents

Use the Task tool to launch **both agents simultaneously in a single message** (two Task tool calls in parallel). Each agent receives the gathered context but cannot see the other's output.

### Advocate Agent

```
subagent_type: general-purpose
prompt: |
  You are an advocate for the following proposal. Build the strongest possible case IN FAVOR.

  Topic: <topic>
  Context: <gathered context>

  Provide:
  - Core arguments why this is the right approach
  - Concrete benefits with evidence from the codebase or industry practice
  - Success scenarios and enabling conditions
  - Why alternatives are weaker

  Be specific, not generic. Ground arguments in the actual codebase and constraints.
  Respond in Japanese.
```

### Critic Agent

```
subagent_type: general-purpose
prompt: |
  You are a critic of the following proposal. Build the strongest possible case AGAINST.

  Topic: <topic>
  Context: <gathered context>

  Provide:
  - Risks and failure scenarios with concrete consequences
  - Stronger alternatives with trade-off comparison
  - Hidden assumptions the proposal relies on
  - What would need to be true for this to fail

  Be specific, not generic. Ground arguments in the actual codebase and constraints.
  Respond in Japanese.
```

## 3. Synthesize

After both agents return, combine their outputs into the following format. Do not editorialize — present both sides faithfully, then identify where they conflict.

## Output Format

```markdown
## Advocate

[Advocate agent output — arguments in favor]

## Critic

[Critic agent output — arguments against, risks, alternatives]

## Key Tensions

[Where advocate and critic directly contradict each other, listed as pairs]

## Decision Factors

[What information or validation would resolve each tension — actionable next steps]
```
