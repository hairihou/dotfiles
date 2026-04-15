---
paths: "**/*.vue"
---

# Vue Style Guide

## General

- No auto imports. Always write explicit imports
- No implicit globals in `<template>` (`$router`, `$t`, etc.). Bind explicitly from `<script setup>`
- Define blocks in order: `<script setup>` → `<template>` → `<style>`

## State Design

- Represent state transitions with a single `ref` of a discriminated union (algebraic data types), not multiple separate `ref`s
- Only define essential state. Derive everything else with `computed`
- Use `ref()` and `Ref<T>`. Do not use `reactive()`
- Use nominal typing with `unique symbol` for IDs, timestamps, dimensions
- `computed()`: always specify generic type parameter (`computed<T>(() => ...)`); never rely on return type inference

```typescript
// Bad: impossible combinations can exist
const isLoading = ref(false);
const error = ref<Error | null>(null);
const data = ref<Data | null>(null);

// Good: discriminated union
type State =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "error"; error: Error }
  | { status: "ok"; data: Data };
const state = ref<State>({ status: "idle" });
```

## Composable

- Must be Server-Client Universal. No client globals like `window` at top level
- Avoid `useRouter`, `inject`, or other implicit dependencies. Accept values and callbacks as arguments instead
- All async operations must handle race conditions with `AbortController`

```typescript
// Bad: hidden dependency
function useTodoNav() {
  const router = useRouter();
}
// Good: explicit inputs
function useTodoNav(
  currentId: Readonly<Ref<string>>,
  onSelectTodo: (id: string) => void,
) { ... }
```
