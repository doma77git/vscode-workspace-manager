# VS Code Workspace Manager — Copilot Instructions

* [Product Vision and Goals](docs/PRD.md): Understand the high-level product vision, target users, and feature set.
* [System Architecture and Design](docs/ARCHITECTURE.md): Overall architecture, design patterns, and layer diagram.
* [Contributing Guidelines](CONTRIBUTING.md): Development workflow, code conventions, and review process.
* [Agent Flows](prompts/agent-flows.md): Decision trees for common agent tasks.
* [Agent Memories](prompts/agent-memories.md): Key facts agents should retain across sessions.

## Critical Rules
- **Always run `make test` before and after any code change**
- Use `pwsh -NoProfile -File scripts/<name>.ps1` to execute scripts
- Dot-source `Helper-Functions.ps1` for shared utilities
- Exit 0 on success, 1 on failure
- **Never store real secrets** in `meta/deepseek-byok.json`
- Update `AGENTS.md` + `CHANGELOG.md` after structural changes

## Project Conventions
- PowerShell: PascalCase functions, 4-space indent
- JSON: 2-space indent. YAML: 2-space indent
- UTF-8 without BOM for all files
- Use Write-Banner, Write-Section, Write-Pass/Fail/Warn from Helper-Functions.ps1
- Box-drawn terminal UI with rounded corners (╭╮╰╯) and emoji icons

Suggest to update these documents if you find any incomplete or conflicting information during your work.
