---
applyTo: '**/*.{ts,tsx,vue}'
---

# TypeScript Guidelines

<!-- https://www.totaltypescript.com/cursor-rules-for-better-ai-development#the-rules -->

## Any inside generic functions

When building generic functions, you may need to use any inside the function body.

This is because TypeScript often cannot match your runtime logic to the logic done inside your types.

One example:

```ts
const youSayGoodbyeISayHello = <TInput extends 'hello' | 'goodbye'>(
  input: TInput,
): TInput extends 'hello' ? 'goodbye' : 'hello' => {
  if (input === 'goodbye') {
    return 'hello'; // Error!
  } else {
    return 'goodbye'; // Error!
  }
};
```

On the type level (and the runtime), this function returns `goodbye` when the input is `hello`.

There is no way to make this work concisely in TypeScript.

So using `any` is the most concise solution:

```ts
const youSayGoodbyeISayHello = <TInput extends 'hello' | 'goodbye'>(
  input: TInput,
): TInput extends 'hello' ? 'goodbye' : 'hello' => {
  if (input === 'goodbye') {
    return 'hello' as any;
  } else {
    return 'goodbye' as any;
  }
};
```

Outside of generic functions, use `any` extremely sparingly.

## Default exports

Unless explicitly required by the framework, do not use default exports.

```ts
// BAD
export default function myFunction() {
  return <div>Hello</div>;
}
```

```ts
// GOOD
export function myFunction() {
  return <div>Hello</div>;
}
```

Default exports create confusion from the importing file.

```ts
// BAD
import myFunction from './myFunction';
```

```ts
// GOOD
import { myFunction } from './myFunction';
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

```ts
type UserCreatedEvent = {
  type: 'user.created';
  data: { id: string; email: string };
};

type UserDeletedEvent = {
  type: 'user.deleted';
  data: { id: string };
};

type Event = UserCreatedEvent | UserDeletedEvent;
```

Use switch statements to handle the results of discriminated unions:

```ts
const handleEvent = (event: Event) => {
  switch (event.type) {
    case 'user.created':
      console.log(event.data.email);
      break;
    case 'user.deleted':
      console.log(event.data.id);
      break;
  }
};
```

Use discriminated unions to prevent the 'bag of optionals' problem.

For example, when describing a fetching state:

```ts
// BAD - allows impossible states
type FetchingState<TData> = {
  status: 'idle' | 'loading' | 'success' | 'error';
  data?: TData;
  error?: Error;
};

// GOOD - prevents impossible states
type FetchingState<TData> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: TData }
  | { status: 'error'; error: Error };
```

## Enums

Do not introduce new enums into the codebase. Retain existing enums.

If you require enum-like behavior, use an `as const` object:

```ts
const BackendToFrontendEnum = {
  xs: 'EXTRA_SMALL',
  sm: 'SMALL',
  md: 'MEDIUM',
} as const;

type LowerCaseEnum = keyof typeof BackendToFrontendEnum; // "xs" | "sm" | "md"

type UpperCaseEnum = (typeof BackendToFrontendEnum)[LowerCaseEnum]; // "EXTRA_SMALL" | "SMALL" | "MEDIUM"
```

Remember that numeric enums behave differently to string enums. Numeric enums produce a reverse mapping:

```ts
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

```ts
enum Direction {
  Up,
  Down,
  Left,
  Right,
}

Object.keys(Direction).length; // 8
```

## Import types

Use import type whenever you are importing a type.

Prefer top-level `import type` over inline `import { type ... }`.

```ts
// BAD
import { type User } from './user';
```

```ts
// GOOD
import type { User } from './user';
```

The reason for this is that in certain environments, the first version's import will not be erased. So you'll be left with:

```ts
// Before transpilation
import { type User } from './user';

// After transpilation
import './user';
```

## Install libraries

When installing libraries, do not rely on your own training data.

Your training data has a cut-off date. You're probably not aware of all of the latest developments in the JavaScript and TypeScript world.

This means that instead of picking a version manually (via updating the `package.json` file), you should use a script to install the latest version of a library.

```bash
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

```ts
// BAD

type A = {
  a: string;
};

type B = {
  b: string;
};

type C = A & B;
```

```ts
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

```ts
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

```ts
type RecordOfArrays<TItem> = Record<string, TItem[]>;
```

## No unchecked indexed access

If the user has this rule enabled in their `tsconfig.json`, indexing into objects and arrays will behave differently from how you expect.

```ts
const obj: Record<string, string> = {};

// With noUncheckedIndexedAccess, value will
// be `string | undefined`
// Without it, value will be `string`
const value = obj.key;
```

```ts
const arr: string[] = [];

// With noUncheckedIndexedAccess, value will
// be `string | undefined`
// Without it, value will be `string`
const value = arr[0];
```

## Optional properties

Use optional properties extremely sparingly. Only use them when the property is truly optional, and consider whether bugs may be caused by a failure to pass the property.

In the example below we always want to pass user ID to `AuthOptions`. This is because if we forget to pass it somewhere in the code base, it will cause our function to be not authenticated.

```ts
// BAD
type AuthOptions = {
  userId?: string;
};

const func = (options: AuthOptions) => {
  const userId = options.userId;
};
```

```ts
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

```ts
// BAD
type User = {
  id: string;
};

const user: User = {
  id: '1',
};

user.id = '2';
```

```ts
// GOOD
type User = {
  readonly id: string;
};

const user: User = {
  id: '1',
};

user.id = '2'; // Error
```

## Return types

When declaring functions on the top-level of a module, declare their return types. This will help future AI assistants understand the function's purpose.

```ts
const myFunc = (): string => {
  return 'hello';
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

```ts
type Result<T, E extends Error> = { ok: true; value: T } | { ok: false; error: E };
```

For example, when parsing JSON:

```ts
const parseJson = (input: string): Result<unknown, Error> => {
  try {
    return { ok: true, value: JSON.parse(input) };
  } catch (error) {
    return { ok: false, error: error as Error };
  }
};
```

This way you can handle the error in the caller:

```ts
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

```ts
// BAD
function calculateTotal(items: number[]): number {
  return items.reduce((sum, item) => sum + item, 0);
}
```

```ts
// GOOD
const calculateTotal = (items: number[]): number => {
  return items.reduce((sum, item) => sum + item, 0);
};
```

Exception: Use `function` declarations when you need hoisting behavior or when defining methods in classes.

```ts
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

```ts
// BAD - use map instead
const doubled: number[] = [];
numbers.forEach((num) => doubled.push(num * 2));

// GOOD
const doubled = numbers.map((num) => num * 2);
```

```ts
// BAD - use filter instead
const evens: number[] = [];
numbers.forEach((num) => {
  if (num % 2 === 0) evens.push(num);
});

// GOOD
const evens = numbers.filter((num) => num % 2 === 0);
```

```ts
// BAD - use reduce instead
let sum = 0;
numbers.forEach((num) => sum += num);

// GOOD
const sum = numbers.reduce((acc, num) => acc + num, 0);
```

### When to use forEach:

Use `forEach` only when you need side effects without creating a new array and no other array method fits:

```ts
// GOOD - logging each item (side effect)
users.forEach((user) => {
  console.log(`Processing user: ${user.name}`);
  sendEmail(user.email);
});

// GOOD - updating external state (side effect)
items.forEach((item) => {
  cache.set(item.id, item);
  metrics.increment('items.processed');
});
```

For most other use cases, prefer `map`, `filter`, `reduce`, `find`, `some`, `every`, or `for...of` loops.
