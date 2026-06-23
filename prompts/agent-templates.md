# Agent Templates — Ready-to-Use Configs

Copy-paste agent configurations for Reasonix and other AI coding assistants.

---

## Reasonix System Prompt Snippet

```markdown
You are working on the VS Code Workspace Manager project at C:\VSCode\Templates.
This is a PowerShell toolkit for managing VS Code workspaces, profiles, terminals, and automation.

Key rules:
- Run `make test` before and after any code change
- Use `pwsh -NoProfile -File scripts/<name>.ps1` to execute scripts
- Dot-source `Helper-Functions.ps1` for shared utilities
- Exit 0 on success, 1 on failure
- Never store real secrets in meta/deepseek-byok.json
- Update AGENTS.md + CHANGELOG.md after structural changes

Quick commands:
  make test      → 48 checks (24 PS + 16 JSON + 6 YAML + 2 integration)
  make validate  → JSON + workspace file validation
  make all       → Full pipeline
  make manager   → Launch 15-option menu
```

---

## Reasonix Custom Instructions

```
Project: VS Code Workspace Manager
Stack: PowerShell 7+, VS Code CLI, Git, GitHub Actions
Root: C:\VSCode\Templates (Windows) or ~/vscode/Templates (Linux/macOS)

Always:
- Validate changes with `make test` before committing
- Use `make validate` for quick JSON checks
- Follow the decision tree in AGENTS.md for where to put new files
- Use Write-Banner, Write-Section, Write-Pass/Fail/Warn from Helper-Functions.ps1

Never:
- Store real secrets
- Use Invoke-Expression or cmd /c (shell injection risk)
- Skip tests to force green
- Commit without updating AGENTS.md if structure changes
```

---

## Workspace-Aware Prompt Header

```
You are in the VS Code Workspace Manager project.
This project manages VS Code workspace templates, profiles, terminal configs,
and automation from a single git repository.

Current state: v1.1.0 · 24 scripts · 16 docs · 11 prompts · 5 templates · 4 profiles
Test suite: 48 checks (all green) · 2.8s runtime

When adding features:
- Menu option → WorkspaceManager.ps1 + Invoke-*.ps1 module
- Standalone script → scripts/<Verb>-<Noun>.ps1
- Shared code → Helper-Functions.ps1
- Config → meta/ or .vscode/
- Docs → docs/ or root .md

Quick reference: prompts/run-cookbook.md · prompts/agent-flows.md
```

---

## Agent Task Templates

### "Add a new menu option"
```
Goal: Add menu option N for {feature-name}.

Steps:
- Read scripts/WorkspaceManager.ps1 menu section
- Create function Invoke-{Name} in scripts/Invoke-{Name}.ps1
- Dot-source at top of WorkspaceManager.ps1
- Add Write-Host menu line + switch case
- Update AGENTS.md function count
- Run make test
```

### "Create a workspace template"
```
Goal: Create a .code-workspace template for {stack}.

Steps:
- Read templates/sample-project.code-workspace for format
- Customize settings for {stack} (tab size, formatter, linter)
- Add recommended extensions
- Add build/test tasks
- Validate: pwsh -File scripts/Run-Validate.ps1
```

### "Debug a failing test"
```
Goal: Fix the failing test in {script-name}.

Steps:
- Run: pwsh -File scripts/Run-Tests.ps1 to reproduce
- Read the failing file at reported line
- Determine: production bug or test bug?
- Fix → re-run (max 2 attempts on same failure)
- If still failing → report with context
```
