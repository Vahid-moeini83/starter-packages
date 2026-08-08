#!/usr/bin/env node

import { Command } from "commander";
import { runInit } from "../src/init.js";

const program = new Command();

program
  .name("frontend-starter")
  .description(
    "CLI tool to initialize frontend projects with Kiro configurations",
  )
  .version("0.1.0");

program
  .command("init")
  .description(
    "Initialize frontend project with skills, context, and MCP configurations",
  )
  .action(async () => {
    await runInit();
  });

program.parse();
