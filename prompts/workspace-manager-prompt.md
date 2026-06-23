# Workspace Manager Prompt — Full Specification

## Task
Create a complete VS Code Templates repository and Workspace Manager on Windows at `C:\VSCode\Templates`.

## Directory Structure
```
C:\VSCode\Templates\
├── templates/          .code-workspace templates
├── profiles/           Exported VS Code profiles (JSON)
├── meta/               Metadata, trust, and BYOK placeholders
├── scripts/            PowerShell management scripts
├── docs/               Documentation
├── prompts/            Ready-to-use prompts
├── .github/workflows/  CI validation
├── .gitignore
├── .gitattributes
├── deploy-instructions.txt
└── README.md
```

## Main Scripts

### WorkspaceManager.ps1
Interactive menu with options:
1. Check VS Code settings.json
2. New workspace template (interactive, variable replacement)
3. Save workspace template (timestamped)
4. Set DeepSeek BYOK (store placeholder)
5. Set Empty Workspace Trust (toggle)
6. Open workspace (list templates, choose, open with code CLI, optional profile)
7. Profiles management (list / import / export)
8. Init repo (call Init-TemplatesRepo.ps1)
0. Exit

### Init-TemplatesRepo.ps1
- Creates .gitignore, README.md, sample template, sample profile
- git init, git add ., git commit
- Installs pre-commit hook

## Security
- .gitignore excludes: .vscode/, workspaceStorage/, *.secret, deepseek-byok.json, secrets.json, *.env, .local, .git/
- Pre-commit hook scans for: password|secret|api[_-]?key|token|private_key
- CI validates JSON and scans for secrets
- No real keys committed to the repository

## Template Variables
- `${PROJECT_NAME}` — project name
- `${GIT_REMOTE}` — Git remote URL

## Profiles
- Export from VS Code → save to profiles/
- Import/List/Export via WorkspaceManager
- Assign profile to template → saved to meta/<template>.meta.json

## BYOK
- Placeholder only — metadata and KMS instructions
- User replaces with real KMS calls (Azure Key Vault, AWS KMS, HashiCorp Vault)

## Encoding
- UTF-8 without BOM for all files
- PowerShell 7 (pwsh) compatible
