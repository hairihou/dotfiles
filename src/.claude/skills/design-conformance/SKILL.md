---
name: design-conformance
description: Make new UI look like it belongs in the product that already exists: read the design tokens and components the codebase declares, or where nothing is declared, the conventions its existing screens already follow, and compose within them instead of introducing a fresh aesthetic. Use when adding to or revising a surface that ships beside other screens, and when reviewing UI just written for values invented outside the system. Not for greenfield work where a distinctive, one-off look is the point, and not for a codebase that has no UI yet.
---

# Design Conformance

A screen is judged next to its neighbors, not on its own. The work is to find what the codebase has already decided and compose inside it — the interesting choices were made before you arrived.

## Read Before Writing

Three reads, then say out loud what they returned:

1. The token and component declaration the codebase makes, if it makes one
2. The nearest existing screen of the same kind as the one you are about to build
3. The components that already exist for the parts you are about to build

State the result as a plain sentence naming files and names: which file the tokens came from, which screen you read, which components you will reuse. The statement has to be checkable against the repo, which is what keeps it honest — you cannot write it without having read.

## Which Ground You Are On

**Declared.** Follow the declaration. Read it far enough to learn which parts are generated and must not be hand-edited.

**Nothing declared, but screens exist.** This is the common case. Derive the conventions the existing screens already follow — the spacing values that recur, the colors that recur, the way a page is put together — then say what you derived before using it.

**No UI yet.** Say that there is nothing to conform to, and stop. Do not design your way out of it.

Two ways the middle case goes wrong:

- Deriving a convention from a single sample. Convention means repetition; one screen is an example. If nothing recurs, say so and treat it as the third case
- Reporting the derivation as a repo file. Say it in your response. Writing a conventions document nobody asked for is a separate deliverable

## Where It Actually Breaks

The system will not answer every question you have. These are the four moments where an answer gets invented instead, and none of them are visible in a diff:

- **The value you want is not in the set.** Take the nearest one that exists, or report the gap. A one-off value defined for this screen alone is how a token set stops meaning anything
- **A component already exists for what you are building.** Use it. Rebuilding it out of primitives produces something that looks close and behaves differently
- **A token name is read as a color rather than a role.** A name that means error belongs on errors. Reaching for it because the shade is right puts a meaning on the screen that you did not intend
- **Everything conforms and it still does not match.** Tokens are necessary, not sufficient. Compare against the screen you read and find what differs

## Before Calling It Done

Answerable yes or no, against files:

- Can you name where each color, spacing, and type value came from?
- Is there a value in your output that appears nowhere else in the codebase?
- Did you build anything the repo already has?
- Held next to the screen you read, does anything differ that you cannot give a reason for?
- Did every gap you worked around get reported, or did one get quietly filled?

## Maintenance

This skill is a procedure, not a catalogue of bad output. Do not add a list of patterns to avoid: measured against real generated output, such lists mostly name failures that no longer happen, and a list catches only what is on it. When something slips through, first check whether a step here already covers it, and if it does, change nothing. Only when no step explains the miss, rewrite that step — replace the sentence rather than appending to it.
