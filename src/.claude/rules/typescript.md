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

## Array Types

Use `T[]` for simple types, `Array<T>` for complex types:

```typescript
// ✅ GOOD - simple types
const names: string[] = [];
const users: User[] = [];

// ✅ GOOD - complex types (unions, generics)
const items: Array<string | number> = [];
const maps: Array<Map<string, User>> = [];

// ✅ GOOD - readonly
const ids: readonly string[] = [];
const configs: ReadonlyArray<Config> = [];
```

## Constructor Functions (Prohibited)

NEVER use `Boolean`, `String`, `Number` as conversion functions:

```typescript
// ❌ PROHIBITED
items.filter(Boolean);
const str = String(value);
const num = Number(input);
const bool = Boolean(value);

// ✅ REQUIRED
items.filter((item) => item !== undefined && item !== null);
const str = `${value}`;
const num = parseFloat(input); // or parseInt(input, 10) for integers
const bool = value !== undefined && value !== null;
```

Note: `Number()` and `parseInt()`/`parseFloat()` behave differently:

- `Number("3.14")` → `3.14`, `parseInt("3.14", 10)` → `3`
- `Number("10px")` → `NaN`, `parseInt("10px", 10)` → `10`

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

Exception: `!!value` is allowed for multiple falsy values:

```typescript
// ✅ OK - checking string | null | undefined for empty
const hasValue = !!value; // instead of: value !== '' && value !== null && value !== undefined

// ❌ BAD - single nullish check should be explicit (value: T | undefined)
const exists = !!value;
// ✅ GOOD
const existsGood = value !== undefined;
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

## Nullish Coalescing

Use `??` for nullish values, `||` only when falsy fallback is intended:

```typescript
// ❌ BAD - || treats 0, '', false as falsy
const countBad = input || 10; // 0 becomes 10
const nameBad = input || "default"; // '' becomes 'default'

// ✅ GOOD - ?? only handles null/undefined
const count = input ?? 10;
const name = input ?? "default";

// ✅ OK - || when falsy fallback is intentional
const displayName = userName || "Anonymous"; // empty string should fallback
```

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

## Result Type (Recommended)

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

## Type Definitions

Use `interface` for object types, `type` for others:

```typescript
// interface - object types (extendable, better error messages)
interface User {
  readonly id: string;
  readonly name: string;
}

// type - unions, tuples, primitives, mapped types
type Status = "active" | "inactive";
type Pair = [string, number];
type ID = string;
type Nullable<T> = T | null;
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

## Unknown Type

Use `unknown` instead of `any` for type-safe handling:

```typescript
// ❌ BAD - any disables type checking
const parseBad = (json: string): any => JSON.parse(json);
const dataBad = parseBad("{}");
dataBad.foo.bar; // no error, runtime crash

// ✅ GOOD - unknown requires type narrowing
const parse = (json: string): unknown => JSON.parse(json);
const data = parse("{}");
if (typeof data === "object" && data !== null && "foo" in data) {
  // safely access data.foo
}
```

`any` is acceptable only in:

- Generic function bodies (see Generic Functions section)
- Type assertions for legacy code migration
- Third-party library type workarounds (with TODO comment)
