# Contributing — VS Code Workspace Manager

Thanks for contributing! This project manages VS Code workspace templates, profiles, trust settings, and BYOK metadata.

---

## Quick Start

```powershell
# Clone
git clone <remote> C:\VSCode\Templates
cd C:\VSCode\Templates

# One-time setup
pwsh -NoProfile -ExecutionPolicy Bypass -File "scripts\Init-TemplatesRepo.ps1"

# Launch the manager
pwsh -NoProfile -ExecutionPolicy Bypass -File "scripts\WorkspaceManager.ps1"
```

## Development Workflow

1. **Create a new branch** — `git checkout -b feat/your-feature`
2. **Make changes** — Edit scripts, templates, profiles, or docs
3. **Validate JSON** — Run `jq . <file>` on any `.json` or `.code-workspace` files you changed
4. **Test the manager** — Launch `WorkspaceManager.ps1` and verify your change works
5. **Run CI locally** — `act -W .github/workflows/validate.yml`
6. **Commit** — Use clear commit messages. The pre-commit hook will scan for secrets.
7. **Push and open a PR** against `main` or `master`

## What We Accept

| Type | Examples |
|------|----------|
| **Bug fixes** | Broken menu options, incorrect paths, JSON validation errors |
| **Features** | New menu options, template variables, profile management |
| **Security** | Strengthened pre-commit hook, better secret scanning, trust improvements |
| **Documentation** | Clearer guides, updated diagrams, new best-practices content |
| **Skills** | New Reasonix skills for `skills/` directory |

## Guidelines

### Code
- **PowerShell:** PascalCase functions (`New-WorkspaceTemplate`), `-NoProfile -ExecutionPolicy Bypass` compatible
- **Encoding:** UTF-8 without BOM for all files
- **Line endings:** LF for `.json`, `.md`, `.yml`; CRLF for `.ps1`
- **Variables:** Template variables use `${VARIABLE_NAME}` syntax (e.g., `${PROJECT_NAME}`)
- **Error handling:** Use `Write-Host "[ERROR] message" -ForegroundColor Red` for errors, return `$false` from validation functions
- **Write-Host over Write-Output:** Keep interactive feedback; the script is a TUI, not a pipeline

### Security
- **No real secrets in the repo** — Use `.gitignore` + pre-commit hook + CI
- **BYOK metadata only** — Never store actual keys, only references/KMS commands
- **Pre-commit hook additions** — If you add new file types that could carry secrets, update the hook pattern

### Documentation
- Use Mermaid diagrams for architecture and flows (`docs/ARCHITECTURE.md` style)
- Update `CHANGELOG.md` with each significant change
- Keep `README.md` and `LANDING.md` in sync with new features
- Update `AGENTS.md` when changing project structure or commands

### Profiles
- Standard VS Code profile export format (JSON)
- One profile per file under `profiles/`
- Filename matches the profile name

### Templates
- Standard `.code-workspace` JSON format
- Use `${PROJECT_NAME}` and `${GIT_REMOTE}` for variable substitution
- Add extension recommendations relevant to the template's stack

## Directory Structure

```
C:\VSCode\Templates\
├── templates/          .code-workspace templates
├── profiles/           VS Code profile exports
├── meta/               BYOK metadata + trust settings
├── scripts/            WorkspaceManager.ps1 + Init-TemplatesRepo.ps1
├── docs/               Architecture, guides, recommendations
├── prompts/            Reasonix prompt snippets
├── skills/             Installable Reasonix skills
├── .github/workflows/  CI validation
├── SECURITY.md         Security policies (this file)
└── AGENTS.md           Agent memory (AI context file)
```

## Review Process

- PRs need at least one review before merging
- CI must pass (JSON lint, secrets scan, structure check)
- All `.json` files must validate with `jq`
- No new secret patterns should be introduced
