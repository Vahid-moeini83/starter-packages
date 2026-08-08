# Backend Starter

CLI tool to initialize backend projects with AI agent skills, context rules, and MCP configurations.

## Installation

```bash
npx backend-starter init
```

Or install globally:

```bash
npm install -g backend-starter
backend-starter init
```

## What it does

This tool creates a `.ai-starter/` directory containing:

- **Skills**: Backend-specific and shared skills for AI agents
- **Context**: Rules and guidelines for development
- **MCP**: Model Context Protocol configurations

Then it creates reference files for your selected AI tools (Cursor, Claude Code, Kiro) that point to `.ai-starter/`.

All files are copied to your current directory without overwriting existing files.

For detailed usage instructions, see [USAGE.md](./USAGE.md).

## Skills Included

### Backend-Specific

- laravel-specialist
- laravel-security
- laravel-patterns
- laravel-tdd
- laravel-best-practice
- mysql
- supabase-postgres-best-practices

### Shared Skills

- find-skills
- grill-me
- Caveman
- improve-codebase-architecture
- docx, pdf, xlsx, pptx
- git-commit
- skill-creator
- seo-audit
- test-driven-development
- non-agents-official

## Context Rules Included

- database.md
- api-standards.md
- security.md
- error-handling-logging.md
- caching.md
- architect.md
- deployment.md
- debugging.md
- scaling.md
- authn-authz.md
- git.md
- testing.md
