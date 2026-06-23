# Changelog

All notable changes to the VS Code Workspace Manager.

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
