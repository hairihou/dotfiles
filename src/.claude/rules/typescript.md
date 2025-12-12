---
paths: **/*.{ts,tsx,vue}
---

# TypeScript Rules

## Equality & Boolean Checks

Use strict equality and explicit checks:

```typescript
// ❌ BAD
if (value == 0) {
}
if (!value) {
}
if (items.length) {
}

// ✅ GOOD
if (value === 0) {
}
if (value === null || value === undefined) {
}
if (items.length > 0) {
}
```

## Type Definitions

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

## Optional Properties

Prefer explicit `| undefined` over `?:` for required awareness:

```typescript
// ❌ BAD - easy to forget passing userId
type Options = { userId?: string };

// ✅ GOOD - forces explicit decision
type Options = { userId: string | undefined };
```

## Readonly & Immutability

Use `readonly` by default:

```typescript
type User = {
  readonly id: string;
  readonly name: string;
};
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

## Imports

Use top-level `import type`:

```typescript
// ❌ BAD
import { type User } from "./user";

// ✅ GOOD
import type { User } from "./user";
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

Exception: JSX components don't need return type annotations.

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

## Naming

- Files: `kebab-case.ts`
- Variables/functions: `camelCase`
- Types/interfaces/classes: `PascalCase`
- Type parameters: `TPrefix` (e.g., `TKey`, `TValue`)

## Generic Functions

`as any` is acceptable inside generic function bodies when TypeScript cannot infer correctly:

```typescript
const toggle = <T extends "on" | "off">(
  input: T
): T extends "on" ? "off" : "on" => {
  return (input === "on" ? "off" : "on") as any;
};
```
