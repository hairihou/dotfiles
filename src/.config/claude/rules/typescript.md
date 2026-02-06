---
paths: "**/*.{ts,tsx,vue}"
---

# TypeScript Rules

## Array Methods

- Prefer `map`/`filter`/`reduce` over `forEach`
- Use `forEach` only for side effects (logging, API calls)

## Array Types

- `T[]` for simple types
- `Array<T>` for complex types (unions, generics)

## Control Flow

Always use block statements (`if (x) { return; }`, not `if (x) return;`)

## Enums

Use `as const` objects instead of enums. Keys must be PascalCase.

```typescript
// NG
const Status = {
  activeUser: "ACTIVE",
  INACTIVE_USER: "INACTIVE",
} as const;

// OK
const Status = {
  Active: "ACTIVE",
  Inactive: "INACTIVE",
} as const;
type Status = (typeof Status)[keyof typeof Status];
```

## Equality & Boolean Checks

- Use strict equality (`===`, `!==`)
- Explicit nullish checks (`value !== undefined`, not `if (value)`)
- Boolean types allow truthy/falsy checks (`if (isEnabled)`)
- `!!value` allowed only for multiple falsy values (string | null | undefined)

## Exports

Avoid default exports unless framework requires.

## Functions

- Prefer arrow functions with explicit return types
- JSX components don't need return type annotations
- Use function declarations when hoisting is required

## Generic Functions

`as any` is acceptable inside generic function bodies when TypeScript cannot infer correctly.

## Nullish Coalescing

- `??` for nullish values
- `||` only when falsy fallback is intentional

## Optional Properties

- Prefer `| undefined` when callers must consciously decide
- Use `?:` when omission is the common case

## Prohibited Patterns

### Primitive Wrappers

- `items.filter(Boolean)` → `items.filter((item) => item !== undefined && item !== null)`
- `Number(input)` → `parseFloat(input)` or `parseInt(input, 10)`
- `String(value)` → `value.toString()`

### Other

- `isNaN(x)` → `Number.isNaN(x)`

## Property Order

Order by stability: `id` → readonly required → writable required → readonly optional → writable optional

## Readonly & Immutability

Use `readonly` by default.

## Result Type

Consider Result type (`{ ok: true; value: T } | { ok: false; error: E }`) for recoverable errors.

## Type Definitions

- `interface` for object types (extendable, better error messages)
- `type` for unions, tuples, primitives, mapped types
- Prefer `interface extends` over `&` intersections
- Use discriminated unions for variant data (avoid bag of optionals)

## Unknown Type

- Use `unknown` instead of `any`
- `any` acceptable only in: generic function bodies, legacy code migration, third-party workarounds (with TODO)
