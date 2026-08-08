import fs from "fs-extra";
import path from "path";
import { fileURLToPath } from "url";
import inquirer from "inquirer";
import { TOOLS, writeToolReference } from "./toolAdapters.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export async function runInit() {
  const templatesDir = path.join(__dirname, "..", "templates");
  const targetDir = process.cwd();
  const aiStarterDir = path.join(targetDir, ".ai-starter");

  console.log(
    "🚀 Initializing frontend project with AI starter resources...\n",
  );

  try {
    // Step 1: Copy all content to .ai-starter/
    console.log("📦 Creating .ai-starter/ directory...");

    await fs.copy(templatesDir, aiStarterDir, {
      overwrite: false,
      errorOnExist: false,
    });

    console.log("✅ .ai-starter/ created successfully\n");

    // Step 2: Ask user about AI tools
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

    // Step 3: Create reference files for selected tools
    const createdFiles = [".ai-starter/"];

    if (!selectedTools.includes("none") && selectedTools.length > 0) {
      console.log("\n📝 Creating reference files for selected tools...\n");

      for (const toolKey of selectedTools) {
        if (toolKey !== "none") {
          try {
            const filePath = await writeToolReference(toolKey, targetDir);
            const tool = TOOLS[toolKey];
            console.log(
              `✅ ${tool.name}: ${path.relative(targetDir, filePath)}`,
            );
            createdFiles.push(path.relative(targetDir, filePath));
          } catch (error) {
            console.error(
              `❌ Error creating ${TOOLS[toolKey]?.name} reference:`,
              error.message,
            );
          }
        }
      }
    }

    // Final summary
    console.log("\n🎉 Frontend project initialized successfully!");
    console.log("\n📁 Created files and directories:");
    createdFiles.forEach((file) => {
      console.log(`  ✓ ${file}`);
    });

    console.log(
      "\n💡 Tip: Check USAGE.md in the package directory for more information.",
    );
    console.log("Note: Existing files were not overwritten.");
  } catch (error) {
    console.error("❌ Error during initialization:", error.message);
    process.exit(1);
  }
}
