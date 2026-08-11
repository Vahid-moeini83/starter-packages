# AI Starter Packages

A monorepo containing CLI tools to bootstrap AI agent configurations for frontend and backend projects. These packages provide a unified way to set up skills, context rules, and MCP (Model Context Protocol) configurations across different AI coding assistants.

## 📦 Packages

### [`frontend-starter`](./packages/frontend-starter)

CLI tool for initializing frontend projects with AI agent configurations including React, Vue, UI/UX, and design-focused skills.

### [`backend-starter`](./packages/backend-starter)

CLI tool for initializing backend projects with AI agent configurations including Laravel, database, API, and security-focused skills.

## 🚀 Quick Start

```bash
# For frontend projects
npx frontend-starter init

# For backend projects
npx backend-starter init
```

## 🎯 What This Does

When you run the `init` command, it:

1. **Creates `.ai-starter/` directory** - A central source of truth containing:
   - `skills/` - Reusable AI agent skills
   - `context/` - Project-specific rules and guidelines
   - `mcp/` - Model Context Protocol configurations

2. **Asks which AI tools you use** - Interactive prompt to select from:
   - Cursor
   - Claude Code
   - Kiro
   - None (just use `.ai-starter/` directly)

3. **Creates reference files** - Based on your selection:
   - **Cursor**: `.cursor/rules/ai-starter.mdc`
   - **Claude Code**: `CLAUDE.md` (appends if exists)
   - **Kiro**: `.kiro/steering/ai-starter.md`

These reference files point to the `.ai-starter/` directory, keeping everything DRY (Don't Repeat Yourself).

## 🏗️ Architecture

```
your-project/
├── .ai-starter/              # Source of truth
│   ├── skills/
│   ├── context/
│   └── mcp/
│
├── .cursor/                  # Tool-specific reference (if selected)
│   └── rules/
│       └── ai-starter.mdc
│
├── .kiro/                    # Tool-specific reference (if selected)
│   └── steering/
│       └── ai-starter.md
│
└── CLAUDE.md                 # Tool-specific reference (if selected)
```

This architecture ensures:

- **Single source of truth**: All content lives in `.ai-starter/`
- **Tool agnostic**: Works with multiple AI assistants
- **Easy updates**: Modify content once, all tools see the change
- **No duplication**: Reference files are small pointers

## 📚 What's Included

### Frontend Starter

- **Skills**: frontend-design, vercel-react-best-practice, ui-ux-prompt, anti-ui-slop, ui-radar, framer-motion-animator, and more
- **Context**: deployment, architect, testing, design, debugging, security, git

### Backend Starter

- **Skills**: laravel-specialist, laravel-security, laravel-patterns, mysql, supabase-postgres-best-practices, and more
- **Context**: database, api-standards, security, error-handling-logging, caching, architect, deployment, debugging, scaling, authn-authz, git, testing

### Shared Skills

Both packages include: find-skills, grill-me, Caveman, improve-codebase-architecture, docx, pdf, xlsx, pptx, git-commit, skill-creator, seo-audit, test-driven-development, non-agents-official

## 💻 Development

```bash
# Clone the repository
git clone <repository-url>
cd starter-packages

# Install dependencies
npm install

# Link packages for local testing
cd packages/frontend-starter
npm link
cd ../..

cd packages/backend-starter
npm link
cd ../..

# Test in a project
cd /path/to/your-project
frontend-starter init
```

## 📖 Documentation

- [Frontend Starter README](./packages/frontend-starter/README.md)
- [Frontend Starter Usage Guide](./packages/frontend-starter/USAGE.md)
- [Backend Starter README](./packages/backend-starter/README.md)
- [Backend Starter Usage Guide](./packages/backend-starter/USAGE.md)

## 🤝 Contributing

1. Add new skills in `packages/[package-name]/templates/skills/`
2. Add new context rules in `packages/[package-name]/templates/context/`
3. Update MCP configurations in `packages/[package-name]/templates/mcp/`
4. Test with `npm link` before publishing

## 📄 License

MIT

## 🔗 Related

- [Skills Installer](./skills-installer) - Alternative installation method
