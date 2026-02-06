---
paths: "**/*.{component.ts,tsx,vue}"
---

# Component Structure

Group related state, computed values, handlers, and side effects by feature.

## Feature Block

A logical group of related state, computed values, and handlers for a single concern.

```tsx
// user feature block
const user = ref<User | null>(null)
const fullName = computed(() => `${user.value?.first} ${user.value?.last}`)
const handleUserUpdate = () => { ... }

// form feature block
const formData = reactive({ name: '', email: '' })
const isValid = computed(() => formData.name.length > 0)
const handleSubmit = () => { ... }
```

## Reactive Primitives

- Declare in consistent order (predictable execution)
- Never declare inside conditionals or loops
- One side effect (useEffect / watch / effect) = one responsibility

## Spacing

- 1 blank line between feature blocks
- No blank lines within same feature block
- No comments to label feature blocks (spacing alone indicates grouping)

---

## Angular

### Declaration Order

`input()`/`output()` → `inject` → feature blocks → lifecycle

### Effect Guidelines

- Effects auto-track signal dependencies
- Use `untracked()` to read signals without tracking
- Cleanup via `onCleanup` callback inside effect
- Avoid writing to signals inside effects (use `allowSignalWrites` only when necessary)

---

## React

### Declaration Order

props → external hooks → `useQuery`/`useMutation` → feature blocks → component-level `useEffect` → early returns → JSX

### useEffect Guidelines

- Specify all dependencies used inside the effect
- Avoid object/array literals in dependency array (use useMemo or extract outside)
- Prefer multiple small effects over one large effect
- Cleanup function: cancel subscriptions, timers, and pending requests

---

## Vue

### Composables

- Return reactive refs (not raw values) for reactivity preservation
- Accept refs as parameters when reactivity is needed (`MaybeRef<T>`)
- Keep composables focused on single responsibility

### Computed

- Always specify generic type parameter: `computed<T>(() => ...)`
- Never rely on return type inference

```vue
<!-- NG -->
const label = computed(() => {
  if (status.value === Status.Active) {
    return t('status.active')
  }
  return t('status.inactive')
})

<!-- OK -->
const label = computed<string>(() => {
  if (status.value === Status.Active) {
    return t('status.active')
  }
  return t('status.inactive')
})
```

### Declaration Order

imports → props/emits → external composables → `useQuery`/`useMutation` → feature blocks → lifecycle → `defineExpose`

### Watch Guidelines

- `watch`: specific reactive sources, lazy by default
- `watchEffect`: auto-track dependencies, runs immediately
- Prefer `watch` with explicit sources over `watchEffect` for clarity
- Always handle cleanup via `onCleanup` parameter
