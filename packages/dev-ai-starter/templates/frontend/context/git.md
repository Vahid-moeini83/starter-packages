# Git & Version Control — AI Agent Rules

## Branching Strategy

- `main` (or `master`) is always deployable. No direct commits to `main` — all changes via pull request.
- Branch naming convention: `<type>/<short-description>`, e.g. `feat/user-onboarding`, `fix/cart-total-rounding`, `chore/upgrade-next-15`.
- Types align with Conventional Commits: `feat`, `fix`, `chore`, `refactor`, `docs`, `test`, `perf`, `style`, `ci`, `build`.
- Keep branches short-lived (days, not weeks). Rebase on `main` regularly to avoid large, painful merges.
- One logical change per branch/PR. Do not bundle an unrelated refactor with a feature.

## Commit Standards

Follow **Conventional Commits**:

```
<type>(<scope>): <short summary, imperative mood, no period>

<optional body: what and why, not how>

<optional footer: BREAKING CHANGE:, Closes #123>
```

Examples:

```
feat(auth): add magic-link login flow
fix(checkout): correct tax calculation for EU orders
refactor(billing): extract invoice PDF generation into service
chore(deps): bump next to 15.1.2
```

Rules:

- Subject line ≤ 72 characters, imperative mood ("add", not "added"/"adds").
- Never commit generic messages like `"fix"`, `"update"`, `"wip"`, `"asdf"` to shared branches — squash/rewrite before opening a PR if local history is messy.
- Each commit should leave the codebase in a working state (build passes) where feasible — makes bisecting reliable.
- Reference the issue/ticket number in the footer when applicable.

## Pull Requests

- PR title follows the same Conventional Commit format as the squash-merge commit will.
- PR description must include: what changed, why, how to test/verify, and screenshots/GIFs for any UI change.
- Keep PRs small and reviewable — target under ~400 lines of diff where possible; split larger work into a stacked series.
- Link the PR to its issue/ticket.
- Never merge your own PR without at least one approval on team projects, even if you're confident — this is a process rule, not a trust issue.
- All CI checks must be green before merge — no merging with a red build "to fix later."
- Use **squash merge** for feature branches into `main` to keep history clean, unless the team has explicitly chosen merge commits for a reason (e.g., preserving co-author history).

## .gitignore Requirements

Every Next.js/React project must ignore at minimum:

```
node_modules/
.next/
out/
build/
dist/
.env
.env.local
.env.*.local
*.log
.DS_Store
coverage/
.turbo/
.vercel/
next-env.d.ts   # only if auto-generated and not customized
```

- Never commit `node_modules`, build output, or `.env*` files (except `.env.example`).
- If a secret is accidentally committed: rotate the secret immediately, then remove it from history (`git filter-repo` or BFG) — a simple revert commit is not sufficient since the secret remains in history.

## Handling Merge Conflicts

- Prefer rebasing feature branches onto `main` over merging `main` into the feature branch, to keep history linear — unless team convention says otherwise.
- Resolve conflicts by understanding both changes' intent, not by blindly picking "ours" or "theirs."
- After resolving conflicts, re-run the full test suite and build before pushing — a conflict resolution can silently reintroduce a bug even if it "looks right."

## Code Review Etiquette (when the agent reviews or is reviewed)

- Review for correctness, security, and maintainability first; style nits last (and only if not already handled by linter/formatter — if it's not automatable, question whether it's worth a comment).
- Leave actionable, specific comments ("this will throw if `user` is null — add a guard" not "this looks off").
- Distinguish blocking comments from suggestions (`nit:`, `question:`, `blocking:` prefixes help).
- Approve only after confirming the PR does what it claims — pull it locally or read thoroughly, don't rubber-stamp.

## Tags & Releases

- Use Semantic Versioning (`MAJOR.MINOR.PATCH`) for anything published or independently deployed.
- Tag releases (`v1.4.0`) and maintain a `CHANGELOG.md` (can be auto-generated from Conventional Commits via `changesets` or `semantic-release`).

## Anti-Patterns

- ❌ `git push --force` to a shared branch (`main`, or any branch others are working from). `--force-with-lease` on your own feature branch only.
- ❌ Committing commented-out code "just in case" — delete it, git history preserves it.
- ❌ Massive PRs mixing formatting-only changes with logic changes (obscures the real diff) — run formatters in a separate, dedicated commit/PR.
- ❌ Rewriting history on a branch other people have already pulled from.
- ❌ Bypassing branch protection rules even when "it's just a small fix."
