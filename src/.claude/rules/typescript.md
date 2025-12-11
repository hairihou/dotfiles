---
paths: **/*.ts, **/*.tsx, **/*.vue
---

# TypeScript Guidelines

<!-- https://www.totaltypescript.com/cursor-rules-for-better-ai-development#the-rules -->

## Any inside generic functions

When building generic functions, you may need to use any inside the function body.

This is because TypeScript often cannot match your runtime logic to the logic done inside your types.

One example:

```typescript
const youSayGoodbyeISayHello = <TInput extends "hello" | "goodbye">(
  input: TInput
): TInput extends "hello" ? "goodbye" : "hello" => {
  if (input === "goodbye") {
    return "hello"; // Error!
  } else {
    return "goodbye"; // Error!
  }
};
```

On the type level (and the runtime), this function returns `goodbye` when the input is `hello`.

There is no way to make this work concisely in TypeScript.

So using `any` is the most concise solution:

```typescript
const youSayGoodbyeISayHello = <TInput extends "hello" | "goodbye">(
  input: TInput
): TInput extends "hello" ? "goodbye" : "hello" => {
  if (input === "goodbye") {
    return "hello" as any;
  } else {
    return "goodbye" as any;
  }
};
```

Outside of generic functions, use `any` extremely sparingly.

## Block statements

Always use block statements (curly braces) for control flow statements, even for single-line statements.

This improves readability, prevents errors when adding additional statements, and maintains consistency.

```typescript
// BAD
if (condition) return;
if (user.isActive) processUser(user);
for (const item of items) console.log(item);

// GOOD
if (condition) {
  return;
}

if (user.isActive) {
  processUser(user);
}

for (const item of items) {
  console.log(item);
}
```

This rule applies to all control flow statements:

```typescript
// BAD
if (error) throw error;
while (running) update();
try { risky(); } catch (e) handle(e);

// GOOD
if (error) {
  throw error;
}

while (running) {
  update();
}

try {
  risky();
} catch (e) {
  handle(e);
}
```

## Default exports

Unless explicitly required by the framework, do not use default exports.

```typescript
// BAD
export default function myFunction() {
  return <div>Hello</div>;
}
```

```typescript
// GOOD
export function myFunction() {
  return <div>Hello</div>;
}
```

Default exports create confusion from the importing file.

```typescript
// BAD
import myFunction from "./myFunction";
```

```typescript
// GOOD
import { myFunction } from "./myFunction";
```

There are certain situations where a framework may require a default export. For instance, Next.js requires a default export for pages.

```tsx
// This is fine, if required by the framework
export default function MyPage() {
  return <div>Hello</div>;
}
```

## Discriminated unions

Proactively use discriminated unions to model data that can be in one of a few different shapes.

For example, when sending events between environments:

```typescript
type UserCreatedEvent = {
  type: "user.created";
  data: { id: string; email: string };
};

type UserDeletedEvent = {
  type: "user.deleted";
  data: { id: string };
};

type Event = UserCreatedEvent | UserDeletedEvent;
```

Use switch statements to handle the results of discriminated unions:

```typescript
const handleEvent = (event: Event) => {
  switch (event.type) {
    case "user.created":
      console.log(event.data.email);
      break;
    case "user.deleted":
      console.log(event.data.id);
      break;
  }
};
```

Use discriminated unions to prevent the 'bag of optionals' problem.

For example, when describing a fetching state:

```typescript
// BAD - allows impossible states
type FetchingState<TData> = {
  status: "idle" | "loading" | "success" | "error";
  data?: TData;
  error?: Error;
};

// GOOD - prevents impossible states
type FetchingState<TData> =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "success"; data: TData }
  | { status: "error"; error: Error };
```

## Enums

Do not introduce new enums into the codebase. Retain existing enums.

If you require enum-like behavior, use an `as const` object:

```typescript
const BackendToFrontendEnum = {
  xs: "EXTRA_SMALL",
  sm: "SMALL",
  md: "MEDIUM",
} as const;

type LowerCaseEnum = keyof typeof BackendToFrontendEnum; // "xs" | "sm" | "md"

type UpperCaseEnum = (typeof BackendToFrontendEnum)[LowerCaseEnum]; // "EXTRA_SMALL" | "SMALL" | "MEDIUM"
```

Remember that numeric enums behave differently to string enums. Numeric enums produce a reverse mapping:

```typescript
enum Direction {
  Up,
  Down,
  Left,
  Right,
}

const direction = Direction.Up; // 0
const directionName = Direction[0]; // "Up"
```

This means that the enum `Direction` above will have eight keys instead of four.

```typescript
enum Direction {
  Up,
  Down,
  Left,
  Right,
}

Object.keys(Direction).length; // 8
```

## Equality operators

ALWAYS use strict equality (`===`) and strict inequality (`!==`) operators.

The loose equality operators (`==` and `!=`) perform type coercion, which can lead to unexpected and confusing behavior.

```typescript
// BAD - uses loose equality with type coercion
if (value == 0) {
  // This matches 0, "0", false, "", null, undefined
}
if (response.status == 200) {
  // This would match "200" as well
}
if (items.length != 0) {
  // Unexpected behavior with type coercion
}

// GOOD - uses strict equality
if (value === 0) {
  // Only matches exactly 0
}
if (response.status === 200) {
  // Only matches the number 200
}
if (items.length !== 0) {
  // Clear and predictable behavior
}
```

### Common type coercion pitfalls to avoid:

```typescript
// These all evaluate to true with loose equality:
0 == false; // true
"" == false; // true
null == undefined; // true
"0" == 0; // true
[] == false; // true
"  " == 0; // true

// With strict equality, these are all false:
0 === false; // false
"" === false; // false
null === undefined; // false
"0" === 0; // false
[] === false; // false
"  " === 0; // false
```

### When you need to check for null/undefined:

```typescript
// BAD - loose equality
if (value == null) {
  // Matches both null and undefined
}

// GOOD - explicit checks
if (value === null || value === undefined) {
  // Clear intention
}

// ALSO GOOD - using nullish check
if (value == null) {
  // Only acceptable use of == is for null/undefined check
  // But explicit is better
}
```

The only exception is when specifically checking for null/undefined together, but even then, explicit checks are preferred for clarity.

### Avoid implicit boolean casting:

Avoid using `!` operator or implicit boolean casting, as they can lead to unexpected behavior with different types.

```typescript
// BAD - implicit boolean casting
if (!value) {
  // Matches "", 0, false, null, undefined, NaN
}
if (!!value) {
  // Double negation for boolean conversion
}
if (items.length) {
  // Implicit truthy check
}

// GOOD - explicit checks
if (value === "") {
  // Only matches empty string
}
if (value === null || value === undefined) {
  // Explicit null/undefined check
}
if (items.length > 0) {
  // Explicit length check
}
if (value === false) {
  // Explicit boolean check
}
```

### Common boolean casting pitfalls:

```typescript
// These all evaluate to false with ! operator:
!0; // true (number)
!""; // true (empty string)
!false; // true (boolean)
!null; // true
!undefined; // true
!NaN; // true
![]; // false (empty array is truthy!)
!{}; // false (empty object is truthy!)

// Be explicit about what you're checking:
const isEmpty = (str: string): boolean => str === "";
const isZero = (num: number): boolean => num === 0;
const isNull = (value: unknown): value is null => value === null;
const isUndefined = (value: unknown): value is undefined => value === undefined;
const hasItems = (arr: unknown[]): boolean => arr.length > 0;
```

## Import types

Use import type whenever you are importing a type.

Prefer top-level `import type` over inline `import { type ... }`.

```typescript
// BAD
import { type User } from "./user";
```

```typescript
// GOOD
import type { User } from "./user";
```

The reason for this is that in certain environments, the first version's import will not be erased. So you'll be left with:

```typescript
// Before transpilation
import { type User } from "./user";

// After transpilation
import "./user";
```

## Install libraries

When installing libraries, do not rely on your own training data.

Your training data has a cut-off date. You're probably not aware of all of the latest developments in the JavaScript and TypeScript world.

This means that instead of picking a version manually (via updating the `package.json` file), you should use a script to install the latest version of a library.

```sh
# pnpm
pnpm add -D @typescript-eslint/eslint-plugin

# yarn
yarn add -D @typescript-eslint/eslint-plugin

# npm
npm install --save-dev @typescript-eslint/eslint-plugin
```

This will ensure you're always using the latest version.

## Interface extends

ALWAYS prefer interfaces when modelling inheritance.

The `&` operator has terrible performance in TypeScript. Only use it where `interface extends` is not possible.

```typescript
// BAD

type A = {
  a: string;
};

type B = {
  b: string;
};

type C = A & B;
```

```typescript
// GOOD

interface A {
  a: string;
}

interface B {
  b: string;
}

interface C extends A, B {
  // Additional properties can be added here
}
```

## JSDoc comments

Use JSDoc comments to annotate functions and types.

Be concise in JSDoc comments, and only provide JSDoc comments if the function's behavior is not self-evident.

Use the JSDoc inline `@link` tag to link to other functions and types within the same file.

```typescript
/**
 * Subtracts two numbers
 */
