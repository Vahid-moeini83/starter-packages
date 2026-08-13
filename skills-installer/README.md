# Skills Installer (Interactive)

Interactive, selective installation of Agent Skills on your system —
one machine-wide setup, independent from the `dev-ai-starter` package
(which handles per-project context/mcp files, not skills).

## How it works

Running the script walks you through three steps:

1. **Choose an area** — Frontend, Backend, or Both.
2. **Pick skills** — a list is shown, grouped into sections
   (`Frontend`, `Backend` if relevant, and always `Shared`). You choose
   exactly which skills you want — nothing is installed automatically.
3. **Confirm** — a summary of your selection is shown before anything
   is installed.

Skills with no verified source yet are marked `(no source yet)` in the
list; selecting one is skipped automatically with a note in the final
summary.

## Usage

### Windows (PowerShell)

```powershell
iwr https://raw.githubusercontent.com/Vahid-moeini83/starter-packages/main/skills-installer/install.ps1 -OutFile install.ps1
.\install.ps1
```

Navigate the area menu with the arrow keys and Enter. In the skills
list: **Space** toggles a skill, **A** toggles all, **Enter** confirms
the selection.

### Linux / macOS (bash)

```bash
curl -fsSL https://raw.githubusercontent.com/Vahid-moeini83/starter-packages/main/skills-installer/install.sh | bash
```

Requires `jq` (`sudo apt install jq` or `brew install jq`). You'll be
prompted to enter a comma-separated list of numbers (e.g. `1,3,5`) or
type `all`.

## Installation target

Every installed skill goes to all three agents below, globally on your
machine (not per-project):

```
-g -a claude-code -a cursor -a kiro-cli -y
```

To change the target agents, edit this line in both `install.sh` and
`install.ps1`.

## Adding a new skill (maintenance)

Add an entry to the relevant category (`frontend`, `backend`, or
`shared`) in `skills-manifest.json`, then push to GitHub:

```json
{
  "name": "skill-name",
  "source": "https://github.com/owner/repo",
  "skill": "exact-skill-name-in-repo"
}
```

If the source repo only has one skill and `--skill` isn't needed, set
`skill` to `null`. No changes to `install.sh` / `install.ps1` are
needed — both scripts read the manifest dynamically and will show the
new entry the next time someone runs them.

## Current manifest status

`non-agents-official` still has `source: null` and will show as
"(no source yet)" in the list; selecting it is a no-op (skipped with a
note). Fill in its `source` once verified on skills.sh.
