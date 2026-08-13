# Testing — AI Agent Rules

Applies to: React/Next.js apps using Vitest/Jest, React Testing Library, Playwright/Cypress.

## Testing Philosophy

- **Test behavior, not implementation.** Assert on what the user sees/does, not internal state or private functions.
- **Testing Trophy, not Pyramid**: prioritize integration tests (components + their real interactions) as the bulk of coverage, with a smaller base of unit tests for pure logic and a thin top layer of E2E for critical user flows.
  ```
        /‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\
       /   E2E (few)        \      Critical user journeys only
      /----------------------\
     /  Integration (most)     \   Components + hooks + interactions
    /----------------------------\
   /   Unit (pure logic)          \  Utils, reducers, calculations
  /__________________________________\
       Static (TS + ESLint) — foundation, always on
  ```
- Write tests that survive refactors. If renaming an internal variable or restructuring a component's internals breaks a test, the test is coupled to implementation, not behavior — fix the test's approach.

## Unit Tests (Vitest/Jest)

- Use for: pure functions, utilities, business logic, reducers, data transformations, custom hooks with complex logic.
- One assertion focus per test; test names describe behavior: `it('returns 0 when the cart is empty')`, not `it('works')`.
- Follow Arrange-Act-Assert structure.
- Mock only at the boundary (network, time, randomness) — don't mock internal collaborators just to isolate a unit if it makes the test meaningless.
- Aim for meaningful coverage of business-critical logic (pricing, permissions, validation) — 100% coverage is not the goal; untested critical paths are the risk to eliminate.

## Component Tests (React Testing Library)

- Query elements the way a user would: `getByRole`, `getByLabelText`, `getByText` — avoid `getByTestId` unless there's no accessible query available (and if so, that's often itself an accessibility gap worth fixing).
- Never test implementation details: don't assert on component state, don't call internal methods directly, don't rely on class names for assertions.
- Use `userEvent` (not `fireEvent`) for interactions — it simulates real user input sequences (focus, keydown, keyup) more accurately.
- Test the states that matter: default/loading/error/empty/populated — not just the happy path.
- For components fetching data, mock at the network layer (MSW — Mock Service Worker) rather than mocking the fetching library/hook directly, so the test exercises real request/response handling.

Example pattern:

```tsx
test("shows validation error when email is invalid", async () => {
  render(<SignupForm />);
  await userEvent.type(screen.getByLabelText(/email/i), "not-an-email");
  await userEvent.click(screen.getByRole("button", { name: /sign up/i }));
  expect(await screen.findByText(/enter a valid email/i)).toBeInTheDocument();
});
```

## Server Actions / API Route Testing

- Test Server Actions and Route Handlers as integration tests: call them directly with realistic inputs, assert on outputs and side effects (DB state, thrown errors), using a test database or transaction rollback per test — never test against production data.
- Cover authorization: explicitly test that unauthorized/unauthenticated calls are rejected, not just that authorized calls succeed.
- Cover validation: assert malformed/malicious input is rejected with the expected error, not a 500.

## E2E Tests (Playwright preferred, Cypress acceptable)

- Reserve for critical user journeys only: signup, login, checkout, core value-prop flow. E2E is slow and flaky-prone — don't E2E-test every UI variant.
- Tests must be independent and order-agnostic — no test should depend on state left by a previous test.
- Use data-testid sparingly and only when role/label queries genuinely can't disambiguate; prefer the same accessible-query approach as component tests.
- Seed test data via API/DB setup, not by clicking through the UI to create prerequisite state (slow, brittle).
- Run E2E against a real preview deployment or a production-like build (`next build && next start`), not `next dev`, to catch build-specific issues.
- Avoid arbitrary `waitForTimeout`; wait on explicit conditions (element visible, network idle, specific response) instead — a fixed sleep is the top cause of flaky E2E suites.

## Test Data & Mocking

- Use factory functions/builders for test data (`buildUser({ role: 'admin' })`) instead of copy-pasted object literals scattered across test files.
- Mock network calls with MSW so the same mock handlers can serve both component tests and integration tests.
- Never let tests depend on real external services (real Stripe, real email provider) — always mock/stub at the boundary in automated test runs; reserve real integrations for a manual or isolated staging smoke test.
- Reset mocks/state between tests (`beforeEach`) — no shared mutable state leaking across test cases.

## CI Integration

- All tests run on every PR; the suite must be fast enough to not block iteration (parallelize, split E2E from unit/integration in CI jobs).
- Flaky tests are bugs — a test that intermittently fails must be fixed or quarantined with a tracked ticket, never just re-run until green and ignored.
- Coverage reports are a signal, not a gate to game — do not write meaningless tests purely to hit a coverage percentage.

## What Requires a Test (Non-Negotiable)

- Any bug fix must include a regression test that fails before the fix and passes after.
- Any new business logic (pricing, permissions, calculations, state machines) must have unit tests covering edge cases (zero, negative, boundary, null/undefined).
- Any new user-facing form must have a test covering validation error states, not just successful submission.
- Any new API route/Server Action handling auth or mutating data must have a test asserting unauthorized access is rejected.

## Anti-Patterns

- ❌ Snapshot tests of large component trees as the primary assertion strategy — they rot fast and get blindly updated (`--updateSnapshot`) without real review.
- ❌ Testing implementation details (internal state, private methods, CSS class presence) instead of user-visible behavior.
- ❌ `getByTestId` everywhere by default instead of accessible queries.
- ❌ E2E tests as the primary coverage strategy — slow feedback loop, high flake rate.
- ❌ Skipping/disabling a failing test (`.skip`, `xit`) to unblock a merge without a tracked follow-up.
- ❌ Tests that depend on execution order or shared global state.
- ❌ Testing third-party library internals (e.g., verifying React Query itself works) instead of your integration with it.
