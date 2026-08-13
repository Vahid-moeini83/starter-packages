import fs from "fs-extra";
import path from "path";

export const TOOLS = {
  cursor: {
    name: "Cursor",
    path: ".cursor/rules/ai-starter.mdc",
    content: `---
description: Reference to shared AI starter resources
alwaysApply: true
---

# AI Starter Resources

This project uses context rules and MCP configuration stored in \`.ai-starter/\`.

Structure:
- \`.ai-starter/frontend/context/*.md\` — Frontend-specific context rules
- \`.ai-starter/frontend/mcp/\` — Frontend-specific MCP configuration
- \`.ai-starter/backend/context/*.md\` — Backend-specific context rules
- \`.ai-starter/backend/mcp/\` — Backend-specific MCP configuration
- \`.ai-starter/shared/mcp/\` — Shared MCP configuration (used by both frontend and backend)

Always check the relevant context files before making changes.
`,
  },

  claudeCode: {
    name: "Claude Code",
    path: "CLAUDE.md",
    content: `
## AI Starter Resources

This project includes context rules and MCP configuration in \`.ai-starter/\`:

- \`.ai-starter/frontend/context/*.md\` — Frontend-specific context rules
- \`.ai-starter/frontend/mcp/\` — Frontend-specific MCP configuration
- \`.ai-starter/backend/context/*.md\` — Backend-specific context rules
- \`.ai-starter/backend/mcp/\` — Backend-specific MCP configuration
- \`.ai-starter/shared/mcp/\` — Shared MCP configuration (used by both frontend and backend)

Refer to these before implementing features, especially the context files relevant to the current task.
`,
    append: true,
  },

  kiro: {
    name: "Kiro",
    path: ".kiro/steering/ai-starter.md",
    content: `---
inclusion: always
---

# AI Starter Resources

This project uses context rules and MCP configuration stored in \`.ai-starter/\`:

- \`.ai-starter/frontend/context/*.md\` — Frontend-specific context rules
- \`.ai-starter/frontend/mcp/\` — Frontend-specific MCP configuration
- \`.ai-starter/backend/context/*.md\` — Backend-specific context rules
- \`.ai-starter/backend/mcp/\` — Backend-specific MCP configuration
- \`.ai-starter/shared/mcp/\` — Shared MCP configuration (used by both frontend and backend)

Consult these resources when relevant to the current task.
`,
  },
};

export async function writeToolReference(toolKey, projectRoot) {
  const tool = TOOLS[toolKey];
  if (!tool) {
    throw new Error(`Unknown tool: ${toolKey}`);
  }

  const fullPath = path.join(projectRoot, tool.path);
  const dir = path.dirname(fullPath);

  await fs.ensureDir(dir);

  if (tool.append) {
    const exists = await fs.pathExists(fullPath);
    if (exists) {
      await fs.appendFile(fullPath, "\n" + tool.content);
    } else {
      await fs.writeFile(fullPath, tool.content.trim());
    }
  } else {
    await fs.writeFile(fullPath, tool.content);
  }

  return fullPath;
}
