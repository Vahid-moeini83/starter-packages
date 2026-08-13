#!/usr/bin/env node

import { Command } from "commander";
import { runInit } from "../src/init.js";

const program = new Command();

program
  .name("backend-starter")
  .description(
    "CLI tool to initialize backend projects with Kiro configurations",
  )
  .version("0.1.0");

program
  .command("init")
  .description(
    "Initialize backend project with skills, context, and MCP configurations",
  )
  .action(async () => {
    await runInit();
  });

program.parse();
