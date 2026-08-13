import fs from "fs-extra";
import path from "path";
import { fileURLToPath } from "url";
import inquirer from "inquirer";
import chalk from "chalk";
import { TOOLS, writeToolReference } from "./toolAdapters.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const TEMPLATES_DIR = path.join(__dirname, "..", "templates");

async function copyContextAndMcp(section, targetDir) {
  const contextSrc = path.join(TEMPLATES_DIR, section, "context");
  const contextDest = path.join(targetDir, ".ai-starter", section, "context");
  await fs.copy(contextSrc, contextDest, { overwrite: true });

  const mcpSrc = path.join(TEMPLATES_DIR, section, "mcp");
  const mcpDest = path.join(targetDir, ".ai-starter", section, "mcp");
  await fs.copy(mcpSrc, mcpDest, { overwrite: true });
}

async function copySharedMcp(targetDir) {
  const mcpSrc = path.join(TEMPLATES_DIR, "shared", "mcp");
  const mcpDest = path.join(targetDir, ".ai-starter", "shared", "mcp");
  await fs.copy(mcpSrc, mcpDest, { overwrite: true });
}

export async function runInit() {
  const targetDir = process.cwd();

  console.log(chalk.cyan("\n🚀 dev-ai-starter — project initialization\n"));

  // Step 1: Project type selection (list — single choice)
  const { projectType } = await inquirer.prompt([
    {
      type: "list",
      name: "projectType",
      message: "What type is this project?",
      choices: [
        { name: "Frontend", value: "frontend" },
        { name: "Backend", value: "backend" },
        { name: "Both (Frontend + Backend)", value: "both" },
      ],
    },
  ]);

  console.log(chalk.gray("\nCopying template files...\n"));

  const updatedSections = [];
  const untouchedSections = [];

  // Copy based on project type
  if (projectType === "frontend" || projectType === "both") {
    try {
      await copyContextAndMcp("frontend", targetDir);
      updatedSections.push("frontend");
    } catch (err) {
      console.error(chalk.red(`  Error copying frontend:`), err.message);
      process.exit(1);
    }
  } else {
    untouchedSections.push("frontend");
  }

  if (projectType === "backend" || projectType === "both") {
    try {
      await copyContextAndMcp("backend", targetDir);
      updatedSections.push("backend");
    } catch (err) {
      console.error(chalk.red(`  Error copying backend:`), err.message);
      process.exit(1);
    }
  } else {
    untouchedSections.push("backend");
  }

  // Always copy shared/mcp (shared only has mcp, no context)
  try {
    await copySharedMcp(targetDir);
    updatedSections.push("shared/mcp");
  } catch (err) {
    console.error(chalk.red(`  Error copying shared/mcp:`), err.message);
    process.exit(1);
  }

  // Step 2: AI tool selection (checkbox — multi-choice)
  const { selectedTools } = await inquirer.prompt([
    {
      type: "checkbox",
      name: "selectedTools",
      message: "Which AI agent tool(s) do you use?",
      choices: [
        { name: "Cursor", value: "cursor" },
        { name: "Claude Code", value: "claudeCode" },
        { name: "Kiro", value: "kiro" },
        { name: "None / Just .ai-starter is enough", value: "none" },
      ],
    },
  ]);

  // Create reference files for selected tools
  const createdRefs = [];

  if (!selectedTools.includes("none") && selectedTools.length > 0) {
    for (const toolKey of selectedTools) {
      if (toolKey !== "none") {
        try {
          const filePath = await writeToolReference(toolKey, targetDir);
          createdRefs.push({
            name: TOOLS[toolKey].name,
            path: path.relative(targetDir, filePath),
          });
        } catch (err) {
          console.error(
            chalk.red(`  Error creating ${TOOLS[toolKey]?.name} reference:`),
            err.message,
          );
        }
      }
    }
  }

  // Final summary
  console.log(chalk.bold("\n--- Summary ---\n"));

  for (const section of updatedSections) {
    console.log(
      chalk.green(`  ✅ .ai-starter/${section}/`) + chalk.gray("  (updated)"),
    );
  }

  for (const section of untouchedSections) {
    console.log(
      chalk.yellow(`  ⏭  .ai-starter/${section}/`) +
        chalk.gray("  (untouched — not selected this run)"),
    );
  }

  if (createdRefs.length > 0) {
    console.log("");
    for (const ref of createdRefs) {
      console.log(
        chalk.green(`  ✅ ${ref.path}`) +
          chalk.gray(`  (${ref.name} reference)`),
      );
    }
  }

  console.log(chalk.cyan("\n🎉 Initialization complete!\n"));
}
