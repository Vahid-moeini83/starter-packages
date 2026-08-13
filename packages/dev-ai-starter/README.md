# dev-ai-starter

A single CLI tool to initialize frontend, backend, or full-stack projects with AI agent context rules and MCP configurations.

## Usage

```bash
npx dev-ai-starter init
```

## How it works

Running `init` asks two questions:

### 1. Project type

```
What type is this project?
> Frontend
  Backend
  Both (Frontend + Backend)
```

### 2. AI tools

```
Which AI agent tool(s) do you use?
[ ] Cursor
[ ] Claude Code
[ ] Kiro
[ ] None / Just .ai-starter is enough
```

## Output structure

The command creates a `.ai-starter/` directory in your current project root:

```
.ai-starter/
├── frontend/          ← only if Frontend or Both was selected
│   ├── context/       — Frontend-specific context rules
│   └── mcp/           — Frontend-specific MCP configuration
├── backend/           ← only if Backend or Both was selected
│   ├── context/       — Backend-specific context rules
│   └── mcp/           — Backend-specific MCP configuration
└── shared/            ← always created (for shared MCP config)
    └── mcp/           — Shared MCP configuration (used by both stacks)
```

Based on your AI tool selection, small reference files are created:

| Tool        | File created                     |
| ----------- | -------------------------------- |
| Cursor      | `.cursor/rules/ai-starter.mdc`   |
| Claude Code | `CLAUDE.md` (appended if exists) |
| Kiro        | `.kiro/steering/ai-starter.md`   |

These reference files point to `.ai-starter/` so each AI tool knows where to find context and MCP configurations.

## Re-running init

Each run only touches the sections you select:

- Selecting **Frontend** → overwrites `.ai-starter/frontend/` (both context and mcp) and `.ai-starter/shared/mcp/`. The `.ai-starter/backend/` directory is left completely untouched.
- Selecting **Backend** → overwrites `.ai-starter/backend/` (both context and mcp) and `.ai-starter/shared/mcp/`. The `.ai-starter/frontend/` directory is left completely untouched.
- Selecting **Both** → overwrites all sections (frontend, backend, and shared/mcp).

This means you can safely re-run `init` at any time to update a specific stack without affecting the other.

## Note on structure

- **Context files**: Each stack (frontend/backend) has its own context files with stack-specific rules. There is no shared context between them, even if some filenames are identical (e.g., `security.md` exists in both but contains different content).
- **MCP configuration**: MCP is split into three categories:
  - Frontend-specific: `.ai-starter/frontend/mcp/`
  - Backend-specific: `.ai-starter/backend/mcp/`
  - Shared (common to both): `.ai-starter/shared/mcp/`

## Local development

```bash
cd packages/dev-ai-starter
npm link

# In your project:
dev-ai-starter init
```
