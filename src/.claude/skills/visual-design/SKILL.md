---
name: visual-design
description: Carry a visual surface's structure in its layout instead of in text that names the structure, in boxes and lines drawn around it, or in decoration added for emphasis. Use when building or revising anything people look at, such as UI screens and components, dashboards, stories, artifacts, slides, and diagrams, alongside any chart or page-design skill that also applies, and when reviewing one just written. Not for prose documents, whose structure is their headings.
---

# Visual Design

What belongs together, what comes first, and what matters most are shown by proximity, alignment, order, and size or weight. Text that names that structure makes the reader read what they could already see. Visible text is for meaning the layout cannot carry.

## Removal Test

After composing, go through every piece of visible text that names or introduces something rather than being the content itself: eyebrows, captions, a `Label:` before a value, table column headers, step numbers, legends, helper text. Page titles and section headings are outside this test and stay visible. For each, picture the surface without it and name what a reader would then get wrong. Keep it only when you can name that error. Otherwise remove it, and if the grouping turns unclear, fix the grouping with spacing, alignment, order, or weight rather than restoring the text. Table column headers are judged as one row: keep the whole row when any column needs its header, and drop it only when every column reads on its own. In a table of records, some column almost always needs its header, so the row usually stays. When a narrow layout stacks each row into a block, the header row is gone, and each field's label is judged on its own like a `Label:` before a value.

### Errors That Justify Keeping Text

- A form control loses its visible label. A placeholder is not a label
- An input loses the format it requires (`MM/YY`), and its label does not state it
- A value loses its unit, its basis, or what it is compared against, and the value alone does not show it. When the source does not give that basis, leave it out and say so in the reply rather than inventing one
- Two groups that look alike differ in a way their content does not show

"It reads clearer" without a named error does not justify keeping text, and neither does a template that had a title in that spot.

## Separators

Separate groups with the lightest means that works, in this order: space, then a line, then a background fill. Each step adds something the reader has to look past, so move to the next only when you can name what a reader would misgroup without it.

- Space: the gap between groups is larger than every gap inside a group. Get this right before adding anything else
- Line: only where adjacent groups hold different kinds of information and space alone leaves the boundary unclear. Not between items of the same kind, except table rows, where one neutral rule per row (not alternating row fills) keeps a row's cells together across columns
- Background fill: only where lines would pile up, or one region must stand apart from the rest of the surface. Never inside another filled or bordered region

A template that boxes every section does not justify a box, and neither does a page background tinted only so white cards stand out against it, unless a design system in use sets that tint as the page background. With no design system in view, the tint fails.

## Emphasis

Size, weight, color, and decoration tell the reader what matters most. Spend them only where you can name what a reader would misread without them: which item matters, or what state it is in. Prefer the content itself to say it (a word, a status chip, whether an action is offered) before adding emphasis on top. Emphasis added so the surface looks designed carries no information and competes with the content.

### Decorations That Fail

- A stripe on one edge of a card, row, or panel (an edge thicker or in a different color than its other edges, which its siblings do not share) to mark it as important, current, or selected. When nothing else shows that state, such as the current item in a navigation list, mark the whole item with weight or a fill instead of one edge. A neutral divider every sibling has is a separator, not a stripe
- A rank, index, or step number set much larger, in a different color, or zero-padded ("01") to look editorial. When the order already shows it, the removal test drops it; when it stays, write it at the item's text size ("1. Title")
- A container restyled to draw attention or to tell states apart (a tinted fill, a colored border, a shadow), such as the one metric tile that needs action, or a "your turn" panel tinted while the "their turn" panel stays gray. When a word, a status chip, or whether an action is offered already shows the state, keep every container the same; color may tint that text, not the container
- The same emphasis repeated on every item of a list or table, so it no longer tells any item apart, such as a red chip on every row of a list that only holds overdue rows

A number set large stays when the number is itself the value the reader came to read, such as a metric, with its label beside it.

## Removing Text Is Not Removing Semantics

Assistive technology may still need what the removal test took off the screen. An icon-only control keeps its accessible name. Check this after the removal test, not in place of it.

## Reviewing Instead of Writing

Run the removal test against the diff, or against the whole surface when there is no diff. For each piece of text that fails it, report what in the layout already carries its meaning, or the layout change that would. Do the same for each border, divider, and filled container against the separator order, and for each enlarged, colored, or decorated element against Emphasis.
