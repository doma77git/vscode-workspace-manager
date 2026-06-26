# VS Code Workspace Manager

> One repo to manage all your VS Code workspaces, profiles, trust settings, and BYOK metadata — with security built in.

## What It Does

| Action | Tool |
|--------|------|
| Create workspace templates from scratch | `WorkspaceManager.ps1` → New template |
| Save existing `.code-workspace` files as reusable templates | `WorkspaceManager.ps1` → Save template |
| Manage VS Code profiles (import / export / list / assign to templates) | `WorkspaceManager.ps1` → Profiles |
| Open any template with a profile via `code --profile` | `WorkspaceManager.ps1` → Open workspace |
| Store DeepSeek BYOK metadata (no real keys — placeholder only) | `WorkspaceManager.ps1` → BYOK |
| Toggle empty workspace trust | `WorkspaceManager.ps1` → Trust |
| Auto-validate JSON and scan for secrets on every push | `.github/workflows/validate.yml` |
| Block commits containing secrets | `.git/hooks/pre-commit` |
| Standalone validation runner | `scripts/Run-Validate.ps1` |
| Full checks (validate + secret scan) | `scripts/Run-Checks.ps1` |
| Run tests (PowerShell syntax + JSON) | `scripts/Run-Tests.ps1` |
| Browse terminal docs from menu | `WorkspaceManager.ps1` → Open docs |
| Scan project for recommended profile | `WorkspaceManager.ps1` → Scan project |
| Auto-open with detected profile | `scripts/Open-WithProfile.ps1` |
| Quick commands via npm | `npm run validate` / `npm run checks` / `npm run open` |
| Quick commands via make | `make validate` / `make checks` / `make install` |
| Self-update from git remote | `scripts/Update-Self.ps1` / `make update` / `npm run update` |
| Run from any directory | `wsm` / `wsm validate` / `wsm test` (if in PATH, or via `C:\VSCode\wsm.cmd`)

## 30-Second Start

```powershell
# Option A: One-liner from the web (Windows/Linux/macOS)
irm https://raw.githubusercontent.com/doma77git/vscode-workspace-manager/main/install.ps1 | iex

# Option B: From local clone
git clone https://github.com/doma77git/vscode-workspace-manager.git C:\VSCode\Templates
cd C:\VSCode\Templates
make install
make manager

# Option C: From any terminal (after install, add to PATH or use stubs)
wsm                     # Launch the interactive menu
wsm validate            # Run validation from anywhere
wsm test                # Run tests from anywhere
```

## Project Map

```
C:\VSCode\Templates\
├── templates/              .code-workspace files you create
├── profiles/               VS Code profiles in JSON
├── meta/                   BYOK metadata + trust settings
├── scripts/                PowerShell scripts (manager, init, validate, checks)
├── docs/                   Full guides (terminal, architecture, trust, etc.)
├── prompts/                Ready-to-paste Reasonix prompts
├── skills/                 Installable Reasonix skills
├── .github/workflows/      CI that lints JSON and scans secrets
├── .github/ISSUE_TEMPLATE/ Bug report and feature request templates
├── .github/PULL_REQUEST_TEMPLATE.md
├── .editorconfig           Consistent editor settings
├── SECURITY.md             Vulnerability reporting and security rules
├── CONTRIBUTING.md         Contribution guidelines
├── LICENSE                 MIT license
├── ONBOARDING.md           Quick-start onboarding
├── CHANGELOG.md            Version history
├── RECOMMENDATIONS.md      Best practices guide
├── HELP.md                 Troubleshooting & FAQ
├── LANDING.md              Project overview
├── deploy-instructions.txt One-time deploy commands
├── wsm.ps1                 Portable launcher (PowerShell, from any directory)
├── wsm.cmd                 Portable launcher (Windows batch, from any directory)
└── README.md               You are here
```

## Key Design Decisions

- **No secrets in the repo** — `.gitignore` excludes BYOK files. The pre-commit hook catches everything else.
- **BYOK is a placeholder** — Stores only metadata and KMS instructions. Replace with your own provider when ready.
- **Profiles are portable** — Export from VS Code, drop into `profiles/`, assign to templates. Open workspaces with `code --profile`.
- **Template variables** — `${PROJECT_NAME}` and `${GIT_REMOTE}` are replaced interactively when creating templates.
- **UTF-8, no BOM** — All files are cleanly encoded. PowerShell 7 compatible.

## Documentation

| File | Purpose |
|------|---------|
| `ONBOARDING.md` | Quick-start onboarding flow |
| `docs/TERMINAL.md` | Terminal profiles, shell integration, and tasks guide |
| `docs/ARCHITECTURE.md` | UML diagrams and architecture overview |
| `docs/SETUP.md` | Prerequisites, detailed setup, verification |
| `docs/WORKFLOW.md` | Day-to-day usage patterns |
| `docs/BYOK-GUIDE.md` | DeepSeek BYOK explained, KMS provider examples |
| `docs/WORKSPACE-TRUST.md` | VS Code workspace trust deep-dive |
| `docs/DEEPSEEK-RECOMMENDATIONS.md` | DeepSeek model tuning and best practices |
| `docs/CI-CD.md` | GitHub Actions workflow and local `act` runs |
| `RECOMMENDATIONS.md` | Best practices for workspace management, security, and team workflows |
| `HELP.md` | Troubleshooting and FAQ |
| `prompts/workspace-manager-prompt.md` | Full spec for regenerating via Reasonix |
| `prompts/usage-prompts.md` | Copy-paste prompts for common tasks |
