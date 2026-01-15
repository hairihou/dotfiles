---
paths: "**/*.{ts,tsx,vue}"
---

# Data Fetching

## Avoid Unnecessary Refetch (CRUD List Operations)

Do NOT use `invalidateQueries` / `refetch` when mutation response contains complete data. Use `setQueryData` to update cache directly.

```typescript
// ❌ BAD - unnecessary network request after mutation
onSuccess: () => {
  queryClient.invalidateQueries({ queryKey: ["users"] });
};

// ❌ BAD - same problem with refetch
onSuccess: () => {
  refetch();
};

// ✅ GOOD - direct cache update, no extra request
onSuccess: (newUser) => {
  queryClient.setQueryData(["users"], (old) => [...(old ?? []), newUser]);
};
```

### Why

- Mutation response already contains the data needed
- Extra network request is wasteful
- Maintains unidirectional data flow: Server → Cache → UI

### When `invalidateQueries` is Acceptable

- Derived/aggregated data affected
- Multi-view updates required
- Server-side side effects exist
- Paginated lists
- Response lacks required data

## Cache Update Patterns

| Operation | Pattern                                           |
| --------- | ------------------------------------------------- |
| Create    | `[...old, newItem]`                               |
| Update    | `old.map(x => x.id === updated.id ? updated : x)` |
| Delete    | `old.filter(x => x.id !== deletedId)`             |

## Framework Reference

| Framework              | Cache Access       | Key Prop   |
| ---------------------- | ------------------ | ---------- |
| TanStack Query (React) | `useQueryClient()` | `queryKey` |
| Pinia Colada (Vue)     | `useQueryCache()`  | `key`      |

## API Design Prerequisite

REST APIs must return mutated data:

```
POST   /users     → { id, name, ... }  // created resource
PUT    /users/:id → { id, name, ... }  // updated resource
DELETE /users/:id → 204 No Content     // id from request
```
