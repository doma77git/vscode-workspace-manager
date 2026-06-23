# HOWTO — Common Recipes

Step-by-step recipes for common tasks. Copy-paste the commands.

---

## HOWTO: Set Up a New Machine

```powershell
# 1. Install prerequisites
# Download: PowerShell 7+, VS Code, Git

# 2. Clone the manager
git clone <your-remote> C:\VSCode\Templates
cd C:\VSCode\Templates

# 3. Initialize
make install

# 4. Check environment
pwsh -File scripts\Check-Environment.ps1

# 5. Launch
make manager
```

---

## HOWTO: Create a Profile for a New Stack

```powershell
# 1. Open VS Code with no workspace
# 2. Install extensions for your stack
# 3. Configure settings (font, theme, formatter)
# 4. Export: Ctrl+Shift+P → Profiles: Export Profile
# 5. Save to C:\VSCode\Templates\profiles\<stack>-dev.json

# 6. Import to manager
make manager
# → Option 7 → Import profile
```

---

## HOWTO: Add Terminal Profiles

```powershell
# Edit templates/sample-project.code-workspace
# Under terminal.integrated.profiles.windows, add:

"Your Shell Name": {
    "path": "C:\\path\\to\\shell.exe",
    "args": ["--your-flag"],
    "icon": "terminal-powershell"
}

# Validate after editing:
make validate
```

---

## HOWTO: Add a VS Code Task

```powershell
# Edit templates/sample-project.code-workspace
# Under tasks.tasks, add:

{
    "label": "Your Task Name",
    "detail": "What this task does",
    "type": "shell",
    "command": "pwsh",
    "args": ["-NoProfile", "-File", "scripts/Your-Script.ps1"],
    "group": "test",
    "presentation": { "reveal": "always", "panel": "new" }
}

# Validate:
make validate
```

---

## HOWTO: Auto-Open a Project with the Right Profile

```powershell
# Scan to find the best profile
pwsh -File scripts\Recommend-Extensions.ps1 -Path <your-project>

# Auto-open
pwsh -File scripts\Open-WithProfile.ps1 <your-project>

# Or with explicit profile
pwsh -File scripts\Open-WithProfile.ps1 <your-project> -Profile python-dev
```

---

## HOWTO: Back Up Before Making Changes

```powershell
# Quick backup
make backup

# Custom location
pwsh -File scripts\Auto-Backup.ps1 -OutputPath D:\backups -KeepLast 10

# Restore: unzip the backup file from exports/
```

---

## HOWTO: Set Up Scheduled Tasks

```powershell
# Windows
pwsh -File scripts\Schedule-Tasks.ps1 -Action install

# Linux/macOS
pwsh -File scripts\Schedule-Tasks.ps1 -Action install
# Then crontab -e and add the displayed lines
```

---

## HOWTO: Run Full Health Check Before Pushing

```powershell
# Option A: One command
make test

# Option B: Full pipeline
make validate
make checks
make test

# Option C: Environment check
pwsh -File scripts\Check-Environment.ps1
```

---

## HOWTO: Debug a Script

```powershell
# Check a specific script's syntax
pwsh -NoProfile -Command "
  $errors = $null
  $ast = [Management.Automation.Language.Parser]::ParseFile('scripts/MyScript.ps1', [ref]$null, [ref]$errors)
  if ($errors.Count -eq 0) { 'OK' } else { $errors | ForEach-Object { $_.Message } }
"

# Run with verbose output (if script supports it)
pwsh -NoProfile -File scripts\MyScript.ps1 -Verbose

# Check the environment
pwsh -File scripts\Check-Environment.ps1
```

---

## HOWTO: Create a Release

```powershell
# 1. Run all tests
make test

# 2. Update version
# Edit CHANGELOG.md — add [X.Y.Z] section
# Edit scripts/WorkspaceManager.ps1 — update version in Invoke-About

# 3. Commit and tag
git add -A
git commit -m "Release vX.Y.Z"
git tag vX.Y.Z

# 4. Push
git push
git push --tags

# The release workflow auto-creates a GitHub Release
```

---

## HOWTO: Migrate from Another Setup

```powershell
# 1. Export profiles from old machine
# VS Code → Ctrl+Shift+P → Profiles: Export Profile

# 2. Copy .code-workspace files to templates/

# 3. Clone or copy this repo to the new machine

# 4. Import profiles
make manager
# → Option 7 → Import profile

# 5. Assign profiles to templates
# → Option 13 → Scan project → assign
```

---

## HOWTO: Add a New Feature

```powershell
# 1. Create branch
git checkout -b feat/my-feature

# 2. Add your script to scripts/

# 3. Add a menu option (if appropriate)
# Edit scripts/WorkspaceManager.ps1
# Add function + Option N

# 4. Update docs
# AGENTS.md, CHANGELOG.md

# 5. Test
make test

# 6. Commit and push
git add -A
git commit -m "feat: add my-feature"
git push
```
