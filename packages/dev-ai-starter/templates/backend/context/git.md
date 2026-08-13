# General Git Standards & Guardrails

## 🛑 Guardrails for AI Agent

- **NO FORCE PUSH**: NEVER use `git push -f` or `--force` on shared, `main`, or `develop` branches.
- **NO SECRETS IN COMMITS**: Ensure no passwords, private keys, or API tokens are included in the git index before committing.
- **NO LARGE BINARIES**: Do not commit large binary files or build artifacts (e.g., `node_modules`, `.pyc`, `.env`, build folders). Always use `.gitignore`.

## 📏 Standards

- **Branching Strategy**: Use feature branching. Branch off from `main` or `develop` (e.g., `feature/user-auth`, `bugfix/typo-in-nav`).
- **Commit Conventions**: Use Conventional Commits (e.g., `feat:`, `fix:`, `chore:`).

## 💡 Best Practices

- **Atomic Commits**: Keep commits small, atomic, and focused on a single logical change. Do not group unrelated changes into a single commit.
- **Clean History**: Use interactive rebase (`git rebase -i`) to squash small/wip commits before merging a feature branch.
- **Pull Requests (PRs)**: Write clear PR descriptions explaining _why_ the change was made, _what_ it fixes, and attach any relevant ticket numbers.
- **Staging**: When instructed to write code and commit, group related file modifications and write a concise, context-rich commit message.
