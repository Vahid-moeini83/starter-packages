# Architecture & Folder Structure — AI Agent Rules

Applies to: React 18+, Next.js 14+ (App Router), TypeScript, Tailwind CSS.

## Core Principles

1. **Feature-first, not type-first.** Group by domain/feature, not by technical layer (avoid dumping everything into flat `components/`, `hooks/`, `utils/` folders at scale).
2. **Colocation.** Keep a component, its styles, its tests, and its hooks next to each other unless shared across 3+ features.
3. **Single source of truth.** No duplicated types, constants, or business logic. Shared code moves to `packages/` or `src/shared/` the moment a second consumer appears (rule of two).
4. **Explicit boundaries.** Features must not import from each other's internals — only from a public `index.ts` barrel export.
5. **Server-first by default.** In App Router, default to Server Components. Add `"use client"` only when interactivity, browser APIs, or hooks require it.

## Standard Next.js App Router Structure

```
src/
  app/                      # Routes only — no business logic
    (marketing)/            # Route groups for layout segregation
    (app)/
      dashboard/
        page.tsx
        layout.tsx
        loading.tsx
        error.tsx
        _components/        # Route-private components (underscore = not a route)
    api/
      [route]/route.ts
    layout.tsx
    global-error.tsx
    not-found.tsx

  features/                 # Feature modules (domain-driven)
    auth/
      components/
      hooks/
      api/                  # fetch/mutation functions, server actions
      types.ts
      utils.ts
      index.ts              # public API of the feature (barrel)
    billing/
      ...

  components/
    ui/                      # Design-system primitives (Button, Input, Dialog)
    layout/                  # Header, Footer, Sidebar, Shell

  hooks/                     # Truly cross-feature hooks (useDebounce, useMediaQuery)
  lib/                       # Framework-agnostic utilities, third-party clients (db, stripe)
  server/                    # Server-only code: actions, services, repositories
    actions/
    services/
    db/
  config/                    # env, site config, constants
  styles/
    globals.css
  types/                     # Global/shared TypeScript types
  middleware.ts

public/
tests/
  e2e/
  __mocks__/
```

## Rules for the AI Agent

- **Never** put business logic inside `app/**/page.tsx`. Pages compose; features implement.
- **Never** create a new top-level folder without checking if an existing feature owns that domain.
- **Always** export a feature's public interface through `index.ts`; do not deep-import `features/auth/components/LoginForm` from outside the feature — import from `features/auth`.
- **Always** put server-only code (DB queries, secrets, service-role clients) under `server/` or a file with server-only guarantees (Server Actions, Route Handlers). Never import server-only modules into Client Components.
- Co-locate a component's test file as `Component.test.tsx` next to `Component.tsx`, OR mirror the path under `tests/` — pick one convention per repo and stay consistent; do not mix.
- Path aliases (`@/features/*`, `@/components/*`, `@/lib/*`) must be defined in `tsconfig.json` and used consistently — no relative `../../../../` chains beyond one level.
- One component per file. File name matches the default export name (PascalCase for components, camelCase for hooks/utils).
- Barrel files (`index.ts`) only re-export; they must not contain logic.

## Layering & Dependency Direction

```
app/  →  features/  →  components/ui, lib, hooks
```

- `app` may depend on `features` and `components`.
- `features` may depend on `components/ui`, `lib`, `hooks`, but never on another `feature`'s internals, and never on `app`.
- `components/ui` must be pure/presentational — no data fetching, no feature-specific logic, no direct API calls.
- `lib` and `server` must not import from `features` or `components` (keep them leaf nodes).

If the AI agent is asked to add code, it must first determine which layer it belongs to using this table before writing any file.

## When Scaling to a Monorepo

Use Turborepo or Nx once there are 2+ deployable apps or shared code consumed by multiple apps:

```
apps/
  web/
  admin/
packages/
  ui/                # shared design system
  config/             # eslint, tsconfig, tailwind presets
  types/
  utils/
```

- Shared packages must declare explicit `exports` in `package.json` — no reaching into `dist/` or internal paths.
- Version internal packages with workspace protocol (`workspace:*`), not pinned versions.

## Anti-Patterns the Agent Must Avoid

- ❌ God components (>300 lines, mixing data fetching + UI + business logic).
- ❌ Prop drilling beyond 2 levels — use composition, context, or a state manager instead.
- ❌ Circular imports between features.
- ❌ Business logic inside `useEffect` that could be a Server Component or Server Action.
- ❌ Creating a new state-management library when React state, URL state, or Server Components already solve the need.
- ❌ Barrel files that re-export everything from `components/ui` causing massive bundle graphs — export granularly when tree-shaking matters.
