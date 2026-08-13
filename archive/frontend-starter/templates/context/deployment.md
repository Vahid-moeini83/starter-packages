# Deployments — AI Agent Rules

## Environments

Maintain at least three distinct environments, each with isolated resources (no shared DB/env vars between them):

| Environment           | Purpose                               | Deploy trigger                               |
| --------------------- | ------------------------------------- | -------------------------------------------- |
| `development` (local) | Local iteration                       | N/A                                          |
| `preview`             | Per-PR review, QA, stakeholder review | Every PR/branch push                         |
| `production`          | Live users                            | Merge to `main`/`master` (or tagged release) |

- Never let a PR/preview environment write to production data or share production secrets.
- Preview deployments must use isolated or seeded databases where possible.

## Environment Variables

- **Never** commit `.env`, `.env.local`, or any file containing real secrets. Only commit `.env.example` with placeholder keys and comments.
- Prefix client-exposed variables per framework convention (`NEXT_PUBLIC_*` in Next.js) and treat everything without that prefix as server-only, never referenced in Client Components.
- Validate environment variables at build/startup using a schema (e.g., `zod`) — fail fast with a clear error rather than undefined-at-runtime bugs.
- Secrets (API keys, DB credentials, signing secrets) live only in the hosting platform's secret manager (Vercel/Netlify/AWS/GH Actions secrets) — never in code, never in client bundles.
- Rotate secrets on any suspected leak or offboarded team member; audit `NEXT_PUBLIC_*` variables regularly to ensure nothing sensitive was accidentally exposed.

## Build & CI Requirements

Before any deploy, CI must run (in this order, fail-fast):

1. Install with lockfile integrity (`npm ci`, not `npm install`).
2. Type check (`tsc --noEmit`).
3. Lint (`eslint .`).
4. Unit/integration tests.
5. Build (`next build`) — this is also a correctness gate (catches type errors in some configs, invalid static generation, serialization issues).
6. (Optional but recommended) E2E smoke tests against the preview deployment.

The agent must never propose skipping type-check or build steps to "speed up" CI. If build time is a real problem, address it via caching/turborepo remote cache, not by removing gates.

## Deployment Strategy

- Prefer **atomic, immutable deployments** (each deploy is a new immutable build, instant rollback to a previous build — this is the default on Vercel/Netlify).
- For platforms without this by default (custom Docker/K8s), use blue-green or rolling deployments — never deploy by overwriting a live instance in place.
- **Rollback plan must exist before shipping**: know how to revert (redeploy previous build) in under a few minutes. Database migrations must be backward-compatible with the previous app version during the rollout window (expand/contract pattern), so a rollback never leaves the DB in a state the old code can't read.

## Next.js-Specific Deployment Rules

- Choose rendering strategy deliberately per route: static (`generateStaticParams`), ISR (`revalidate`), or dynamic (`force-dynamic`) — do not default everything to dynamic, as it kills performance and increases cost.
- Set `output: 'standalone'` for containerized deployments to minimize image size.
- Verify `next.config.js` `images.domains`/`remotePatterns` are locked to known hosts — do not allow arbitrary remote image domains.
- Check bundle size impact of new dependencies (`@next/bundle-analyzer`) before merging anything that adds a heavy client-side library.
- Enable Content Security Policy headers and security headers (see `05-security.md`) at the edge/middleware or hosting config level, not ad-hoc per page.

## Database Migrations

- Migrations must be version-controlled, reversible where feasible, and run as a distinct CI/CD step before the new app version receives traffic.
- Never run destructive migrations (`DROP COLUMN`, `DROP TABLE`) in the same deploy as the code that stops using that column — split into two deploys (stop using it → confirm stable → drop it).

## Monitoring Post-Deploy

- Error tracking (Sentry or equivalent) must be wired up with source maps uploaded on every production build.
- Set up deployment notifications (Slack/Discord webhook) with build status and a link to logs.
- Define and watch key metrics post-deploy for a defined window: error rate, Core Web Vitals (LCP, INP, CLS), and any critical business metric (checkout success rate, sign-up rate) — do not consider a deploy "done" the moment the build turns green.

## Checklist Before Marking a Deployment Task Complete

- [ ] All CI gates passed (type check, lint, test, build).
- [ ] No secrets committed or exposed in client bundle.
- [ ] Environment variables documented in `.env.example`.
- [ ] Rollback path confirmed.
- [ ] Migrations are backward-compatible with the currently-live app version.
- [ ] Monitoring/alerts will catch a failure within minutes, not days.

## Anti-Patterns

- ❌ Deploying directly from a local machine to production, bypassing CI.
- ❌ Using `latest` tags for base Docker images or dependencies in production builds — pin versions.
- ❌ Storing build artifacts with embedded secrets.
- ❌ Manually editing files on a running production server/container.
- ❌ Treating "the build succeeded" as equivalent to "the deploy is safe."
