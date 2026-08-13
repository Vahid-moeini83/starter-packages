# Debugging — AI Agent Rules

## Methodology (follow in order)

1. **Reproduce first.** Never propose a fix without a confirmed reproduction (steps, input, or failing test). If reproduction isn't possible, say so explicitly rather than guessing.
2. **Isolate the layer.** Determine whether the bug is: Server Component render, Client Component render, hydration mismatch, data fetching, state management, styling, or build/config. Each has different tooling.
3. **Read the actual error**, not the symptom. Trace stack traces to the first frame in project code (skip node_modules/framework frames first, but don't ignore them if project frames don't explain it).
4. **Bisect.** For regressions, use `git bisect` or comment out recently changed code to narrow the diff before editing broadly.
5. **Fix the root cause, not the symptom.** Do not silence errors with `try/catch` swallowing, `// @ts-ignore`, or `!important` unless the ticket explicitly asks for a stopgap — and if so, leave a `// TODO(reason, ticket)` comment.
6. **Verify the fix** with the original repro AND a regression test before considering the task done.

## Next.js / React-Specific Debugging

### Hydration Errors

- Check for: `Date.now()`, `Math.random()`, `window`/`document` access, or locale-dependent formatting rendered during SSR without guarding.
- Fix pattern: move non-deterministic values into `useEffect` + state, or use `suppressHydrationWarning` only on the specific leaf node as a last resort — never at the root.
- Verify server and client render the same markup by diffing `next build && next start` output vs dev.

### Server Component vs Client Component bugs

- If a hook (`useState`, `useEffect`, `useContext`) errors as "can only be used in Client Components," check for a missing `"use client"` directive at the top of the file — and confirm it's the leaf, not the whole tree.
- If a prop passed from Server to Client Component fails silently, check for non-serializable values (functions, Dates without conversion, class instances) crossing the boundary.

### Data Fetching Bugs

- Confirm caching behavior: `fetch` default caching, `revalidate`, `cache: 'no-store'`. A "stale data" bug is almost always a caching config issue in App Router — check this before touching component logic.
- For client-side fetching (React Query/SWR), check query key stability — an unstable key (new object/array literal per render) is the most common cause of infinite refetch loops.

### State Bugs

- Stale closures: check `useEffect`/`useCallback`/`useMemo` dependency arrays before assuming a logic bug.
- Check for state updates on unmounted components (missing cleanup in `useEffect`).
- For "why did this re-render," recommend React DevTools Profiler over guessing.

### Styling Bugs (Tailwind)

- Class not applying → check for: dynamic class name string concatenation (Tailwind JIT can't detect `` `text-${color}-500` ``; must use full static class names or a lookup map).
- Specificity fights → check Tailwind config `important` setting and CSS layer order before adding `!important`.
- Check `tailwind.config` `content` globs actually include the file if a class is silently missing in production build only.

## Tooling the Agent Should Use/Recommend

- **React DevTools** — component tree, re-render highlighting, Profiler tab.
- **Next.js build output** — read `next build` warnings fully; they flag serialization issues, bundle size, and dynamic API misuse.
- **`next dev --turbo` error overlay** — read the _full_ stack, including the "Call Stack" toggle, before concluding.
- **Source maps** — ensure enabled in production error tracking (Sentry) so stack traces map to real files.
- **`console.trace()`** over `console.log()` when the call origin is unclear.
- **Network tab** — for data bugs, check actual request/response, not assumed behavior.

## Debugging Checklist Before Declaring "Fixed"

- [ ] Original repro steps no longer fail.
- [ ] No new console errors/warnings introduced.
- [ ] `npm run build` / `next build` succeeds (catches type errors and serialization issues that dev mode hides).
- [ ] `npm run lint` and `tsc --noEmit` pass.
- [ ] A regression test was added (unit or e2e) covering the exact bug scenario.
- [ ] No debug artifacts left behind (`console.log`, `debugger`, commented-out code).

## Anti-Patterns

- ❌ Wrapping code in try/catch just to stop an error from surfacing without understanding why it occurred.
- ❌ Adding `useEffect` to "fix" a render issue that's actually a derived-state problem (compute during render instead).
- ❌ Downgrading a dependency to "fix" a bug without understanding the actual breaking change.
- ❌ Guessing at async race conditions without adding logging/timestamps to confirm ordering first.
