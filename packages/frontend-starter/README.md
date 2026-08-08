# Frontend Starter

CLI tool to initialize frontend projects with AI agent skills, context rules, and MCP configurations.

## Installation

```bash
npx frontend-starter init
```

Or install globally:

```bash
npm install -g frontend-starter
frontend-starter init
```

## What it does

This tool creates a `.ai-starter/` directory containing:

- **Skills**: Frontend-specific and shared skills for AI agents
- **Context**: Rules and guidelines for development
- **MCP**: Model Context Protocol configurations

Then it creates reference files for your selected AI tools (Cursor, Claude Code, Kiro) that point to `.ai-starter/`.

All files are copied to your current directory without overwriting existing files.

For detailed usage instructions, see [USAGE.md](./USAGE.md).

## Skills Included

### Frontend-Specific

- frontend-design
- vercel-react-best-practice
- ui-ux-prompt
- anti-ui-slop
- ui-radar
- framer-motion-animator
- vercel-react-native-skills
- web-design-guidelines

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

- deployment.md
- architect.md
- testing.md
- design.md
- debugging.md
- security.md
- git.md
