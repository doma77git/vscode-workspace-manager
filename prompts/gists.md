# Gists — Copy-Paste Snippets & One-Liners

Quick reference snippets for every task. Copy, paste, run.

---

## 🚀 Launch

```powershell
# Full menu
make manager

# PowerShell direct
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts\WorkspaceManager.ps1
```

---

## ✅ Test & Validate

```powershell
# All at once (2.9s)
make all -Quick

# Step by step
make test          # 33 checks: PS AST + JSON + YAML
make validate      # 10 JSON + workspace files
make checks        # Validate + secret scan
make doctor        # Environment health

# JSON output
pwsh -File scripts/Run-Tests.ps1 -Json

# Silent (only errors)
pwsh -File scripts/Run-Tests.ps1 -Quiet
```

---

## 📁 Create

```powershell
# One-line template creation (from project root)
@{
    folders = @(@{path=".."; name="MyProject"})
    settings = @{"editor.formatOnSave"=$true}
} | ConvertTo-Json -Depth 3 | Set-Content templates\my-project.code-workspace -Encoding UTF8

# Validate it
make validate
```

---

## 🚀 Open Projects

```powershell
# Auto-detect profile
pwsh -File scripts\Open-WithProfile.ps1 path\to\project

# Explicit profile
pwsh -File scripts\Open-WithProfile.ps1 path\to\project -Profile python-dev

# Dry-run
pwsh -File scripts\Open-WithProfile.ps1 -DryRun

# Tab-complete profile names (. scripts\Open-WithProfile.ps1 first)
Open-WithProfile.ps1 -Profile <Tab>
```

---

## 🔍 Scan & Recommend

```powershell
# Scan a project
pwsh -File scripts\Recommend-Extensions.ps1 -Path path\to\project

# JSON output for piping
pwsh -File scripts\Recommend-Extensions.ps1 -Path . -Format json

# Generate install commands
pwsh -File scripts\Recommend-Extensions.ps1 -Path . -Format install

# Navigate project
pwsh -File scripts\Navigate-Project.ps1
```

---

## 💾 Backup & Restore

```powershell
# Quick backup
make backup

# Custom location
pwsh -File scripts\Auto-Backup.ps1 -OutputPath D:\backups -KeepLast 10

# Restore: unzip exports/backup-*.zip to C:\VSCode\Templates\
```

---

## 🔄 Update

```powershell
# Pull latest + validate
make update

# Silent
pwsh -File scripts\Update-Self.ps1 -Force

# Preview
pwsh -File scripts\Update-Self.ps1 -DryRun
```

---

## ⏰ Schedule

```powershell
# Install daily/weekly/monthly tasks
pwsh -File scripts\Schedule-Tasks.ps1 -Action install

# See what's scheduled
pwsh -File scripts\Schedule-Tasks.ps1 -Action list

# Remove
pwsh -File scripts\Schedule-Tasks.ps1 -Action uninstall
```

---

## 🧪 One-Liners

```powershell
# Count templates
(ls templates\*.code-workspace).Count

# Count profiles
(ls profiles\*.json).Count

# Find a function
grep -rn "^function " scripts/ | grep "FunctionName"

# Validate single file
pwsh -NoProfile -Command "try { Get-Content 'file.json' | ConvertFrom-Json >`$null; 'OK' } catch { 'FAIL' }"

# Check git status after validate
make validate && git status --short

# Full CI simulation (no push)
make validate && make checks && make test

# Open a doc from terminal
code docs\TERMINAL.md

# Show version
grep "## \[" CHANGELOG.md | head -1

# Quick stats
echo "Scripts: $(ls scripts/*.ps1 | wc -l) | Docs: $(ls docs/*.md | wc -l) | Tests: 33"
```

---

## 📦 npm Quickref

```bash
npm run test      # 33 checks
npm run all       # Full pipeline
npm run open -- . # Auto-open
npm run update    # Self-update
npm run backup    # Backup
npm run doctor    # Health check
```

---

## 📦 Make Quickref

```bash
make test         # 33 checks
make all          # Full pipeline
make validate     # Quick check
make manager      # Launch menu
make update       # Self-update
make backup       # Backup
make doctor       # Health
```

---

## 🎯 Decision Flow

```
Just edited a file?
  → make validate (2s)

About to commit?
  → make test (3s)

About to push?
  → make all (6s)

Something broken?
  → make doctor → read docs/HELP.md

New machine?
  → make install → make doctor → make manager
```
