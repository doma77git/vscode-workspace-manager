# Changelog

All notable changes to the VS Code Workspace Manager.

## [1.1.0] — 2026-06-23

### Added
- 4 new menu options: Run validation checks (10), Open docs (11), About / version (12), Scan project (13)
- `scripts/Run-Validate.ps1` — standalone JSON + workspace validation runner
- `scripts/Run-Checks.ps1` — meta-runner combining validation and secret scanning
- `Makefile` — convenience targets: `make validate`, `make checks`, `make install`, `make doctor`, `make deps`
- `profiles/profile-template.json` — metadata template with tags, description, version, settings, extensions
- `Invoke-ScanProject` — scans a project path for language/framework indicators and suggests matching profiles
- `scripts/Open-WithProfile.ps1` — auto-detects project profile and opens with `code --profile`; supports `-Profile`, `-DryRun`, `-ListMappings`
- `package.json` — npm scripts: `npm run validate`, `npm run checks`, `npm run install`, `npm run doctor`, `npm run open`, `npm run ci`, `npm run manager`
- `scripts/Run-Tests.ps1` — validates PowerShell AST syntax + JSON syntax across all project files
- `.vscode/settings.json` — the repo eats its own dogfood with terminal profiles and editor settings
- `.markdownlint.json` — consistent Markdown rules for all `.md` files
- `.github/dependabot.yml` — auto-update GitHub Actions monthly
- `.github/CODEOWNERS` — assign reviewers per path
- `.github/workflows/release.yml` — auto-create GitHub Release on tag push
- `.cspell.json` — spell-check configuration for project documentation
- `scripts/post-commit` — auto-run tests after each commit
- `docs/FAQ.md` — frequently asked questions
- `Invoke-UpdateCheck` — Option 14: checks current version and remote status
- Cross-platform path detection in `WorkspaceManager.ps1` (Windows/Linux/macOS)
- `scripts/Update-Self.ps1` — self-updater: stash → fetch → merge → restore → validate
- `Invoke-UpdateCheck` now offers to run self-update directly
- `autoUpdateCheck` in `meta/trust.json` — optional startup update notification
- `docs/SELF-UPDATE.md` — complete self-update guide
- `prompts/goals.md` — 10 copy-paste goal templates for common workflows
- `prompts/run-cookbook.md` — every way to run, validate, test, update, and open
- `prompts/learn-path.md` — 9-stage learning path from beginner to master
- `prompts/improve.md` — prompts for evolving and enhancing the project
- `prompts/usage-prompts.md` — expanded with terminal, tasks, scan, self-update, and release prompts
- `scripts/Auto-Backup.ps1` — backs up templates, profiles, meta to timestamped zip; prunes old backups
- `scripts/Schedule-Tasks.ps1` — cross-platform scheduler (Windows Task Scheduler + cron)
- `Invoke-ScheduleTasks` — Option 15: list, install, or uninstall scheduled tasks
- `.github/workflows/scheduled-checks.yml` — weekly CI validation with auto-issue on failure
- `docs/AUTOMATION.md` — complete automation and scheduling guide
- `scripts/Helper-Functions.ps1` — shared utility library (banners, sections, pass/fail/warn, validation, git, counts)
- `scripts/Check-Environment.ps1` — comprehensive environment health check with recommendations
- `scripts/Recommend-Extensions.ps1` — suggests VS Code extensions per stack (table/json/install output)
- `docs/HOWTO.md` — 12 common how-to recipes
- `docs/TUNEUP.md` — tune-up and optimization guide
- `ROADMAP.md` — project roadmap (v1.2.0 → v2.0.0)
- `TODO.md` — tracking document for planned work
- `SUGGESTIONS.md` — future ideas and improvement suggestions
- `ONBOARDING.md` — enhanced with interactive checklist, Minute 7, updated menu display
- `scripts/Navigate-Project.ps1` — interactive project browser (9 options: tree, catalog, docs, menu map, search, read, stats, architecture, dependencies)
- `docs/UML.md` — 7 standalone Mermaid diagrams (system, menu flow, self-update, validation pipeline, data structures, automation, dependency graph)
- `docs/INDEX.md` — master documentation portal with learning path and quick map
- `prompts/agent-flows.md` — decision trees for 8 common agent tasks
- `prompts/agent-research.md` — systematic investigation paths with search commands
- `prompts/agent-memories.md` — key facts agents should retain across sessions
- `AGENTS.md` — added Agent Workflows section with autosuggestions
- `skills/deepseek-byok` — updated with security verification step and CI integration
- `skills/deepseek-reasonix` — updated with prompt library references and full config
- `skills/workspace-manager` — new skill: core operations, decision tree, documentation map
- `Run-Tests.ps1` — added YAML syntax validation; 33 total checks (18 PS + 10 JSON + 5 YAML)
- `Run-All.ps1` — single entry point: test → validate → checks → doctor; -Quick and -Json flags
- `Makefile` — added `make all` target
- `package.json` — added `npm run all` script
- `VSCodeWorkspaceManager.psd1` — PowerShell module manifest for PSGallery publishing
- `VSCodeWorkspaceManager.psm1` — Root module (dot-sources all scripts, exports functions)
- `Open-WithProfile.ps1` — added tab-completion for -Profile parameter (Register-ArgumentCompleter)
- `Run-Tests.ps1` — added -Json and -Quiet flags
- `prompts/gists.md` — copy-paste snippets and one-liners for every operation
- `docs/GRAPHICS.md` — ASCII art and box-drawing style reference
- `.github/workflows/auto-changelog.yml` — validates CHANGELOG on push
- `scripts/pre-push` — blocks push if tests or checks fail
- `wsm.ps1 / wsm.cmd` — portable launcher: `wsm` / `wsm validate` / `wsm test` from any directory
- `vscode.ps1 / vscode.cmd / vscode.sh` — universal launcher: registry + scan discovery, interactive menu, dispatch
- `vscode-tools.json` — tool registry for universal launcher (3 entries: wsm, multiboot, test-backup)
- `skills/vscode-helper` — Reasonix skill: VS Code troubleshooting, REHL, topics
- `docs/reasonix/specs/2026-06-26-vscode-launcher-design.md` — universal launcher design spec
- `docs/reasonix/plans/2026-06-26-vscode-launcher.md` — universal launcher implementation plan
- `tests/` — test fixtures directory (valid-tool.ps1, bad-tool.ps1 for scan testing)
- `WorkspaceManager.ps1` — modularized: 4 Invoke-* functions extracted to separate module files (912→759 lines, -17%)
- `LICENSE` — MIT
- `.github/ISSUE_TEMPLATE/` — bug report, feature request, config
- `.github/PULL_REQUEST_TEMPLATE.md` — structured PR checklist
- `docs/TERMINAL.md` — terminal profiles, shell integration, tasks guide
- Terminal profile configurations in sample workspace (6 profiles)
- Sample tasks in sample workspace (7 tasks: 6 individual + 1 compound)
- `scripts/Import-Export-PM.ps1` — full interop with alefragnani/vscode-project-manager: import, export, auto-discover Git repos (scan), watch-projects.json (sync), tag metadata round-trip
- `vscode-tools.json` — added `pm-import` and `pm-scan` registry entries under Interop category

