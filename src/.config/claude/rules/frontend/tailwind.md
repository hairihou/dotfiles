---
paths: "**/*.{component.ts,css,html,tsx,vue}"
---

# Tailwind CSS v4

## v4 Architecture (LLMs often get wrong)

- `tailwind.config.js` does not exist — all configuration lives in CSS
- Entry point is `@import "tailwindcss"`, not `@tailwind base/components/utilities`
- Custom utilities use `@utility`, not `@layer utilities { ... }` or `@layer components { ... }`
- Custom variants use `@custom-variant`, not plugin API
- Important modifier is trailing: `flex!`, not `!flex`
- CSS variable references use parentheses: `bg-(--brand)`, not `bg-[--brand]`
- Default border color is `currentColor`, not `gray-200` — always specify color explicitly
- Variant stacking reads left-to-right: `*:first:pt-0`, not `first:*:pt-0`

## Avoid

- `@apply` — use CSS variables or components
- Arbitrary values — prefer design scale (`ml-4` not `ml-[16px]`)

## CSS Variables

Access theme values:

```css
.custom {
  background: var(--color-blue-500);
  padding: var(--spacing-4);
  margin: calc(100vh - --spacing(16));
}
```

Extend theme:

```css
@theme {
  --color-brand: oklch(0.7 0.15 200);
}
```

## Dark Mode

Light mode first, then `dark:` variants:

```html
<div class="bg-white dark:bg-black"></div>
```

## Gradients

```html
<!-- Linear -->
<div class="bg-linear-to-r from-blue-500 to-purple-500"></div>

<!-- Custom angle -->
<div class="bg-linear-45 from-blue-500 to-purple-500"></div>

<!-- Radial -->
<div class="bg-radial from-white to-black"></div>

<!-- Conic -->
<div class="bg-conic from-red-500 via-yellow-500 to-red-500"></div>
```

## Responsive

Only add breakpoint variants when values change:

```html
<!-- NG - redundant -->
<div class="px-4 md:px-4 lg:px-8"></div>

<!-- OK -->
<div class="px-4 lg:px-8"></div>
```

## Spacing

Use `gap-*` in flex/grid, never `space-x-*` or `space-y-*`:

```html
<!-- NG -->
<div class="flex space-x-4"></div>

<!-- OK -->
<div class="flex gap-4"></div>
```

- Use `min-h-dvh` not `min-h-screen` (mobile Safari)
- Use `size-*` for equal width/height

## Typography

Always use line-height modifiers, never separate `leading-*`:

```html
<!-- NG -->
<p class="text-base leading-7"></p>

<!-- OK -->
<p class="text-base/7"></p>
```
