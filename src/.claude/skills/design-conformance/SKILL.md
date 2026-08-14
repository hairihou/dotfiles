---
name: design-conformance
description: Make new UI look like it belongs in the product that already exists: read the design tokens and components the codebase declares, or where nothing is declared, the conventions its existing screens already follow, and compose within them instead of introducing a fresh aesthetic. Use when adding to or revising a surface that ships beside other screens, and when reviewing UI just written for values invented outside the system. Not for greenfield work where a distinctive, one-off look is the point, not when the brief asks for a new look rather than a consistent one, and not for a codebase that has no UI yet.
---

# Design Conformance

A screen is judged next to its neighbors, not on its own. The work is to find what the codebase has already decided and compose inside it.

The design system here means whatever the codebase treats as its source of design decisions: a token file, a theme object, the dependency those are pulled from, or, failing all of that, the screens already shipped.

## Read Before Writing

Three reads, then state what they returned:

1. The design tokens the codebase declares, if it declares any, following the import out to the package that defines them
2. The nearest existing screen of the same kind as the one you are about to build
3. The components already available for the parts you are about to build, including those a design-system dependency provides

State the result as a plain sentence naming the files: where the tokens are defined, which screen you read, which components you will reuse.

## Which Case Applies

**Declared.** Follow the declaration. Read it far enough to learn which parts are generated and must not be hand-edited. Where the screen you read departs from the declaration, the declaration wins and the departure is a gap to report, not a precedent to copy.

**Nothing declared, but screens exist.** This is the common case. Entering it requires the same naming as the reads: say where you looked for a declaration and what you looked for, so that finding none is distinguishable from missing it. Then derive the conventions the existing screens already follow — the spacing values that recur, the colors that recur, the way a page is put together — then say what you derived before using it. A single screen is a precedent rather than a rule: follow it, and say it was the only sample you had, instead of generalizing from it.

**No UI at all.** Say that there is nothing to conform to, and stop. Do not design your way out of it.

Do not write the derivation into the repo. Say it in your response; a conventions document nobody asked for is a separate deliverable.

## Where the System Has No Answer

The system will not answer every question you have. These are the four moments where an answer gets invented instead. The diff shows the invented value but not the context that judges it:

- **The value you want is not in the set.** Take the existing one whose role matches, or report the gap. A one-off value defined for this screen alone is how a token set stops meaning anything
- **A component already exists for what you are building.** Use it. Rebuilding it out of primitives produces something that looks close and behaves differently
- **A token name is read as a color rather than a role.** A name that means error belongs on errors. Reaching for the one whose shade happens to fit puts a meaning on the screen that you did not intend
- **Everything conforms and it still does not match.** Tokens are necessary, not sufficient. Compare against the screen you read and find what differs

Conformance does not outrank a floor that applies on its own. Where matching the neighbor would put contrast, hit area, or focus visibility below what is required, report the conflict rather than matching.

## Reviewing Instead of Writing

The same three reads, run against the diff rather than your own output. A finding is a value or a component the system already answers for, answered differently here. Report where the system's answer lives, not only that one exists.

## Before Calling It Done

Each of these should be answerable with yes, against the files:

- Can you name where each color, spacing, and type value came from?
- Does every value you used belong to the system, rather than being introduced by this screen?
- Did you confirm that nothing you built already exists in the system?
- Held next to the screen you read, can you give a reason for every difference?
- Did every gap you worked around get reported?

## Maintenance

This skill is a procedure, not a catalogue of bad output. Do not add a list of patterns to avoid: a list catches only what is on it, and the patterns worth listing turn over faster than the list does. When something slips through, ask whether a step here would have caught it, not whether a step covers the topic; only when no step would have caught it, rewrite that step — replace the sentence rather than appending to it.
