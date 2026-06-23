---
name: workspace-manager
description: Manage VS Code workspace templates, profiles, terminal config, tasks, validation, and automation using the Workspace Manager toolkit.
type: project
runAs: inline
allowedTools: [read_file, write_file, edit_file, bash, ask, grep, glob]
---

# VS Code Workspace Manager — Core Operations

Full toolkit for managing VS Code workspaces, profiles, terminal settings, and automation from a single repository.

## When to use
- User says "workspace", "template", "profile", "VS Code config", "terminal setup", "task"
- User needs to create/modify workspace templates or profiles
- User needs to validate, test, or run checks on the project
- User wants to automate workspace management

## Quick Commands

```powershell
make test       # Full test suite (PowerShell AST + JSON)
make validate   # JSON + workspace file validation
make checks     # Validation + secret scan
make doctor     # Environment health check
make manager    # Launch the 15-option menu
make update     # Self-update from git remote
make backup     # Back up templates/profiles/meta
```

## Project Structure

```
scripts/   → 13 PowerShell scripts (runners, checkers, helpers, backup, scheduler, reco, navigator)
templates/ → .code-workspace files (with ${PROJECT_NAME} / ${GIT_REMOTE} variables)
profiles/  → VS Code profile JSON exports
meta/      → trust.json + deepseek-byok.json + <template>.meta.json
docs/      → 15+ guides (INDEX.md for the portal)
prompts/   → 10 agent instruction files (agent-flows, goals, run-cookbook, etc.)
```

## Common Tasks

### Create a workspace template
1. Launch menu: `make manager` → Option 2
2. Or prompt: "Create a new workspace template for {stack} with {features}"
3. Templates go in `templates/` as `.code-workspace` files
4. Validate: `make validate`

### Set up terminal profiles
1. Read `templates/sample-project.code-workspace` for the current config
2. Add profiles under `terminal.integrated.profiles.windows`
3. Validate JSON after editing: `make validate`

### Add VS Code tasks
1. Read `templates/sample-project.code-workspace` → `tasks.tasks` array
2. Add task objects with `label`, `type`, `command`, `args`, `group`, `detail`
3. Use `dependsOn` for compound tasks
4. Validate: `make validate`

### Scan a project for recommendations
```powershell
# From menu: Option 13
# Or from command line:
pwsh -File scripts/Recommend-Extensions.ps1 -Path <project-path>
pwsh -File scripts/Open-WithProfile.ps1 <project-path>
```

### Run validation before committing
```powershell
make test       # Full: PS syntax + JSON + workspace
make checks     # Validation + secret scan
make doctor     # Environment prerequisites
```

### Self-update
```powershell
make update                    # Pull latest + validate
# Or menu: Option 14 → y
```

## Conventions

- **Always run `make test` before committing changes**
- UTF-8 without BOM for all files
- PowerShell: PascalCase functions, `-NoProfile -File` execution
- JSON: 2-space indent. PowerShell: 4-space indent
- Use `Helper-Functions.ps1` for shared utilities (Write-Banner, Write-Section, Write-Pass/Fail)
- Exit 0 on success, 1 on failure
- **Never store real secrets** in `meta/deepseek-byok.json`
- Update `AGENTS.md` + `CHANGELOG.md` after any structural change

## Decision Tree

```
Making a change?
├─ Adding a feature
│   ├─ User-facing menu → WorkspaceManager.ps1
│   ├─ Automated task → scripts/<Verb>-<Noun>.ps1
│   ├─ Shared utility → Helper-Functions.ps1
│   ├─ Config/settings → meta/ or .vscode/
│   └─ Documentation → docs/ or root .md
├─ Fixing a bug
│   ├─ Reproduce → Read file → Fix → make test
│   └─ If user-facing → update relevant doc
└─ Reviewing
    ├─ Focus on scripts that execute commands
    └─ Report: severity + file:line + fix direction
```

## Documentation Map

```
Getting Started → ONBOARDING.md → LANDING.md → README.md
Architecture    → ARCHITECTURE.md → UML.md → ROADMAP.md
Features        → TERMINAL.md → WORKSPACE-TRUST.md → BYOK-GUIDE.md
Operations      → HOWTO.md → TUNEUP.md → FAQ.md → HELP.md
Automation      → AUTOMATION.md → SELF-UPDATE.md
Agent Help      → agent-flows.md → agent-research.md → agent-memories.md
```
