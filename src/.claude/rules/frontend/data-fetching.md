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

## Implementation

### React (TanStack Query)

```tsx
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";

const queryClient = useQueryClient();

// Read
const { data: users } = useQuery({
  queryKey: ["users"],
  queryFn: fetchUsers,
});

// Create
const { mutate: createUser } = useMutation({
  mutationFn: createUserApi,
  onSuccess: (newUser) => {
    queryClient.setQueryData(["users"], (old) => [...(old ?? []), newUser]);
  },
});

// Update
const { mutate: updateUser } = useMutation({
  mutationFn: updateUserApi,
  onSuccess: (updatedUser) => {
    queryClient.setQueryData(["users"], (old) =>
      (old ?? []).map((user) =>
        user.id === updatedUser.id ? updatedUser : user
      )
    );
  },
});

// Delete
const { mutate: deleteUser } = useMutation({
  mutationFn: deleteUserApi,
  onSuccess: (_, deletedId) => {
    queryClient.setQueryData(["users"], (old) =>
      (old ?? []).filter((user) => user.id !== deletedId)
    );
  },
});
```

### Vue (Pinia Colada)

```vue
<script setup lang="ts">
import { useQuery, useMutation, useQueryCache } from "@pinia/colada";

const queryCache = useQueryCache();

// Read
const { data: users } = useQuery({
  key: ["users"],
  query: fetchUsers,
});

// Create
const { mutate: createUser } = useMutation({
  mutation: createUserApi,
  onSuccess: (newUser) => {
    queryCache.setQueryData(["users"], (old) => [...(old ?? []), newUser]);
  },
});

// Update
const { mutate: updateUser } = useMutation({
  mutation: updateUserApi,
  onSuccess: (updatedUser) => {
    queryCache.setQueryData(["users"], (old) =>
      (old ?? []).map((user) =>
        user.id === updatedUser.id ? updatedUser : user
      )
    );
  },
});

// Delete
const { mutate: deleteUser } = useMutation({
  mutation: deleteUserApi,
  onSuccess: (_, deletedId) => {
    queryCache.setQueryData(["users"], (old) =>
      (old ?? []).filter((user) => user.id !== deletedId)
    );
  },
});
</script>
```

## API Design Prerequisite

This strategy requires REST APIs to return mutated data:

```
POST   /users     → { id: 1, name: "John", ... }  // created resource
PUT    /users/:id → { id: 1, name: "Jane", ... }  // updated resource
DELETE /users/:id → 204 No Content                // id from request
```
