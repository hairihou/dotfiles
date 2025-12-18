---
paths: "**/*.{ts,tsx,vue}"
---

# TypeScript Rules

## Array Methods

Prefer `map`/`filter`/`reduce` over `forEach`:

```typescript
// ❌ BAD
const doubled: number[] = [];
numbers.forEach((n) => doubled.push(n * 2));

// ✅ GOOD
const doubled = numbers.map((n) => n * 2);
```

Use `forEach` only for side effects (logging, API calls).

## Control Flow

Always use block statements:

```typescript
// ❌ BAD
if (condition) return;

// ✅ GOOD
if (condition) {
  return;
}
```

## Enums

Use `as const` objects instead of enums:

```typescript
// ❌ BAD
enum Status {
  Active,
  Inactive,
}

// ✅ GOOD
const Status = { Active: "active", Inactive: "inactive" } as const;
type Status = (typeof Status)[keyof typeof Status];
```

## Equality & Boolean Checks

Use strict equality and explicit nullish checks:

```typescript
// ❌ BAD - loose equality, implicit nullish check
if (value == 0) {
}
if (value) {
}
if (!value) {
}
if (items.length) {
}

// ✅ GOOD - strict equality, explicit nullish check
if (value === 0) {
}
if (value !== undefined) {
}
if (value === undefined) {
}
if (items.length > 0) {
}

// ✅ OK - boolean type allows truthy/falsy check
if (isEnabled) {
}
if (!isDisabled) {
}
```

## Exports

Avoid default exports unless framework requires:

```typescript
// ❌ BAD
export default function myFunction() {}

// ✅ GOOD
export function myFunction() {}
```

## Functions

Prefer arrow functions with explicit return types:

```typescript
// ❌ BAD
function calculate(x: number) {
  return x * 2;
}

// ✅ GOOD
const calculate = (x: number): number => {
  return x * 2;
};
```

Exceptions:

- JSX components don't need return type annotations
- Use function declarations when hoisting is required

## Generic Functions

`as any` is acceptable inside generic function bodies when TypeScript cannot infer correctly:

```typescript
const toggle = <T extends "on" | "off">(
  input: T
): T extends "on" ? "off" : "on" => {
  return (input === "on" ? "off" : "on") as any;
};
```

## Imports

Use top-level `import type`:

```typescript
// ❌ BAD
import { type User } from "./user";

// ✅ GOOD
import type { User } from "./user";
```

Note: With `verbatimModuleSyntax: true`, inline `import { type X }` may be preferred. Follow project's tsconfig.

## Naming

- Files: `kebab-case.ts`
- Variables/functions: `camelCase`
- Types/interfaces/classes: `PascalCase`
- Type parameters: `TPrefix` (e.g., `TKey`, `TValue`)

## Optional Properties

For object types where callers must consciously decide, prefer `| undefined`:

```typescript
// ❌ BAD - easy to forget passing userId
type Options = { userId?: string };

// ✅ GOOD - forces explicit decision
type Options = { userId: string | undefined };
```

Use `?:` when the property is truly optional and omission is the common case.

## Readonly & Immutability

Use `readonly` by default:

```typescript
interface User {
  readonly id: string;
  readonly name: string;
}
```

## Type Definitions

Use `interface` for object types, `type` for others:

```typescript
// interface - object types (extendable, better error messages)
interface User {
  id: string;
  name: string;
}

// type - unions, tuples, primitives, mapped types
type Status = "active" | "inactive";
type Pair = [string, number];
type ID = string;
type Readonly<T> = { readonly [K in keyof T]: T[K] };
```

Prefer `interface extends` over `&` intersections:

```typescript
// ❌ BAD - poor performance
type C = A & B;

// ✅ GOOD
interface C extends A, B {}
```

Use discriminated unions for variant data:

```typescript
// ❌ BAD - bag of optionals
type State = {
  status: "idle" | "loading" | "success" | "error";
  data?: Data;
  error?: Error;
};

// ✅ GOOD - impossible states prevented
type State =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "success"; data: Data }
  | { status: "error"; error: Error };
```

---

# Guidelines (Recommended)

## Error Handling

Consider Result type for recoverable errors:

```typescript
type Result<T, E> = { ok: true; value: T } | { ok: false; error: E };

const parseJson = (input: string): Result<unknown, Error> => {
  try {
    return { ok: true, value: JSON.parse(input) };
  } catch (e) {
    return { ok: false, error: e as Error };
  }
};
```
