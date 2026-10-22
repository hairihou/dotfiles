---
name: visual-design
description: Carry a visual surface's structure in its layout instead of in text that names the structure. Use when building or revising anything people look at, such as UI screens and components, dashboards, stories, artifacts, slides, and diagrams, alongside any chart or page-design skill that also applies, and when reviewing one just written. Not for prose documents, whose structure is their headings.
---

# Visual Design

What belongs together, what comes first, and what matters most are shown by proximity, alignment, order, and size or weight. Text that names that structure makes the reader read what they could already see. Visible text is for meaning the layout cannot carry.

## Removal Test

After composing, go through every piece of visible text that names or introduces something rather than being the content itself: eyebrows, captions, a `Label:` before a value, step numbers, legends, helper text. Page titles and section headings are outside this test and stay visible. For each, picture the surface without it and name what a reader would then get wrong. Keep it only when you can name that error. Otherwise remove it, and if the grouping turns unclear, fix the grouping with spacing, alignment, order, or weight rather than restoring the text.

Errors that justify keeping text:

- A form control loses its visible label. A placeholder is not a label
- A value loses its unit, its basis, or what it is compared against, and the value alone does not show it
- Two groups that look alike differ in a way their content does not show

"It reads clearer" without a named error does not justify keeping text, and neither does a template that had a title in that spot.

## Removing Text Is Not Removing Semantics

Assistive technology may still need what the removal test took off the screen. An icon-only control keeps its accessible name. Check this after the removal test, not in place of it.

## Reviewing Instead of Writing

Run the removal test against the diff, or against the whole surface when there is no diff. For each piece of text that fails it, report what in the layout already carries its meaning, or the layout change that would.
