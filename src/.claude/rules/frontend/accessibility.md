---
paths: ["**/*.{component.ts,css,html,tsx,vue}"]
---

# Accessibility

Target WCAG 2.2 AA with margin, not at the threshold. A number given here overrides; anything unstated falls back to WCAG 2.2 AA.

## Philosophy

- The goal is to benefit as many people as possible — not to clear the bar minimally or to exploit its exemptions
- The author does not get to decide what is "decorative". Every viewer has an equal right to perceive what is on screen, so every visible element meets the contrast floor regardless of whether it reads as text or decoration
- WCAG exemptions were written against 2008-era browser, assistive-tech, and bandwidth limits — do not cite an exemption to justify a lower bar today

## Enforced Deltas

Model defaults reliably violate the rules below. Judge contrast on the final rendered result in both light and dark themes, accounting for `opacity`, `rgba()` / `hsla()`, and `filter: opacity()` compositing.

### Contrast

- Body text against its background: at least 7:1
- Secondary / annotation text: at least 4.5:1, and lower contrast than body — express priority through contrast, not font size. Defaults ship ~3:1 muted grays, which fail even bare AA
- Non-text (borders, dividers, icons, UI component edges, focus rings): at least 3:1. Defaults ship ~1.2–1.6 hairlines, invisible to low-vision users
- Text over an accent or colored fill must also clear its text threshold

### Font Size

- Set font-size in `rem`, not `px`, so it honors the user's default font-size preference — `px` only responds to page zoom, ignoring the root setting
- Body and annotations at least 0.875rem (14px at the default root)
- Headings larger than body — except extension `popup.html`, where a heading may match body size

### Banned By Default

- No `opacity` or alpha to de-emphasize text or borders — it lowers effective contrast; use a solid color that meets the ratio
- No auto-dismissing toast or snackbar — render the result inline, or give a persistent close control the user dismisses
- No autoplay, auto-scroll, or carousel without an always-available stop control

## CSS Variables

- Do not share one token between a decorative divider/background and a UI component border/indicator — only the latter carries the 3:1 floor
- A decorative border that cannot reach 3:1 should be removed, not kept faint

## Handled By Defaults

Current models already satisfy these; re-check only on regression: native semantics (`<button>` for actions, `<a>` for navigation, never `<div>`/`<span>` controls), native form controls over `contenteditable`, an `<input type="file">` alongside any drop area, retained focus indicators (no bare `outline: none`), and link underlines kept on hover.
