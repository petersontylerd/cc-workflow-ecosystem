---
name: angular-development
description: Use when working with Angular projects, implementing components or services, or choosing Angular patterns. Covers Angular 17+ modern patterns including standalone components, signals, state management detection, and performance optimization.
---

# Angular Development Standards

## Overview

Modern Angular 17+ development with standalone components, signals, and CLI tooling.

**Core principle:** Discovery-first - detect existing project conventions before applying patterns.

## Discovery-First Approach

Before implementing, always detect the project's existing patterns:

```bash
# Check Angular version and dependencies
cat package.json | grep -E "@angular|@ngrx"

# Check for standalone vs NgModule architecture
grep -r "standalone: true" src/app --include="*.ts" | head -5
grep -r "@NgModule" src/app --include="*.ts" | head -5

# Detect state management approach
grep -r "signal\|computed\|effect" src/app --include="*.ts" | head -5
grep -r "BehaviorSubject\|ReplaySubject" src/app --include="*.ts" | head -5
```

Adapt to what you find, not what you prefer.

## Environment Setup

| Tool | Recommendation |
|------|----------------|
| Angular | >=17 |
| CLI | Angular CLI (ng) |
| Package Manager | npm or pnpm |
| Testing | Playwright/Cypress for E2E |

## Essential Commands

```bash
# Development
ng serve
ng serve --open

# Generation
ng generate component feature/my-component
ng generate service core/services/my-service
ng generate pipe shared/pipes/my-pipe

# Building
ng build
ng build --configuration production

# Testing
ng test
ng e2e
```

## State Management Detection

Identify the project's approach before implementing:

| Pattern | Detection | Typical Usage |
|---------|-----------|---------------|
| Signals | `signal()`, `computed()`, `effect()` | UI state, simple reactivity |
| RxJS Services | `BehaviorSubject`, `$` suffix observables | Async data, complex streams |
| NgRx | `@ngrx/*` packages, store directories | Large apps, strict Redux pattern |

### Signals Pattern

```typescript
import { signal, computed, effect } from '@angular/core';

// Writable signal
readonly count = signal(0);

// Derived/computed value
readonly doubled = computed(() => this.count() * 2);

// Side effects
constructor() {
  effect(() => {
    console.log('Count changed:', this.count());
  });
}
```

### RxJS Service Pattern

```typescript
import { BehaviorSubject, Observable } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class DataService {
  private readonly _items$ = new BehaviorSubject<Item[]>([]);

  // Public observable (read-only)
  readonly items$: Observable<Item[]> = this._items$.asObservable();

  updateItems(items: Item[]): void {
    this._items$.next(items);
  }
}
```

## Component Standards

### Standalone Components (Angular 17+)

```typescript
@Component({
  selector: 'app-feature',
  standalone: true,
  imports: [CommonModule, RouterModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `...`
})
export class FeatureComponent {}
```

### Modern Control Flow

```html
<!-- Conditionals -->
@if (loading()) {
  <app-spinner />
} @else if (error()) {
  <app-error [message]="error()" />
} @else {
  <app-content [data]="data()" />
}

<!-- Iteration with tracking -->
@for (item of items(); track item.id) {
  <app-item [item]="item" />
} @empty {
  <p>No items found</p>
}

<!-- Switch -->
@switch (status()) {
  @case ('loading') { <app-spinner /> }
  @case ('error') { <app-error /> }
  @default { <app-content /> }
}
```

### Deferred Loading

```html
@defer (on viewport) {
  <app-heavy-component />
} @placeholder {
  <div class="skeleton"></div>
} @loading (minimum 500ms) {
  <app-spinner />
}
```

## Performance Patterns

### Change Detection

Always use OnPush:

```typescript
@Component({
  changeDetection: ChangeDetectionStrategy.OnPush,
  // ...
})
```

### Track Functions

For `@for` or `*ngFor`, always provide tracking:

```html
<!-- Modern control flow -->
@for (item of items(); track item.id) {
  <app-item [item]="item" />
}

<!-- Legacy ngFor -->
<div *ngFor="let item of items; trackBy: trackById">
```

### Lazy Loading Routes

```typescript
export const routes: Routes = [
  {
    path: 'feature',
    loadComponent: () => import('./feature/feature.component')
      .then(m => m.FeatureComponent)
  },
  {
    path: 'admin',
    loadChildren: () => import('./admin/admin.routes')
      .then(m => m.ADMIN_ROUTES)
  }
];
```

## Subscription Management

### takeUntilDestroyed (Preferred)

```typescript
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';

@Component({...})
export class MyComponent {
  private destroyRef = inject(DestroyRef);

  ngOnInit() {
    this.dataService.items$
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(items => this.handleItems(items));
  }
}
```

### Async Pipe (Template-based)

```html
@if (items$ | async; as items) {
  @for (item of items; track item.id) {
    <app-item [item]="item" />
  }
}
```

## Naming Conventions

| Element | Style | Example |
|---------|-------|---------|
| Components | PascalCase + Component | `UserProfileComponent` |
| Services | PascalCase + Service | `AuthenticationService` |
| Pipes | PascalCase + Pipe | `DateFormatPipe` |
| Directives | PascalCase + Directive | `HighlightDirective` |
| Files | kebab-case | `user-profile.component.ts` |
| Selectors | prefix-kebab | `app-user-profile` |
| Observables | camelCase + $ | `items$`, `loading$` |

## Common Patterns

### Injection

```typescript
// Preferred: inject function
private readonly http = inject(HttpClient);
private readonly router = inject(Router);

// Alternative: constructor injection
constructor(private readonly http: HttpClient) {}
```

### Input/Output with Signals

```typescript
// Signal inputs (Angular 17.1+)
readonly name = input.required<string>();
readonly count = input(0); // with default

// Model inputs (two-way binding)
readonly value = model<string>('');

// Output
readonly selected = output<Item>();
```

### Error Handling

```typescript
this.http.get<Data>('/api/data').pipe(
  catchError(error => {
    console.error('API error:', error);
    return of({ items: [], error: true });
  })
);
```

## Quick Reference

| Need | Use |
|------|-----|
| State management | Detect existing approach first |
| Change detection | `ChangeDetectionStrategy.OnPush` |
| Control flow | `@if`, `@for`, `@switch` |
| Subscription cleanup | `takeUntilDestroyed()` or `async` pipe |
| Component inputs | `input()` / `input.required()` |
| Two-way binding | `model()` |
| Dependency injection | `inject()` function |
| Lazy loading | `loadComponent` / `loadChildren` |
| Performance | `track` in `@for`, OnPush, defer |
