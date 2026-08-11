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
fix(payment): resolve transaction timeout issue

Payment was timing out due to database lock.
Implemented optimistic locking to prevent this.
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
- ❌ Include sensitive data (keys, passwords, .env files)
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
- [ ] Feature tests pass
- [ ] Manual testing completed

## Related Issues

Closes #issue-number
```

### Review Checklist

- Code follows Laravel best practices
- Changes are well-tested
- Documentation is updated
- No unnecessary changes included
- Migrations are reversible
- No sensitive data exposed

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
# Laravel specific
/node_modules
/public/hot
/public/storage
/storage/*.key
/vendor
.env
.env.backup
.env.production
.phpunit.result.cache
Homestead.json
Homestead.yaml
auth.json
npm-debug.log
yarn-error.log

# IDE
/.fleet
/.idea
/.vscode
*.swp
*.swo
*.swn

# OS
.DS_Store
Thumbs.db

# Testing
/coverage
_ide_helper.php
_ide_helper_models.php
.phpstorm.meta.php
```

## Deployment Workflow

```bash
# On feature completion
git checkout main
git pull origin main
git merge feature/my-feature
git push origin main

# Tag releases
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

---

_This is a starter template. Customize based on your project needs._
