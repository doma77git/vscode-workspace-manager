# VS Code Workspace Manager

Complete template repository for managing VS Code workspaces, profiles, and trust settings on Windows.

## Directory Structure

```
C:\VSCode\Templates\
├── templates/          .code-workspace template files
├── profiles/           Exported VS Code profiles (JSON)
├── meta/               Metadata, trust, and BYOK placeholders
├── scripts/            PowerShell management scripts
├── docs/               Documentation
├── prompts/            Ready-to-use Reasonix prompts
├── .github/workflows/  CI validation
├── .gitignore
├── .gitattributes
├── deploy-instructions.txt
└── README.md
```

## Quick Start

1. Run the init script once:
   ```
   pwsh -NoProfile -ExecutionPolicy Bypass -File "C:\VSCode\Templates\scripts\Init-TemplatesRepo.ps1"
   ```

2. Launch the interactive Workspace Manager:
   ```
   pwsh -NoProfile -ExecutionPolicy Bypass -File "C:\VSCode\Templates\scripts\WorkspaceManager.ps1"
   ```

## Main Scripts

| Script | Purpose |
|--------|---------|
| `scripts\WorkspaceManager.ps1` | Interactive menu: create/save templates, manage profiles, BYOK, trust, open workspaces |
| `scripts\Init-TemplatesRepo.ps1` | One-time setup: git init, first commit, pre-commit hook |

## Security

- `.gitignore` excludes secrets, keys, tokens, and `.vscode/` workspace storage
- Pre-commit hook scans staged files for patterns: `password`, `secret`, `api_key`, `token`, `private_key`
- BYOK uses a placeholder file — no real keys are stored in the repository
- CI workflow validates JSON and scans for secrets on every push

## Profiles

Export profiles from VS Code (Command Palette → Profiles: Export Profile) and save them to `profiles/`. The Workspace Manager can import, list, and assign profiles to templates.

## Template Variables

Templates support variable placeholders:
- `${PROJECT_NAME}` — replaced with your project name when creating a template
- `${GIT_REMOTE}` — replaced with the Git remote URL

## Documentation

- `docs/SETUP.md` — Prerequisites and step-by-step setup
- `docs/WORKFLOW.md` — Daily usage guide
- `docs/BYOK-GUIDE.md` — DeepSeek BYOK placeholder explanation
- `docs/CI-CD.md` — GitHub Actions CI workflow details
