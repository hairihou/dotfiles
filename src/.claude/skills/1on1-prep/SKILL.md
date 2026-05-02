---
name: 1on1-prep
description: Prepare for 1on1 meetings using a Psychological Safety x Responsibility framework. Use when preparing for a 1on1, noticing behavioral changes, or planning a difficult conversation with a report.
argument-hint: "[member-name]"
disable-model-invocation: true
allowed-tools: AskUserQuestion, Glob, Grep, Read
---

# 1on1 Prep

Structured 1on1 preparation using the **Psychological Safety x Responsibility** 4-zone framework.

Core principle: 1on1 is a diagnostic tool — assess the zone first, then adapt your approach accordingly.

**Scope:** One member at a time. Not for team-wide assessment.

Framework details: `${CLAUDE_SKILL_DIR}/references/framework.md`

## Skip gate

After Step 1, if the manager answered "nothing notable" to 3 or more of the 5 questions, propose skipping the 1on1 or converting it to a 15-minute async check-in. A 1on1 with no observations to discuss degrades into status update theater and erodes the channel.

## Process

### Step 1: Gather Observations

Ask the manager (via AskUserQuestion) about recent observations:

1. "How has their communication style changed recently?" (tone in reviews, meetings, Slack)
2. "What's their current workload like? Any deadline pressure?"
3. "Are they taking on new challenges or staying in familiar territory?"
4. "How do they respond to feedback or ambiguity?"
5. "Have they expressed frustration, boredom, or disengagement?"

If the manager struggles to answer, point them at the Objective Data Sources table in the framework reference and ask them to scan one source at a time.

### Step 2: Zone Assessment

Read the framework reference and map observations to a zone using the assessment decision flow.

**Handling mixed signals:** Use the **dominant signal** rule:

- Identify which axis (Safety or Responsibility) has clearer evidence
- Prioritize the zone with higher risk (Anxiety > Apathy > Comfort > Learning)

When genuinely ambiguous, start the 1on1 with open-ended questions from both candidate zones.

### Step 3: Zone-Specific Strategy

Read the framework reference and apply the strategy, key questions, and 1on1 approach for the assessed zone.

### Step 4: Generate Agenda

Output a structured 1on1 agenda:

```markdown
## 1on1 Agenda: <member-name> — <date>

**Assessed zone:** <zone-name> (<Safety level> x <Responsibility level>)
**Basis:** <2-3 specific observations that led to this assessment>

### Opening (5 min)

- "<zone-appropriate opening question>"

### Core Discussion (15 min)

- "<question 1 from zone strategy>"
- "<question 2 from zone strategy>"
- "<question 3, optional>"

### Action Items

- [ ] **Manager:** <concrete action with deadline>
- [ ] **Manager:** <concrete action with deadline>
- [ ] **<member-name>:** <concrete action with deadline>

### Follow-up

- <next check-in type and timing>
- <next full 1on1 timing — shorter for Anxiety/Apathy>
```

Example output: see `${CLAUDE_SKILL_DIR}/references/framework.md` (bottom section).

## Anti-patterns

- **Advice mode** — manager talks more than the report. Track question-to-statement ratio in the agenda; if it skews toward statements, rebalance
- **Skipping the prior action items** — never open without checking what was committed to last time. Silent drops corrode trust faster than missed deadlines
- **Zone-strategy mismatch** — opening with a Learning-zone question ("what stretch are you taking?") when the report is in Anxiety zone reads as oblivious. Match the question to the assessed zone, not to the manager's preferred mode
- **Treating the agenda as a script** — if the report opens with something urgent, abandon the agenda. The framework guides preparation, not execution
