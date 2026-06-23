# Agent Memories — Key Facts to Retain Across Sessions

Facts an AI agent should remember when working on this project.
Load these at the start of any session.

---

## Project Identity

- **Name:** VS Code Workspace Manager
- **Location:** `C:\VSCode\Templates\` (Windows) or `~/vscode/Templates/` (Linux/macOS)
- **Stack:** PowerShell 7+, VS Code CLI, Git, GitHub Actions
- **Version:** Read from CHANGELOG.md first heading
- **License:** MIT

## Entry Points

- **Menu:** `pwsh -File scripts/WorkspaceManager.ps1` (15 options)
- **Validate:** `make validate` or `pwsh -File scripts/Run-Validate.ps1`
- **Test:** `make test` or `pwsh -File scripts/Run-Tests.ps1`
- **Checks:** `make checks` or `pwsh -File scripts/Run-Checks.ps1`
- **Update:** `make update`
- **Doctor:** `make doctor`

## Critical Conventions

- Always use `pwsh -NoProfile -File` to run scripts, not dot-sourcing
- UTF-8 without BOM for all files
- PowerShell functions: PascalCase (`Invoke-ScanProject`)
- JSON: 2-space indent. PowerShell: 4-space indent
- Emoji in menu + box-drawing headers (╔╗╚╝)
- Green=pass, Red=fail, Yellow=warn, Cyan=header, DarkGray=detail
- Every script exits 0 on success, 1 on failure
- Dot-source `Helper-Functions.ps1` for shared utilities

## File Map

```
scripts/           → 13 .ps1 files (runners, checkers, helpers, backup, scheduler, reco)
templates/         → .code-workspace files
profiles/          → VS Code profile JSON exports
meta/              → trust.json, deepseek-byok.json, *.meta.json
docs/              → 15+ markdown guides
prompts/           → 10 agent prompt/flow/research files
.github/workflows/ → 3 CI workflows (validate, release, scheduled)
```

## Dependency Chain

```
Helper-Functions.ps1 ← (used by 9 scripts)
    ↓
Run-Validate.ps1 ← Run-Checks.ps1, Schedule-Tasks.ps1
Run-Tests.ps1    ← Update-Self.ps1
    ↓
WorkspaceManager.ps1 (calls Run-Validate, Update-Self, Schedule-Tasks via pwsh -File)
```

## Before Making Changes

1. Run `make test` to establish baseline
2. Read AGENTS.md for conventions
3. Check CHANGELOG.md for recent changes
4. Check TODO.md for planned work that might conflict

## After Making Changes

1. Run `make test` to verify nothing broke
2. Update AGENTS.md if structure or commands changed
3. Update CHANGELOG.md with the change
4. If new feature → add to relevant doc and prompts

## Never Do

- Store real secrets in `meta/deepseek-byok.json`
- Use `Invoke-Expression` or `cmd /c` (shell injection risk)
- Skip/disable tests to force green
- Commit without running `make test` first
- Change the Helper-Functions.ps1 API without updating all callers