const subtract = (a: number, b: number) => a - b;

/**
 * Does the opposite to {@link subtract}
 */
const add = (a: number, b: number) => a + b;
```

## Naming conventions

- Use kebab-case for file names (e.g., `my-component.ts`)
- Use camelCase for variables, function names, and constants (e.g., `myVariable`, `myFunction()`, `maxCount`)
- Use UpperCamelCase (PascalCase) for classes, types, interfaces, object literals and constants (e.g., `MyClass`, `MyInterface`, `MyObjectLiteral`, `MaxCount`)
- Inside generic types, functions or classes, prefix type parameters with `T` (e.g., `TKey`, `TValue`)

```typescript
type RecordOfArrays<TItem> = Record<string, TItem[]>;
```

## No unchecked indexed access

If the user has this rule enabled in their `tsconfig.json`, indexing into objects and arrays will behave differently from how you expect.

```typescript
const obj: Record<string, string> = {};

// With noUncheckedIndexedAccess, value will
// be `string | undefined`
// Without it, value will be `string`
const value = obj.key;
```

```typescript
const arr: string[] = [];

// With noUncheckedIndexedAccess, value will
// be `string | undefined`
// Without it, value will be `string`
const value = arr[0];
```

## Optional properties

Use optional properties extremely sparingly. Only use them when the property is truly optional, and consider whether bugs may be caused by a failure to pass the property.

In the example below we always want to pass user ID to `AuthOptions`. This is because if we forget to pass it somewhere in the code base, it will cause our function to be not authenticated.

```typescript
// BAD
type AuthOptions = {
  userId?: string;
};

