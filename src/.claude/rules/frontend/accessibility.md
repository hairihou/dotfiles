---
paths: ["**/*.component.ts", "**/*.{css,html,tsx,vue}"]
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
- No hand-authored focus ring, and no `outline: none` / `outline: 0` to suppress the UA one — the UA ring (`outline-style: auto`) adapts to background, dark mode, and forced-colors; a fixed replacement adapts to neither of the first two, and a `box-shadow`-only ring is dropped in forced-colors. The 3:1 floor above then becomes yours to hold. Adjusting `outline-offset` is not suppression, and a rounded `overflow: hidden` container clipping the ring's outer band is acceptable — restructuring to avoid it is not
  - For a custom checkbox / radio / switch, style the native control itself with `appearance: none` rather than hiding it behind a proxy element; only where the control must stay visually hidden, carry the ring on the proxy via `:has(:focus-visible)`
  - Only where the UA ring itself measures below 3:1 against the actual background (Safari draws a single accent-color ring, ~2.1:1 on most backgrounds), author a two-tone `outline` plus `box-shadow` ring, with the `outline` carrying the contrast in forced-colors

## CSS Variables

- Do not share one token between a decorative divider/background and a UI component border/indicator — only the latter carries the 3:1 floor
- A decorative border that cannot reach 3:1 should be removed, not kept faint
