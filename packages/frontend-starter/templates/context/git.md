# Git Guidelines

## Commit Messages

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples

```
feat(auth): add login functionality

Implement OAuth login with Google and GitHub providers.
Includes error handling and loading states.

Closes #123
```

```
fix(button): resolve click handler issue

Button was triggering twice due to event bubbling.
Added stopPropagation to prevent this.
```

## Branch Strategy

### Branch Naming

- `feature/feature-name` - New features
- `fix/bug-description` - Bug fixes
- `hotfix/critical-fix` - Urgent production fixes
- `refactor/component-name` - Code refactoring
- `docs/documentation-update` - Documentation

### Workflow

1. Create branch from `main` or `develop`
2. Make changes and commit
3. Push branch and create pull request
4. Code review and approval
5. Merge to main branch
6. Delete feature branch

## Best Practices

### Do

- ✅ Commit often with small, focused changes
- ✅ Write descriptive commit messages
- ✅ Pull before pushing
- ✅ Keep commits atomic (one logical change)
- ✅ Review your changes before committing

### Don't

- ❌ Commit directly to main/master
- ❌ Commit large binary files
- ❌ Include sensitive data (keys, passwords)
- ❌ Commit commented-out code
- ❌ Use generic messages like "fix" or "update"

## Pull Requests

### PR Template

```markdown
## Description

Brief description of changes

## Type of Change

- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing

- [ ] Unit tests pass
- [ ] Manual testing completed
- [ ] No console errors

## Screenshots

(if applicable)

## Related Issues

Closes #issue-number
```

### Review Checklist

- Code follows project style guide
- Changes are well-tested
- Documentation is updated
- No unnecessary changes included
- Commit history is clean

## Useful Commands

```bash
# View uncommitted changes
git status
git diff

# Undo last commit (keep changes)
git reset HEAD~1

# Update from remote
git pull origin main

# View commit history
git log --oneline --graph

# Stash changes temporarily
git stash
git stash pop

# Rebase on main
git rebase main

# Cherry-pick a commit
git cherry-pick <commit-hash>
```

## .gitignore Essentials

```
# Dependencies
node_modules/
package-lock.json (if using yarn)
yarn.lock (if using npm)

# Build outputs
dist/
build/
.next/
out/

# Environment variables
.env
.env.local
.env.production

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Testing
coverage/

# Logs
*.log
npm-debug.log*
```

---

_This is a starter template. Customize based on your project needs._
