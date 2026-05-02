---
paths: "**/*.{ts,tsx,vue}"
---

# TypeScript Rules

Applies to all TypeScript code, including `<script>` blocks in Vue SFC. Follow project linter config when present; these rules supplement it.

## Module Structure

- Re-export-only `index.ts` (barrel): do not create new ones
  - Exception: package public entrypoint (file referenced by `package.json#exports`/`main`/`module`)
- Path aliases (`@/...`, `~/...`): do not introduce new ones; in projects where aliases are already configured, write new imports as relative paths
- Util / shared file extraction: only after a second concrete consumer exists — do not pre-extract

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
- `Number(input)` → `parseFloat(input)` or `parseInt(input, 10)`

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
