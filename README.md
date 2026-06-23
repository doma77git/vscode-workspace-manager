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

## 30-Second Start

```powershell
# 1. Initialize (one time only)
pwsh -NoProfile -ExecutionPolicy Bypass -File "C:\VSCode\Templates\scripts\Init-TemplatesRepo.ps1"

# 2. Launch the manager
pwsh -NoProfile -ExecutionPolicy Bypass -File "C:\VSCode\Templates\scripts\WorkspaceManager.ps1"
```

## Project Map

```
C:\VSCode\Templates\
├── templates/              .code-workspace files you create
├── profiles/               VS Code profiles in JSON
├── meta/                   BYOK metadata + trust settings
├── scripts/                The two PowerShell scripts
├── docs/                   Full guides
├── prompts/                Ready-to-paste Reasonix prompts
├── .github/workflows/      CI that lints JSON and scans secrets
├── .git/hooks/pre-commit   Blocks accidental secret commits
├── ONBOARDING.md           This page
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
| `docs/SETUP.md` | Prerequisites, detailed setup, verification |
| `docs/WORKFLOW.md` | Day-to-day usage patterns |
| `docs/BYOK-GUIDE.md` | DeepSeek BYOK explained, KMS provider examples |
| `docs/CI-CD.md` | GitHub Actions workflow and local `act` runs |
| `prompts/workspace-manager-prompt.md` | Full spec for regenerating via Reasonix |
| `prompts/usage-prompts.md` | Copy-paste prompts for common tasks |
