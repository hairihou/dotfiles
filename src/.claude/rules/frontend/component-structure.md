---
paths: "**/*.{component.ts,tsx,vue}"
---

# Component Structure

Group related state, computed values, handlers, and side effects by feature.

## Declaration Order

### Vue Composition API

imports → props/emits → external composables → `useQuery`/`useMutation` → feature blocks → lifecycle → `defineExpose`

### React

props → external hooks → `useQuery`/`useMutation` → feature blocks → component-level `useEffect` → early returns → JSX

### Angular

`input()`/`output()` → `inject` → feature blocks → lifecycle

## Feature Block Example

```tsx
const user = ref<User | null>(null)
const fullName = computed(() => `${user.value?.first} ${user.value?.last}`)
const handleUserUpdate = () => { ... }

const formData = reactive({ name: '', email: '' })
const isValid = computed(() => formData.name.length > 0)
const handleSubmit = () => { ... }
```

## Spacing

- 1 blank line between feature blocks
- No blank lines within same feature block
- No comments to label feature blocks (spacing alone indicates grouping)
