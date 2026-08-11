# Security — AI Agent Rules

Applies to: Next.js/React apps, client-server boundary, auth, data handling.

## The #1 Rule: Never Trust the Client

- All authorization checks must happen on the server (Server Actions, Route Handlers, middleware, DB row-level security) — never rely on client-side checks (hiding a button) as a security boundary. Client-side checks are UX only.
- Any data received from the client (form input, query params, headers, cookies) must be validated and sanitized server-side before use, even if it was also validated client-side.
- Never pass sensitive server data into a Client Component's props "because it's easier" — only pass what the UI actually needs to render.

## Secrets & Environment Variables

- Anything without a public prefix (`NEXT_PUBLIC_*`) must never be referenced inside a file that ships to the client (Client Components, anything imported by them).
- Audit before every release: search the client bundle for accidental secret leakage (`next build` output + a grep of `.next/static` for known secret patterns is a reasonable check).
- API keys for third-party services with server-side SDKs (Stripe secret key, DB credentials, service-role keys) must only be used in Server Components, Server Actions, or Route Handlers — never in `"use client"` files.
- Rotate any credential that may have been exposed, logged, or committed — do not assume "no one saw it."

## Authentication & Authorization

- Use battle-tested auth libraries/providers (NextAuth/Auth.js, Clerk, Supabase Auth, Auth0) rather than hand-rolled session/JWT logic unless there's a strong, explicit reason.
- Session tokens/cookies must be `httpOnly`, `Secure`, and `SameSite=Lax` or `Strict` — never store auth tokens in `localStorage`/`sessionStorage` where they're accessible to XSS.
- Enforce authorization at the data-access layer (e.g., a repository/service function checks "does this user own this resource?"), not just at the route/UI layer — so a forgotten check in one route doesn't become a breach.
- Use CSRF protection for state-changing requests when using cookie-based sessions (Server Actions have built-in origin checking in Next.js — verify it's not disabled).
- Rate-limit authentication endpoints (login, signup, password reset, OTP) to prevent brute force and enumeration.
- Don't leak account existence via error messages (e.g., "no user with that email" vs "invalid credentials" — prefer the generic message).

## Input Validation & Injection

- Validate all external input (forms, API payloads, URL params, headers) with a schema library (`zod`) at the boundary — parse, don't just check.
- Use parameterized queries / an ORM (Prisma, Drizzle) — never string-concatenate raw SQL with user input.
- Sanitize/escape any user-generated content rendered as HTML. If `dangerouslySetInnerHTML` is unavoidable, sanitize with a library like `DOMPurify` first — never render raw user HTML directly.
- Validate and constrain file uploads: type (via content sniffing, not just extension/MIME header trust), size limits, and store outside of directly executable paths; scan or restrict what's servable.
- Validate redirect targets (open redirect protection) — never redirect to a raw, unvalidated `?next=` param without checking it's an internal path.

## XSS / Content Security

- React escapes JSX content by default — that protection is void the moment `dangerouslySetInnerHTML` is used, so treat it as a last resort with mandatory sanitization.
- Set a Content-Security-Policy header (via `next.config.js` headers or middleware) restricting script sources; avoid `unsafe-inline`/`unsafe-eval` where feasible.
- Set standard security headers on every response:
  ```
  X-Content-Type-Options: nosniff
  X-Frame-Options: DENY (or CSP frame-ancestors)
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: <restrict unused APIs>
  Strict-Transport-Security: max-age=63072000; includeSubDomains; preload
  ```

## Dependencies & Supply Chain

- Run `npm audit`/`pnpm audit` (or Dependabot/Snyk) regularly; treat high/critical vulnerabilities in production dependencies as blocking, not backlog items.
- Pin dependency versions (lockfile committed and used, `npm ci` not `npm install` in CI) to avoid unreviewed drift.
- Be cautious adding new dependencies for trivial functionality — every dependency is attack surface. Check maintenance status, download count, and open security issues before adding.
- Never install packages by name similarity without verifying (typosquatting risk) — confirm the exact package name matches official docs.

## API & Route Handler Security

- Every Route Handler that mutates data must check authentication and authorization before touching the database — first lines of the handler, not an afterthought.
- Apply rate limiting to public-facing API routes, especially anything expensive (search, AI calls, email sending).
- CORS: restrict `Access-Control-Allow-Origin` to known origins; never `*` on routes that handle authenticated/sensitive requests.
- Don't expose verbose error details (stack traces, DB errors) to the client in production responses — log server-side, return a generic message client-side.

## Data Handling & Privacy

- Apply the principle of least privilege: only fetch/select the fields actually needed (avoid `SELECT *` returning fields like password hashes into API responses).
- Never log sensitive data (passwords, tokens, full card numbers, PII beyond what's necessary) — scrub logs.
- Follow data retention and deletion requirements (GDPR/CCPA as applicable) if the product handles personal data — support actual account/data deletion, not just soft flags nobody honors.

## Checklist Before Marking Any Feature Touching Auth/Payments/User Data as Done

- [ ] All new inputs validated server-side with a schema.
- [ ] Authorization enforced at the data-access layer, not just UI.
- [ ] No secrets or server-only env vars reachable from client code.
- [ ] No raw SQL string concatenation.
- [ ] Any HTML rendering of user content is sanitized.
- [ ] Errors don't leak internal details to the client.
- [ ] Security headers present on the relevant routes.
- [ ] New dependencies checked for known vulnerabilities.

## Anti-Patterns

- ❌ "We'll add auth checks later" — never ship a mutating endpoint without authz.
- ❌ Storing JWTs or session tokens in `localStorage`.
- ❌ Trusting `NEXT_PUBLIC_*`-style client data as authoritative for permissions.
- ❌ Disabling TypeScript/ESLint security-relevant rules to "get it working."
- ❌ Rolling a custom crypto/hashing implementation instead of a vetted library (`bcrypt`, `argon2`).
- ❌ Broad `try/catch` blocks that swallow and hide security-relevant failures (e.g., a failed permission check silently defaulting to "allow").
