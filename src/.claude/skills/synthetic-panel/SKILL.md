---
name: synthetic-panel
description: Screen product or UX concepts (value propositions, copy, feature ideas, screen mockups as images) with a synthetic panel of LLM personas, each answering in free text in its own isolated call, then rated on a 5-point scale and ranked. Use when the user wants to compare concept candidates or collect likely objections before testing with real people. Not a substitute for usability testing, human surveys, or any decision that needs absolute scores.
argument-hint: '<concepts to compare and who the target users are>'
allowed-tools: Bash, Read, Write
---

# Synthetic Panel

Rank concept candidates and surface objections with LLM personas: each persona answers in free text first, and a separate rater maps the text to the scale. Asking a persona for a number directly collapses answers to the scale midpoint.

Target: $ARGUMENTS. If empty, the concept files and target users named in the conversation.

Script: `${CLAUDE_SKILL_DIR}/scripts/panel.py` (`run`, `report`; `--help` for usage). Run it as is: its shebang starts `uv run --script`, and a plain `python3` cannot parse it. Work in the directory the user names, else the scratchpad directory.

## What the Result Can and Cannot Claim

Nothing here has been checked against human answers. State that the panel is synthetic and unvalidated in every result.

- Rankings and paired differences only. A synthetic mean is not a forecast of a human mean; synthetic means spread wider than human ones.
- Objections and reasons are hypotheses to test with real users, not findings.
- Weak where the model has seen little discussion of the domain (niche B2B workflows, internal tools). When the target is one, the answer says so and says that the ranking and objections are therefore weaker evidence than for consumer concepts.
- Subgroup differences are unreliable: age and income effects tend to carry over, gender and region do not.

## Flow

1. Concepts: one ID per candidate, each a text file, an image, or both (`--concept A=copy.md,mock.png`). Present every candidate at the same fidelity; a polished mockup against a one-line description measures the polish.
2. Panel facts from the user: who the target users are, and the attributes that plausibly drive the answer (for B2B: role, company size, current tool, pain points; for consumers: age, income, household, habits). When the user names no target segment, ask for it with the attributes you need, rather than inventing one. Once a segment is given, do not ask about the rest: those are the assumptions of step 3. If the user has real user data or a known distribution, draw personas from it.
3. Write `personas.jsonl`, one `{"id", "profile"}` per line, 30 or more. Knowing the product category, the medium, and the one attribute below is enough to write them; write them before studying the candidates' features further, so no other trait is tailored to one. Write each profile in the panel's language as a short third-person description with concrete specifics. Every attribute the user gave appears in every profile in the user's own words (a "dual-income household" segment means each profile states that both partners work), so grep the file for each one before running. Attributes the user did not give are assumptions: spread them across the panel and list them in the answer. First list what the candidates differ in by content (the skill, goal, or task each serves) and pick the user attribute that maps to that difference: for a conversation-practice app against a vocabulary app, wanting to speak against wanting a test score. Time, budget, or past dropouts are secondary. When the user did not give that attribute, spread its values evenly, and in the answer give the ranking within each value and name its real distribution as the first thing to check; this split is planned before the run, unlike the subgroup cuts warned against above. Personas without demographics give realistic-looking distributions but cannot tell concepts apart.
4. Question and scale: one question per run, about the action the user wants the concepts to win (buying, signing up, starting a trial, using), with five labels lowest first in the panel's language ("Definitely would not sign up" ... "Definitely would sign up"). Word it so it names no feature or task that only one candidate covers (asking whether they would use it "for ordering" favors the ordering feature). When the candidates differ in price, ask about the action, not purchase. State the chosen question in the answer, and when you stop to ask the user anything, propose the question and labels in the same message. Image concepts are shown to personas as images; say so when proposing. Use `--language` for the language personas reply in; the user's Claude Code language setting is excluded from persona calls.
5. `panel.py run ... --dry-run` prints the call count (two calls per persona and concept). Before running without `--dry-run`, tell the user the count, the model, and the cost estimate, and wait for their OK. When the user already set a cost ceiling and the estimate fits under it, that ceiling is the OK: report the numbers and run. Runs on Sonnet cost about 0.013 USD per persona and concept; before personas exist, estimate personas x concepts x 0.013 USD. Rerun the same command to retry failed pairs.
6. `panel.py report <out>` prints n, failures, mean, bootstrap 95% CI, and the distribution per concept, then paired differences between concepts over the same personas. Read `responses.jsonl` for the answers.

## Answer

- Ranking with the paired-difference CIs. Call two concepts indistinguishable when the CI of their difference includes 0. When the candidates differ in more than one respect (price and features), say beside the ranking that it compares each candidate as a whole and cannot credit any one difference. The CIs and the share of resamples measure variation across these synthetic personas only, not uncertainty about real users: a 100% share says nothing about how people would answer.
- Failed calls per concept, when any.
- Objections and appeal per concept, grouped by theme, each with one or two verbatim answers and the persona attributes behind it.
- What to test with real users next: the open questions the objections raise, and the concepts worth a human round.
- The panel size, model, and question, and that this is a synthetic, unvalidated panel.
