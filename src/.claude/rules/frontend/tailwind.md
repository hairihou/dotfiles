---
paths: ["**/*.component.ts", "**/*.{css,html,tsx,vue}"]
---

# Tailwind

## Syntax Deltas from v3

- Important modifier is trailing: `flex!`, not `!flex`
- CSS variable references use parentheses: `bg-(--brand)`, not `bg-[--brand]`
- Default border color is `currentColor`, not `gray-200` — always specify color explicitly
- Variant stacking reads left-to-right: `*:first:pt-0`, not `first:*:pt-0`
- Gradients are `bg-linear-*` / `bg-radial` / `bg-conic`, not `bg-gradient-to-*`

## Avoid

- `@apply` — use CSS variables or components
- Arbitrary values — prefer design scale (`ml-4` not `ml-[16px]`)

## Spacing

Use `gap-*` in flex/grid, never `space-x-*` or `space-y-*`:

```html
<!-- Bad -->
<div class="flex space-x-4"></div>

<!-- Good -->
<div class="flex gap-4"></div>
```

- Use `min-h-dvh` not `min-h-screen` (mobile Safari)
- Use `size-*` for equal width/height

## Typography

Always use line-height modifiers, never separate `leading-*`:

```html
<!-- Bad -->
<p class="text-base leading-7"></p>

<!-- Good -->
<p class="text-base/7"></p>
```
