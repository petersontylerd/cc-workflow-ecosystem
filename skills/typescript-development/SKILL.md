---
name: typescript-development
description: Use when working with TypeScript projects, configuring tsconfig, implementing TypeScript patterns, or choosing TypeScript tooling. Covers strict mode, type patterns, and error handling.
---

# TypeScript Development Standards

## Overview

TypeScript with strict mode, explicit types, and modern patterns. TypeScript 5.0+ required.

**Core principle:** Strict type safety, explicit over implicit, leverage the type system.

## Environment Setup

| Tool | Recommendation |
|------|----------------|
| TypeScript | >=5.0 |
| Runtime | Node.js >=20 LTS |
| Package Manager | pnpm > npm > yarn |
| Config | Strict tsconfig.json |

## Essential Commands

```bash
# Install dependencies
pnpm install

# Development
pnpm dev

# Run tests
pnpm test

# Format with Prettier
pnpm format

# Lint with ESLint
pnpm lint

# Type check
pnpm typecheck

# Build
pnpm build
```

## Code Quality Tools

| Tool | Purpose |
|------|---------|
| Prettier | Formatting (2 space, single quotes) |
| ESLint | Linting (@typescript-eslint) |
| tsc | Type checking (strict mode) |
| Vitest/Jest | Testing |

## Strict tsconfig.json

Enable all strict flags:

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "exactOptionalPropertyTypes": true
  }
}
```

## TypeScript-Specific Standards

### Interfaces vs Types

Prefer interfaces for objects:

```typescript
// Prefer for objects
interface User {
  id: string;
  name: string;
  email: string;
}

// Use type for unions, primitives, functions
type Status = 'pending' | 'active' | 'disabled';
type Handler = (event: Event) => void;
```

### Explicit Return Types

Required for public APIs:

```typescript
// Good: Explicit return type
function getUser(id: string): User | null {
  return users.get(id) ?? null;
}

// Good: Inferred for simple internal functions
const double = (n: number) => n * 2;
```

### Const Assertions

For literal types:

```typescript
const config = {
  endpoint: '/api',
  timeout: 5000,
} as const;

// Type is { readonly endpoint: "/api"; readonly timeout: 5000; }
```

### Discriminated Unions

For state modeling:

```typescript
type Result<T> =
  | { success: true; data: T }
  | { success: false; error: Error };

function handleResult<T>(result: Result<T>) {
  if (result.success) {
    console.log(result.data); // Type is T
  } else {
    console.error(result.error); // Type is Error
  }
}
```

### Avoid any

Use `unknown` with type guards:

```typescript
// Bad
function process(data: any) { ... }

// Good
function process(data: unknown) {
  if (isValidData(data)) {
    // data is now typed
  }
}

function isValidData(data: unknown): data is ValidData {
  return typeof data === 'object' && data !== null && 'id' in data;
}
```

## Modern Patterns

### Optional Chaining and Nullish Coalescing

```typescript
// Optional chaining
const name = user?.profile?.name;

// Nullish coalescing (prefer over ||)
const timeout = config.timeout ?? 5000;
```

### Destructuring

```typescript
// Object destructuring
const { id, name, email } = user;

// Array destructuring
const [first, ...rest] = items;

// With defaults
const { timeout = 5000 } = options;
```

### Template Literals

```typescript
const message = `User ${user.name} logged in at ${timestamp}`;

// Template literal types
type EventName = `on${Capitalize<string>}`;
```

### Async/Await

Prefer over Promise chains:

```typescript
// Good
async function fetchData(): Promise<Data> {
  const response = await fetch(url);
  return response.json();
}

// Avoid
function fetchData(): Promise<Data> {
  return fetch(url).then(r => r.json());
}
```

## Error Handling

### Custom Error Classes

```typescript
class ApiError extends Error {
  constructor(
    message: string,
    public statusCode: number,
    public code: string
  ) {
    super(message);
    this.name = 'ApiError';
  }
}
```

### Result Pattern

For expected errors:

```typescript
type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };

function parseJson(text: string): Result<unknown> {
  try {
    return { ok: true, value: JSON.parse(text) };
  } catch (e) {
    return { ok: false, error: e as Error };
  }
}
```

### Never Ignore Rejections

```typescript
// Always handle
promise.catch(handleError);

// Or use try/catch
try {
  await promise;
} catch (error) {
  handleError(error);
}
```

## Collections

Prefer Map/Set over objects:

```typescript
// For dynamic keys
const userCache = new Map<string, User>();
userCache.set(user.id, user);

// For unique values
const uniqueIds = new Set<string>();
uniqueIds.add(id);
```

## Quick Reference

| Need | Use |
|------|-----|
| Object shapes | `interface` |
| Union types | `type` |
| Literal types | `as const` |
| Optional values | `?.` and `??` |
| Unknown data | `unknown` + type guards |
| Iteration | `for...of` |
| Key-value | `Map<K, V>` |
| Unique values | `Set<T>` |
| Async | `async/await` |
