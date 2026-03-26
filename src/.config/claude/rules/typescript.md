---
paths: "**/*.{ts,tsx,vue}"
---

# TypeScript Rules

Applies to all TypeScript code, including `<script>` blocks in Vue SFC. Follow project linter config when present; these rules supplement it.

## Prohibited Patterns

- `any` → use `unknown` and narrow
  - Exception: generic function bodies where TypeScript cannot infer correctly
- `as` type assertion → use type guards or `satisfies`
  - Exception: `as const`, unavoidable DOM casts (`as HTMLInputElement`), library `.d.ts` that lacks generics or returns `any`/`object`
- `enum` → use `as const` objects (see Naming Conventions)
- `!` (non-null assertion) → use type guards or restructure
  - Exception: test code where the value is guaranteed by setup
- Fire-and-forget promises → always `await` or return; if intentionally discarding, use `void someAsyncFn()`
- Bare `if (value)` for nullish checks → use `value !== undefined` or `value !== null`; boolean types allow truthy checks; `if (name)` on `string` allowed only when excluding empty string is intentional
- `!!value` → allowed only for coercing union with multiple falsy values (`string | null | undefined` → `boolean`)
- `items.filter(Boolean)` → `items.filter((item) => item !== undefined && item !== null)`
- `isNaN(x)` → `Number.isNaN(x)`
- `Number(input)` → `parseFloat(input)` or `parseInt(input, 10)`
- `String(value)` → `value.toString()`

## Naming Conventions

- `as const` objects: `PascalCase` (keys also `PascalCase`); derive union type alongside
- Discriminated union discriminant: `type`
- `SCREAMING_CASE`: reserved for environment variables only

```typescript
const Status = {
  Active: "ACTIVE",
  Inactive: "INACTIVE",
} as const;
type Status = (typeof Status)[keyof typeof Status];
```

## Error Handling

- `return await` inside `try`/`catch`/`finally`: required (without `await` the promise escapes the block)
- `return await` outside error-handling blocks: omit (redundant)
- When `@typescript-eslint/return-await` is configured: linter takes precedence