const func = (options: AuthOptions) => {
  const userId = options.userId;
};
```

```typescript
// GOOD
type AuthOptions = {
  userId: string | undefined;
};

const func = (options: AuthOptions) => {
  const userId = options.userId;
};
```

## Readonly properties

Use `readonly` properties for object types by default. This will prevent accidental mutation at runtime.

Omit `readonly` only when the property is genuinely mutable.

```typescript
// BAD
type User = {
  id: string;
};

const user: User = {
  id: "1",
};

user.id = "2";
```

```typescript
// GOOD
type User = {
  readonly id: string;
};

const user: User = {
  id: "1",
};

user.id = "2"; // Error
```

## Return types

When declaring functions on the top-level of a module, declare their return types. This will help future AI assistants understand the function's purpose.

```typescript
const myFunc = (): string => {
  return "hello";
};
```

One exception to this is components which return JSX. No need to declare the return type of a component, as it is always JSX.

```tsx
const MyComponent = () => {
  return <div>Hello</div>;
};
```

## Throwing

Think carefully before implementing code that throws errors.

If a thrown error produces a desirable outcome in the system, go for it. For instance, throwing a custom error inside a backend framework's request handler.

However, for code that you would need a manual try catch for, consider using a result type instead:

```typescript
type Result<T, E extends Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };
```

For example, when parsing JSON:

```typescript
const parseJson = (input: string): Result<unknown, Error> => {
  try {
    return { ok: true, value: JSON.parse(input) };
  } catch (error) {
    return { ok: false, error: error as Error };
  }
};
```

This way you can handle the error in the caller:

```typescript
const result = parseJson('{"name": "John"}');

if (result.ok) {
  console.log(result.value);
} else {
  console.error(result.error);
}
```

## Arrow functions

Prefer arrow functions over `function` declarations for function definitions.

Arrow functions provide consistent lexical scoping and are more concise.

```typescript
// BAD
function calculateTotal(items: number[]): number {
  return items.reduce((sum, item) => sum + item, 0);
}
```

```typescript
// GOOD
const calculateTotal = (items: number[]): number => {
  return items.reduce((sum, item) => sum + item, 0);
};
```

Exception: Use `function` declarations when you need hoisting behavior or when defining methods in classes.

```typescript
// This is fine when hoisting is needed
function initializeApp() {
  setupDatabase();
}

function setupDatabase() {
  // Implementation
}

// This is fine for class methods
class Calculator {
  calculate(value: number): number {
    return value * 2;
  }
}
```

## forEach usage

Use `forEach` sparingly and only when it's the most appropriate choice. In most cases, other array methods are more suitable.

### When NOT to use forEach:

```typescript
// BAD - use map instead
const doubled: number[] = [];
numbers.forEach((num) => doubled.push(num * 2));

// GOOD
const doubled = numbers.map((num) => num * 2);
```

```typescript
// BAD - use filter instead
const evens: number[] = [];
numbers.forEach((num) => {
  if (num % 2 === 0) evens.push(num);
});

// GOOD
const evens = numbers.filter((num) => num % 2 === 0);
```

```typescript
// BAD - use reduce instead
let sum = 0;
numbers.forEach((num) => (sum += num));

// GOOD
const sum = numbers.reduce((acc, num) => acc + num, 0);
```

### When to use forEach:

Use `forEach` only when you need side effects without creating a new array and no other array method fits:

```typescript
// GOOD - logging each item (side effect)
users.forEach((user) => {
  console.log(`Processing user: ${user.name}`);
  sendEmail(user.email);
});

// GOOD - updating external state (side effect)
items.forEach((item) => {
  cache.set(item.id, item);
  metrics.increment("items.processed");
});
```

For most other use cases, prefer `map`, `filter`, `reduce`, `find`, `some`, `every`, or `for...of` loops.
