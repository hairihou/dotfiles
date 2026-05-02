---
name: retrospect
description: Guide personal reflection by separating fact, interpretation, and emotion through structured inquiry. Use when "something feels off", "need to process this", "had a conflict", or decisions feel unclear. Not for technical decision analysis — use devils-advocate for that.
argument-hint: <event or situation>
disable-model-invocation: true
allowed-tools: AskUserQuestion
---

# Retrospect

## Skip gate

If the event occurred within the last ~24 hours, run only Steps 1-2 (Listen, Inquire on Fact and Emotion). Defer Interpretation and Integrate to a later session — fresh emotion distorts both interpretation accuracy and action choice.

## Steps

1. **Listen**: Understand the event
2. **Inquire**: Ask 1-3 questions to separate Fact / Interpretation / Emotion
   - Fact: "What exactly happened? What did you observe?"
   - Interpretation: "What meaning did you assign to it? What assumptions are you making?"
   - Emotion: "How did that make you feel? What was your gut reaction?"
3. **Deepen**: Clarify facts, surface assumptions, acknowledge emotions
   - Challenge interpretations: "Is there another way to read this situation?"
   - Validate emotions: "That reaction makes sense given your interpretation."
   - Name the bias if one fits (one sentence, no lecture):
     - **Confirmation bias** — only facts that support the initial reading are cited
     - **Hindsight bias** — past intent is described through current knowledge
     - **Fundamental attribution error** — the other person's action is attributed to character, not situation
4. **Integrate**: Summarize using the Output Format below and propose 1-2 concrete actions grounded in Facts only

## Output Format

```
[Facts] What a camera would record
[Interpretations] Meaning assigned, assumptions made
[Emotions] Reactions and their intensity
[Actions] 1-2 concrete next steps grounded in Facts only
```

## Common Mistakes

- Deriving Action from Interpretation rather than Fact — the Action will optimize for a story that may not be true
- Treating "I felt X because they did Y" as Fact — this is causal Interpretation; the Facts are "they did Y" and "I felt X" separately
- Skipping Emotion as "not the point" — unprocessed emotion leaks into Interpretation in the next session

## Guidelines

- Respond in user's language
- Facts and interpretations often blend; separate them gently

## Start

$ARGUMENTS
