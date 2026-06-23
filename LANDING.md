# Landing — VS Code Workspace Manager

> **One repository. Every workspace. Zero trust surprises.**

VS Code Workspace Manager gives you a single source of truth for:
- **Workspace templates** — reusable `.code-workspace` files with variable substitution
- **Profiles** — portable VS Code settings, extensions, and keybindings
- **Workspace Trust** — security boundaries that protect you from malicious code
- **BYOK metadata** — DeepSeek key references without storing secrets

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
│   ├── WorkspaceManager.ps1      ← Interactive menu (9 options)
│   └── Init-TemplatesRepo.ps1    ← One-time git + hook setup
├── templates/                    ← .code-workspace files
├── profiles/                     ← VS Code profile exports
├── meta/
│   ├── trust.json                ← Workspace trust decisions
│   └── deepseek-byok.json        ← BYOK metadata (no keys)
├── docs/                         ← Full documentation
│   ├── ARCHITECTURE.md           ← UML diagrams
│   ├── DEEPSEEK-RECOMMENDATIONS.md
│   ├── WORKSPACE-TRUST.md        ← VS Code trust deep-dive
│   ├── SETUP.md
│   ├── WORKFLOW.md
│   ├── BYOK-GUIDE.md
│   └── CI-CD.md
├── skills/                       ← Installable Reasonix skills
├── prompts/                      ← Copy-paste Reasonix prompts
├── .github/workflows/            ← CI validation
├── HELP.md                       ← Troubleshooting & FAQ
├── ONBOARDING.md                 ← 5-minute onboarding
├── README.md                     ← You are here
└── CHANGELOG.md
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

### Security Pipeline
```
pre-commit hook → blocks secrets locally
        ↓
git push → GitHub CI validates JSON + scans secrets
        ↓
.gitignore → excludes BYOK files, .vscode/, workspaceStorage/
```

---

## Documentation Map

| Need | Read |
|------|------|
| I'm new, get me started | [`ONBOARDING.md`](./ONBOARDING.md) |
| Something is broken | [`HELP.md`](./HELP.md) |
| Understand the architecture | [`docs/ARCHITECTURE.md`](./docs/ARCHITECTURE.md) |
| DeepSeek best practices | [`docs/DEEPSEEK-RECOMMENDATIONS.md`](./docs/DEEPSEEK-RECOMMENDATIONS.md) |
| VS Code trust deep-dive | [`docs/WORKSPACE-TRUST.md`](./docs/WORKSPACE-TRUST.md) |
| Step-by-step setup | [`docs/SETUP.md`](./docs/SETUP.md) |
| Day-to-day usage | [`docs/WORKFLOW.md`](./docs/WORKFLOW.md) |
| BYOK explained | [`docs/BYOK-GUIDE.md`](./docs/BYOK-GUIDE.md) |
| CI pipeline details | [`docs/CI-CD.md`](./docs/CI-CD.md) |
| Reasonix prompt library | [`prompts/`](./prompts/) |
