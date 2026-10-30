---
paths: ['**/*.{ts,tsx,vue}']
---

# Query Cache

## Avoid Unnecessary Refetch (CRUD List Operations)

Do not use `invalidateQueries` / `refetch` when the mutation response contains complete data. Use `setQueryData` to update the cache directly.

```typescript
// Bad: unnecessary network request after mutation
onSuccess: () => {
  queryClient.invalidateQueries({ queryKey: ['users'] });
};

// Bad: same problem with refetch
onSuccess: () => {
  refetch();
};

// Good: direct cache update, no extra request
onSuccess: (newUser) => {
  queryClient.setQueryData(['users'], (old) => [...(old ?? []), newUser]);
};
```

### When `invalidateQueries` is Acceptable

- Derived/aggregated data affected
- Multi-view updates required
- Server-side side effects exist
- Paginated lists
- Response lacks required data

## Framework Reference

| Framework              | Cache Access       | Key Prop   |
| ---------------------- | ------------------ | ---------- |
| TanStack Query (React) | `useQueryClient()` | `queryKey` |
| Pinia Colada (Vue)     | `useQueryCache()`  | `key`      |