### Changed
- `.github/workflows/validate.yml` — checks `skills/` dir, new required files (`LICENSE`, `.editorconfig`, `SECURITY.md`, `CONTRIBUTING.md`), terminal profile count, task count, required docs
- `README.md` — updated project map with new files
- `ONBOARDING.md` — added minute 6, updated cheat sheet
- `RECOMMENDATIONS.md` — added Terminal Configuration and Task Automation sections
- `LANDING.md` — updated directory tree and feature list
- `deploy-instructions.txt` — expanded post-deploy checklist
- `AGENTS.md` — reflects all new menu options, run scripts, and conventions
- `meta/deepseek-byok.json` — fixed provider from `"deepseek"` to `"placeholder"`
- `meta/trust.json` — aligned schema with ARCHITECTURE.md (added `trustedParentFolders`, `decisions`, `updatedAt`)

### Security
- Added `SECURITY.md` with vulnerability reporting policy and BYOK security rules
- Added `CONTRIBUTING.md` with security contribution guidelines
- CI now validates all required security-related files exist

## [1.0.0] — 2026-06-23

### Added
- Full directory structure: `templates/`, `profiles/`, `meta/`, `scripts/`, `docs/`, `prompts/`, `.github/workflows/`
- `WorkspaceManager.ps1` — interactive menu with 8 options: Check settings, New template, Save template, BYOK, Trust, Open workspace, Profiles management, Init repo
- `Init-TemplatesRepo.ps1` — one-time setup: git init, first commit, pre-commit hook installation
- Sample workspace template (`sample-project.code-workspace`) with `${PROJECT_NAME}` and `${GIT_REMOTE}` variable placeholders
- Sample VS Code profile (`sample-profile.json`)
- Meta files: `trust.json`, `deepseek-byok.json` (placeholder), `deepseek-keys.json` (placeholder)
- Pre-commit hook scanning for `password|secret|api_key|token|private_key`
- GitHub Actions CI workflow (`validate.yml`): JSON lint, secrets scan, structure check
- `.gitignore` excluding secrets, BYOK files, and workspace storage
- `.gitattributes` for consistent line endings
- `README.md` — landing page with quick-start and project map
- `ONBOARDING.md` — 6-step onboarding guide
- Documentation: `docs/SETUP.md`, `docs/WORKFLOW.md`, `docs/BYOK-GUIDE.md`, `docs/CI-CD.md`
- Prompt files: `prompts/workspace-manager-prompt.md`, `prompts/usage-prompts.md`
- `prompts/reasonix-prompt-reference.md` — full reference covering goal, memo, project, Plan, update, init, todo, instructions, kb, graphical workflow, agentic deployment, pr follow-up, skills
- `deploy-instructions.txt` — one-time deploy commands
- Template-to-profile binding via `meta/<template>.meta.json`
- Interactive variable replacement for `${PROJECT_NAME}` and `${GIT_REMOTE}`
- `code --profile <name> <workspace>` integration for opening workspaces with profiles
- Profile management: list, import, export (instructions)
- DeepSeek BYOK metadata storage with provider-agnostic KMS instructions
- Empty workspace trust toggle
- Validate-JsonFile utility function
- Check-VSCodeSettings inspection of `%APPDATA%\Code\User\settings.json`

### Security
- No real keys or secrets in the repository
- BYOK files (`.json`) excluded from git via `.gitignore`
- Pre-commit hook blocks accidental secret commits
- CI fails on secret detection
- All sensitive patterns documented in security rules

### Conventions
- UTF-8 without BOM for all files
- PowerShell 7 (`pwsh`) compatible
- Windows-native paths

---

## Versioning

This project follows [Semantic Versioning](https://semver.org/).

Types of changes:
- **Added** — new features
- **Changed** — changes in existing functionality
- **Deprecated** — soon-to-be-removed features
- **Removed** — removed features
- **Fixed** — bug fixes
- **Security** — vulnerability fixes
