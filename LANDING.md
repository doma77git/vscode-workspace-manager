# Landing — VS Code Workspace Manager

> **One repository. Every workspace. Zero trust surprises.**

VS Code Workspace Manager gives you a single source of truth for:
- **Workspace templates** — reusable `.code-workspace` files with variable substitution
- **Profiles** — portable VS Code settings, extensions, and keybindings
- **Terminal setup** — pre-configured profiles, shell integration, and tasks
- **Workspace Trust** — security boundaries that protect you from malicious code
- **BYOK metadata** — DeepSeek key references without storing secrets
- **Convenience** — npm scripts, Makefile, and standalone runners for CI/CD

---

## Why This Exists

| Problem | Solution |
|---------|----------|
| Workspaces scattered across disk, no version control | All templates in `templates/`, git-tracked |
| Profiles are tied to one machine | Export to `profiles/`, sync anywhere |
| "Do I trust this repo?" — unsure every time | `meta/trust.json` records your decisions |
| Secret keys accidentally committed | Pre-commit hook + `.gitignore` + CI scan |
| Onboarding new team members takes hours | One `git clone` + `Init-TemplatesRepo.ps1` = ready |
| No standard way to open workspaces with profiles | `code --profile <name> <workspace>` — one command |

---

## Quick Start

```powershell
# 1. Clone (or initialize from scratch)
git clone <your-remote> C:\VSCode\Templates
cd C:\VSCode\Templates

# 2. One-time setup
pwsh -NoProfile -ExecutionPolicy Bypass -File "scripts\Init-TemplatesRepo.ps1"

# 3. Launch the manager
pwsh -NoProfile -ExecutionPolicy Bypass -File "scripts\WorkspaceManager.ps1"
```

---

## What's Inside

```
C:\VSCode\Templates\
├── scripts/
│   ├── WorkspaceManager.ps1      ← Interactive menu (14 options)
│   ├── Init-TemplatesRepo.ps1    ← One-time git + hook setup
│   ├── Run-Validate.ps1          ← Standalone JSON validator
│   ├── Run-Checks.ps1            ← Meta-runner (validate + secret scan)
│   ├── Run-Tests.ps1             ← PowerShell AST + JSON syntax tests
│   └── Open-WithProfile.ps1      ← Auto-detect profile and open in VS Code
├── templates/                    ← .code-workspace files
├── profiles/                     ← VS Code profile exports + metadata template
├── meta/
│   ├── trust.json                ← Workspace trust decisions
│   ├── deepseek-byok.json        ← BYOK metadata (no keys)
│   └── deepseek-keys.json        ← Key reference placeholder
├── docs/                         ← Full documentation (9 guides)
├── skills/                       ← Installable Reasonix skills
├── prompts/                      ← Copy-paste Reasonix prompts
├── .vscode/
│   └── settings.json             ← This repo eats its own dogfood
├── .github/
│   ├── workflows/validate.yml    ← CI pipeline
│   ├── dependabot.yml            ← Auto-update GitHub Actions
│   ├── ISSUE_TEMPLATE/           ← Bug + feature templates
│   └── PULL_REQUEST_TEMPLATE.md  ← PR checklist
├── .editorconfig
├── .markdownlint.json            ← Consistent Markdown rules
├── SECURITY.md
├── CONTRIBUTING.md
├── LICENSE                       ← MIT
├── Makefile                      ← make validate / checks / test / install
├── package.json                  ← npm run validate / checks / test / open
├── deploy-instructions.txt
├── CHANGELOG.md
├── RECOMMENDATIONS.md
├── ONBOARDING.md
├── HELP.md
├── LANDING.md
└── README.md
```

---

## Key Features

### Workspace Templates
Create new templates interactively — variables `${PROJECT_NAME}` and `${GIT_REMOTE}` are replaced on the fly. Save existing workspaces as timestamped templates.

### Profile Management
Export from VS Code → drop into `profiles/` → assign to templates → open with `code --profile`. Bulk export all profiles with `Export-AllProfiles`.

### Workspace Trust (VS Code Security)
Based on the [official VS Code Workspace Trust](https://code.visualstudio.com/docs/editing/workspaces/workspace-trust) system:
- **Restricted Mode** blocks AI agents, terminals, tasks, debugging, and extensions
- **Parent folder inheritance** — trust `C:\TrustedRepos` once, all subfolders trusted
- **Shared with Agents window** — trust state applies everywhere
- Our `meta/trust.json` records your decisions with rationale

### DeepSeek BYOK
Metadata-only key management. Choose Azure Key Vault, AWS KMS, or HashiCorp Vault. No real keys ever touch disk.

### Terminal Profiles & Tasks
6 pre-configured Windows terminal profiles (PowerShell 7 fast/full, Windows PowerShell, Git Bash, cmd, WSL). 7 VS Code tasks (JSON validation, CI checks, compound Full Validation). Shell integration with command decorations, sticky scroll, and IntelliSense enabled by default.

### Project Scanning & Auto-Open
Scan any project for language/framework indicators (`package.json`, `pyproject.toml`, `go.mod`, etc.) and get a suggested matching profile. Use `Open-WithProfile.ps1` to auto-detect and open projects in VS Code with the right profile — no manual guessing.

### Convenience Commands
```powershell
# PowerShell
pwsh -File scripts/Run-Tests.ps1        # Full test suite
pwsh -File scripts/Open-WithProfile.ps1 . # Auto-open

# npm
npm run validate    # Validate JSON
npm run test        # Run tests
npm run open -- .   # Auto-open

# Make
make validate       # Validate JSON
make test           # Run tests
```

### Security Pipeline
```
pre-commit hook → blocks secrets locally
        ↓
git push → GitHub CI validates JSON + scans secrets
        ↓
standalone scripts → Run-Validate.ps1 + Run-Checks.ps1 for local checks
        ↓
.gitignore → excludes BYOK files, .vscode/, workspaceStorage/
```

---

## Documentation Map

| Need | Read |
|------|------|
| I'm new, get me started | [`ONBOARDING.md`](./ONBOARDING.md) |
| Common questions | [`docs/FAQ.md`](./docs/FAQ.md) |
| Something is broken | [`HELP.md`](./HELP.md) |
| Understand the architecture | [`docs/ARCHITECTURE.md`](./docs/ARCHITECTURE.md) |
| Set up terminal + tasks | [`docs/TERMINAL.md`](./docs/TERMINAL.md) |
| DeepSeek best practices | [`docs/DEEPSEEK-RECOMMENDATIONS.md`](./docs/DEEPSEEK-RECOMMENDATIONS.md) |
| VS Code trust deep-dive | [`docs/WORKSPACE-TRUST.md`](./docs/WORKSPACE-TRUST.md) |
| Step-by-step setup | [`docs/SETUP.md`](./docs/SETUP.md) |
| Day-to-day usage | [`docs/WORKFLOW.md`](./docs/WORKFLOW.md) |
| BYOK explained | [`docs/BYOK-GUIDE.md`](./docs/BYOK-GUIDE.md) |
| CI pipeline details | [`docs/CI-CD.md`](./docs/CI-CD.md) |
| General best practices | [`RECOMMENDATIONS.md`](./RECOMMENDATIONS.md) |
| Reasonix prompt library | [`prompts/`](./prompts/) |
