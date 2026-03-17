---
name: devils-advocate
description: Use when evaluating a decision, challenging an approach, or weighing pros and cons of architecture/technology choices.
argument-hint: <topic or decision to evaluate>
allowed-tools: Agent, Glob, Grep, Read
---

# Devil's Advocate

Parallel advocate/critic analysis that surfaces tensions and decision factors for a given topic.

Topic: $ARGUMENTS

## 1. Gather Context

Search the codebase for code, documentation, and configuration related to the topic (Glob/Grep to locate, Read up to 5 key files). Identify:

- Current state and constraints
- Stakeholders and affected systems
- Prior art or existing patterns in the codebase

## 2. Run Parallel Sub-agents

Use the Agent tool to launch **both agents simultaneously in a single message** (two Agent tool calls in parallel). Each agent receives the gathered context but cannot see the other's output.

For each agent, read the prompt template from `${CLAUDE_SKILL_DIR}/agents/` and substitute `{{topic}}` and `{{context}}` with actual values.

| Agent    | Prompt file                              |
| -------- | ---------------------------------------- |
| Advocate | `${CLAUDE_SKILL_DIR}/agents/advocate.md` |
| Critic   | `${CLAUDE_SKILL_DIR}/agents/critic.md`   |

## 3. Synthesize

After both agents return, combine their outputs into the following format. Do not editorialize — present both sides faithfully, then identify where they conflict.

### Output Format

```markdown
## Advocate

[Advocate agent output — arguments in favor]

## Critic

[Critic agent output — arguments against, risks, alternatives]

## Key Tensions

| Advocate claims | Critic claims |
| --------------- | ------------- |
| [Position A]    | [Counter A]   |

## Decision Factors

[What information or validation would resolve each tension — actionable next steps]
```

## Common Mistakes

- Topic too broad (e.g., "frontend strategy" → narrow to "adopting React Server Components for the dashboard")
- Editorializing in synthesis — present both agents' outputs faithfully before identifying tensions
- Ignoring Decision Factors — the actionable next steps are the most valuable part, not just the debate itself
