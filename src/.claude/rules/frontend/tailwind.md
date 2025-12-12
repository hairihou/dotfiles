---
paths: "**/*.{component.ts,css,html,tsx,vue}"
---

# Tailwind CSS v4 Rules

## Critical: Removed Utilities

Never use these — they don't exist in v4:

| Deprecated          | Use Instead       |
| ------------------- | ----------------- |
| `bg-opacity-*`      | `bg-black/50`     |
| `text-opacity-*`    | `text-black/50`   |
| `border-opacity-*`  | `border-black/50` |
| `flex-shrink-*`     | `shrink-*`        |
| `flex-grow-*`       | `grow-*`          |
| `overflow-ellipsis` | `text-ellipsis`   |

## Critical: Renamed Utilities

Always use the v4 name:

| v3               | v4               |
| ---------------- | ---------------- |
| `bg-gradient-*`  | `bg-linear-*`    |
| `shadow-sm`      | `shadow-xs`      |
| `shadow`         | `shadow-sm`      |
| `drop-shadow-sm` | `drop-shadow-xs` |
| `drop-shadow`    | `drop-shadow-sm` |
| `blur-sm`        | `blur-xs`        |
| `blur`           | `blur-sm`        |
| `rounded-sm`     | `rounded-xs`     |
| `rounded`        | `rounded-sm`     |
| `outline-none`   | `outline-hidden` |
| `ring`           | `ring-3`         |

## Spacing

Use `gap-*` in flex/grid, never `space-x-*` or `space-y-*`:

```html
<!-- ❌ BAD -->
<div class="flex space-x-4">
  <!-- ✅ GOOD -->
  <div class="flex gap-4"></div>
</div>
```

Other spacing rules:

- Use `min-h-dvh` not `min-h-screen` (mobile Safari bug)
- Use `size-*` for equal width/height

## Typography

Always use line-height modifiers, never separate `leading-*`:

```html
<!-- ❌ BAD -->
<p class="text-base leading-7">
  <!-- ✅ GOOD -->
</p>

<p class="text-base/7"></p>
```

## Responsive

Only add breakpoint variants when values change:

```html
<!-- ❌ BAD - redundant -->
<div class="px-4 md:px-4 lg:px-8">
  <!-- ✅ GOOD -->
  <div class="px-4 lg:px-8"></div>
</div>
```

## Dark Mode

Light mode first, then `dark:` variants:

```html
<div class="bg-white dark:bg-black"></div>
```

## Gradients (v4)

```html
<!-- Linear -->
<div class="bg-linear-to-r from-blue-500 to-purple-500">
  <!-- Radial -->
  <div class="bg-radial from-white to-black">
    <!-- Conic -->
    <div class="bg-conic from-red-500 via-yellow-500 to-red-500"></div>
  </div>
</div>
```

## CSS Variables

Access theme values:

```css
.custom {
  background: var(--color-blue-500);
  padding: var(--spacing-4);
  /* or use --spacing() function */
  margin: calc(100vh - --spacing(16));
}
```

Extend theme:

```css
@theme {
  --color-brand: oklch(0.7 0.15 200);
}
```

## Avoid

- `@apply` — use CSS variables or components
- Arbitrary values — prefer design scale (`ml-4` not `ml-[16px]`)
