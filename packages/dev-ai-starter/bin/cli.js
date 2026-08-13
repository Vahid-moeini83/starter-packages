#!/usr/bin/env node

import { Command } from "commander";
import { runInit } from "../src/init.js";

const program = new Command();

program
  .name("dev-ai-starter")
  .description(
    "CLI tool to initialize frontend, backend, or full-stack projects with AI agent configurations",
  )
  .version("0.1.0");

program
  .command("init")
  .description(
    "Initialize project with skills, context rules, and MCP configurations",
  )
  .action(async () => {
    await runInit();
  });

program.parse();
