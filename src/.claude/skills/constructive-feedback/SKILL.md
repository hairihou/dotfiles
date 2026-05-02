---
name: constructive-feedback
description: Transform harsh, vague, or emotionally charged feedback text into actionable form using the Situation-Behavior-Impact-Suggestion framework. Use when "sounds too harsh", "how should I say this", "draft feedback", or "rephrase this message".
argument-hint: <feedback content>
allowed-tools: AskUserQuestion
---

# Constructive Feedback

## Input

$ARGUMENTS

## Input gate

Before transforming, verify $ARGUMENTS contains a specific incident: when, where, observable behavior. If any are missing, use AskUserQuestion to extract them. Do not proceed with vague input — the SBI output will be hollow and the recipient cannot act on it.

## Transform

- Make vague points specific
- Replace emotional expressions with fact-based statements
- Add constructive suggestions

## Output Format

Respond in user's language.

```
[Situation] (when, where)
[Behavior] (observable action)
[Impact] (effect)

---

[Suggestion]
[Expected Outcome]
```

## Common Mistakes

- **Behavior contains interpretation** — "He doesn't care about the team" is interpretation. Behavior is what a camera would record: "joined 10-15 minutes after the scheduled start"
- **Impact is generic** — "affected the team" carries no information. State who, how many, what duration, what concrete cost
- **Suggestion is not actionable** — "be more committed" is not a change the recipient can make tomorrow. The suggestion must name the action and the trigger

## Example

**Input**: "He's always late to meetings and doesn't care about the team."

**Output**:

```
[Situation] In the last 3 weekly standups (Jan 6, 13, 20)
[Behavior] Joined 10-15 minutes after the scheduled start time
[Impact] Other members had to repeat context, reducing discussion time by ~30%

---

[Suggestion] Confirm the meeting time works, or agree on async updates if schedule conflicts
[Expected Outcome] Full participation from the start, more productive use of meeting time
```
