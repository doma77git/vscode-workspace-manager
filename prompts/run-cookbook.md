# Run Cookbook — Every Way to Execute

Quick reference for all project operations. Copy-paste any command.

---

## 🏃 Quick Start

```powershell
# Launch the interactive menu (14 options)
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts\WorkspaceManager.ps1

# One-time repo initialization
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts\Init-TemplatesRepo.ps1
```

---

## ✅ Validation & Testing

```powershell
# Validate all JSON + workspace files
pwsh -NoProfile -File scripts\Run-Validate.ps1

# Full checks (validate + secret scan)
pwsh -NoProfile -File scripts\Run-Checks.ps1

# Full test suite (PowerShell AST + JSON syntax)
pwsh -NoProfile -File scripts\Run-Tests.ps1
```

---

## 🚀 Opening Projects

```powershell
# Auto-detect profile and open current directory
pwsh -NoProfile -File scripts\Open-WithProfile.ps1

# Auto-detect and open specific path
pwsh -NoProfile -File scripts\Open-WithProfile.ps1 path\to\project

# Explicit profile override
pwsh -NoProfile -File scripts\Open-WithProfile.ps1 -Profile web-dev

# Dry-run (preview without opening)
pwsh -NoProfile -File scripts\Open-WithProfile.ps1 -DryRun

# Show indicator→profile mapping table
pwsh -NoProfile -File scripts\Open-WithProfile.ps1 -ListMappings
```

---

## 🔄 Self-Update

```powershell
# Interactive update (confirms before pulling)
pwsh -NoProfile -File scripts\Update-Self.ps1

# Silent update (no confirmation)
pwsh -NoProfile -File scripts\Update-Self.ps1 -Force

# Preview what would happen
pwsh -NoProfile -File scripts\Update-Self.ps1 -DryRun

# Silent update, skip post-update tests
pwsh -NoProfile -File scripts\Update-Self.ps1 -Force -SkipTests
```

---

## 📦 Make Targets

```bash
make help       # Show all targets
make validate   # Run-Validate.ps1
make checks     # Run-Checks.ps1
make test       # Run-Tests.ps1
make install    # Init-TemplatesRepo.ps1
make update     # Update-Self.ps1 -Force
make doctor     # Check prerequisites
make deps       # Run CI locally (act)
make clean      # Remove exports/
```

---

## 📦 npm Scripts

```bash
npm run validate   # Run-Validate.ps1
npm run checks     # Run-Checks.ps1
npm run test       # Run-Tests.ps1
npm run install    # Init-TemplatesRepo.ps1
npm run open -- .  # Open-WithProfile.ps1
npm run update     # Update-Self.ps1 -Force
npm run ci         # Run CI locally (act)
npm run manager    # WorkspaceManager.ps1
npm run doctor     # Check prerequisites
```

---

## 🔧 Individual Operations

```powershell
# Check specific JSON file
jq . file.json

# Check prerequisites
pwsh --version; code --version; git --version

# List all templates
Get-ChildItem templates\ -Filter *.code-workspace

# List all profiles
Get-ChildItem profiles\ -Filter *.json

# Open a workspace with explicit profile
code --profile my-profile templates\my-app.code-workspace

# Run CI locally
act -W .github/workflows/validate.yml

# View changelog
code CHANGELOG.md
```

---

## 🧪 One-Liner Validation

```powershell
# Validate everything in one line (from project root)
pwsh -NoProfile -Command "Get-ChildItem -Recurse -Include '*.json','*.code-workspace' -Exclude '.git' | ForEach-Object { try { \$null = Get-Content \$_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json; Write-Host \\\"OK: \$(\$_.Name)\\\" -F Green } catch { Write-Host \\\"FAIL: \$(\$_.Name)\\\" -F Red; exit 1 } }"
```

---

## 📊 Command Decision Matrix

| I want to… | Best command |
|------------|-------------|
| Start working | `pwsh -File scripts\WorkspaceManager.ps1` |
| Validate after editing | `make validate` |
| Full pre-push check | `make checks` |
| Run all tests | `make test` |
| Open a project | `pwsh -File scripts\Open-WithProfile.ps1 path` |
| Update to latest | `make update` |
| Check if updates available | `pwsh -File scripts\WorkspaceManager.ps1` → Option 14 |
| Create a template | `WorkspaceManager.ps1` → Option 2 |
| Assign a profile | `WorkspaceManager.ps1` → Option 13 (scan) |
| See what I have | `WorkspaceManager.ps1` → Option 12 (about) |
| Read a guide | `WorkspaceManager.ps1` → Option 11 (open docs) |
| Fix something | `code docs/HELP.md` |
