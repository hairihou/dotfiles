---
name: humanizer
description: Remove AI-generated writing patterns from text and re-inject natural human voice. Use when prose feels machine-written — significance inflation, em-dash overuse, sycophantic tone, formulaic structure — typically after generating drafts or when reviewing AI-assisted writing. Triggered also by "humanize" or "remove AI-ness".
model: haiku
allowed-tools: Read
---

# Humanizer

Identify and remove AI-generated writing patterns, then inject human voice. Two-pass process: pattern removal, then anti-AI audit.

## When NOT to humanize

Skip the rewrite for text where formality and predictability are features, not bugs:

- Legal, compliance, security advisories — readers scan for known phrases
- Error messages and CLI output — terseness and parallel structure aid grep and triage
- API reference docs — consistency across endpoints outweighs voice
- Localized strings bound to translation memory — voice changes break TM matches

If the input is one of these, return the original with a one-line note instead of rewriting.

## Severity (apply in this order)

A heavy rewrite can damage meaning. Fix in priority order; stop when the text reads human enough.

1. **Content patterns (#1-6)** — these distort meaning, not just register. Always fix
2. **Language and Style patterns (#7-18)** — tone tells. Fix all that appear
3. **Communication and Filler (#19-25)** — atmosphere. Fix when they remain after passes 1-2

## Patterns to detect and fix

### Content

1. **Significance inflation** — "pivotal moment", "enduring testament", "vital role", "indelible mark". Remove grandiose framing; state facts plainly.
2. **Notability name-dropping** — Listing media outlets without context. Replace with one specific, sourced claim.
3. **Superficial -ing analysis** — "highlighting...", "underscoring...", "symbolizing...", "reflecting...". Delete the dangling participle phrase; if the point matters, make it its own sentence.
4. **Promotional language** — "groundbreaking", "nestled", "vibrant", "breathtaking", "renowned", "stunning". Replace with specific, verifiable descriptions.
5. **Vague attributions** — "Experts believe", "Industry observers note". Name the source or delete.
6. **Formulaic challenges** — "Despite challenges... continues to thrive", "Future outlook". Replace with specific facts about what happened.

### Language

7. **AI vocabulary** — Additionally, crucial, delve, enhance, foster, garner, intricate, landscape (abstract), pivotal, showcase, tapestry (abstract), testament, underscore, valuable. Replace with plain words.
8. **Copula avoidance** — "serves as", "stands as", "functions as", "boasts". Use "is", "are", "has".
9. **Negative parallelism** — "It's not just X; it's Y". Simplify.
10. **Rule of three** — Forced triplets. Break the pattern; use the number that fits.
11. **Synonym cycling** — Rewriting the same concept with different words across sentences. Say it once.
12. **False ranges** — "from X to Y" where X and Y are not on a meaningful scale. List items directly.

### Style

13. **Em dash overuse** — Replace with commas, periods, or parentheses.
14. **Boldface overuse** — Remove mechanical bold from terms that do not need emphasis.
15. **Inline-header lists** — "- **Speed:** description". Convert to prose or plain list items.
16. **Title case headings** — Use sentence case.
17. **Emoji decoration** — Remove decorative emojis from headings and lists.
18. **Curly quotes** — Normalize to straight quotes for consistency.

### Communication

19. **Chatbot artifacts** — "I hope this helps!", "Let me know if...", "Here is a...". Remove.
20. **Knowledge-cutoff disclaimers** — "As of [date]", "While specific details are limited...". Remove or replace with sourced facts.
21. **Sycophantic tone** — "Great question!", "You're absolutely right!". Remove.

### Filler and hedging

22. **Filler phrases** — "In order to" → "To". "Due to the fact that" → "Because". "It is important to note that" → delete.
23. **Excessive hedging** — "could potentially possibly might". Pick one qualifier or remove all.
24. **Generic conclusions** — "The future looks bright", "Exciting times lie ahead". End with a specific fact or plan.
25. **Hyphenated compound overuse** — "cross-functional", "data-driven", "end-to-end" used uniformly. Vary or drop hyphens where meaning is clear.

## Adding voice

Pattern removal alone produces sterile text. After cleaning, check for:

- **Uniform sentence length** — Vary rhythm. Short sentences. Then longer ones.
- **Missing opinions** — React to facts, not just report them.
- **Missing first person** — Use "I" when it fits.
- **Missing uncertainty** — "I genuinely don't know" is more human than listing pros and cons neutrally.
- **Missing personality** — Let humor or edge in where appropriate.

## Process

1. Read the input text
2. Identify all pattern instances from the list above
3. Rewrite, preserving meaning and intended tone, applying severity order
4. Add voice where the text feels sterile
5. Re-scan against the full pattern list above and fix remaining matches
6. Present the final version with a brief summary of changes

## Output modes

Default: emit the rewritten text only. If the user asks for a diff, emit per-paragraph before/after blocks tagged with the pattern numbers that triggered each rewrite — useful when the user is learning to spot patterns rather than fixing one piece.

## Common Mistakes

- **Over-rewriting domain terms** — "underscore" in financial writing or "delve" in academic prose may be the genre's register, not AI residue. Check the source domain before flattening
- **Replacing all em dashes** — em dash overuse is the signal, not the dash itself. A single em dash in a 500-word piece is fine; the rule fires on density, not presence
- **Adding fake voice** — injecting "honestly," / "to be clear," / first-person reactions where the original was deliberately neutral makes the text sound performative. Voice is a fix, not a flourish
