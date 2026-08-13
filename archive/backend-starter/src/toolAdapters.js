import fs from "fs-extra";
import path from "path";

// تعریف ابزارهای AI و فایل‌های reference مربوط به هرکدوم
export const TOOLS = {
  cursor: {
    name: "Cursor",
    path: ".cursor/rules/ai-starter.mdc",
    content: `---
description: Reference to shared AI starter resources
alwaysApply: true
---

# AI Starter Resources

This project uses shared skills, context rules, and MCP configuration stored in \`.ai-starter/\`.
Please read the relevant files there:

- Skills: \`.ai-starter/skills/<skill-name>/SKILL.md\`
- Context/Rules: \`.ai-starter/context/*.md\`
- MCP config: \`.ai-starter/mcp/\`

Always check \`.ai-starter/context/\` for relevant project rules before making changes,
and \`.ai-starter/skills/\` for reusable skill instructions.
`,
  },

  claudeCode: {
    name: "Claude Code",
    path: "CLAUDE.md",
    content: `
## AI Starter Resources

This project includes shared skills, context rules, and MCP configuration in \`.ai-starter/\`:

- Skills: \`.ai-starter/skills/<skill-name>/SKILL.md\`
- Context/Rules: \`.ai-starter/context/*.md\`
- MCP config: \`.ai-starter/mcp/\`

Refer to these before implementing features, especially the context/rules files relevant to the task at hand.
`,
    append: true, // این فایل رو append می‌کنیم اگر وجود داشت
  },

  kiro: {
    name: "Kiro",
    path: ".kiro/steering/ai-starter.md",
    content: `---
inclusion: always
---

# AI Starter Resources

This project uses shared skills, context rules, and MCP configuration stored in \`.ai-starter/\`:

- Skills: \`.ai-starter/skills/<skill-name>/SKILL.md\`
- Context/Rules: \`.ai-starter/context/*.md\`
- MCP config: \`.ai-starter/mcp/\`

Consult these resources when relevant to the current task.
`,
  },
};

/**
 * فایل reference مربوط به یک ابزار AI رو می‌سازه
 * @param {string} toolKey - کلید ابزار از TOOLS (cursor, claudeCode, kiro)
 * @param {string} projectRoot - مسیر ریشه پروژه
 */
export async function writeToolReference(toolKey, projectRoot) {
  const tool = TOOLS[toolKey];
  if (!tool) {
    throw new Error(`Unknown tool: ${toolKey}`);
  }

  const fullPath = path.join(projectRoot, tool.path);
  const dir = path.dirname(fullPath);

  // مطمئن شو که دایرکتوری والد وجود داره
  await fs.ensureDir(dir);

  if (tool.append) {
    // برای فایل‌هایی مثل CLAUDE.md که باید append بشه
    const exists = await fs.pathExists(fullPath);

    if (exists) {
      // اگر فایل وجود داشت، محتوا رو به انتهاش اضافه کن
      await fs.appendFile(fullPath, "\n" + tool.content);
    } else {
      // اگر نبود، فایل جدید بساز
      await fs.writeFile(fullPath, tool.content.trim());
    }
  } else {
    // برای فایل‌های جدید، مستقیماً بنویس
    await fs.writeFile(fullPath, tool.content);
  }

  return fullPath;
}
