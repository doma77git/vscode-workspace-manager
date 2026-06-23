# Automation & Scheduling — Keep Everything Running

The VS Code Workspace Manager can run itself — validating, backing up, and checking for updates on a schedule you control.

---

## Scheduled Tasks

Three pre-configured tasks:

| Task | Frequency | What it does | Script |
|------|-----------|-------------|--------|
| **Validate** | Daily at 09:00 | Runs `Run-Validate.ps1` — verifies all JSON and workspace files | `Schedule-Tasks.ps1` |
| **Backup** | Weekly at 12:00 | Runs `Auto-Backup.ps1` — creates timestamped archive of templates, profiles, meta | `Schedule-Tasks.ps1` |
| **Update Check** | Monthly at 08:00 | Runs `Update-Self.ps1 -DryRun` — notifies if new version available | `Schedule-Tasks.ps1` |

---

## Setting Up Schedules

### From the Interactive Menu

```
Option 15 → Schedule tasks
  → 1) List current tasks
  → 2) Install all tasks
  → 3) Uninstall all tasks
```

### From PowerShell

```powershell
# See what's scheduled
pwsh -NoProfile -File scripts\Schedule-Tasks.ps1 -Action list

# Install all three tasks
pwsh -NoProfile -File scripts\Schedule-Tasks.ps1 -Action install

# Install only specific tasks
pwsh -NoProfile -File scripts\Schedule-Tasks.ps1 -Action install -Tasks "validate,backup"

# Remove all tasks
pwsh -NoProfile -File scripts\Schedule-Tasks.ps1 -Action uninstall
```

---

## Windows (Task Scheduler)

`Install` creates three tasks in Windows Task Scheduler:
- `VSCodeWS-Validate` — daily at 09:00
- `VSCodeWS-Backup` — weekly at 12:00
- `VSCodeWS-UpdateCheck` — monthly at 08:00

> **Note:** Task Scheduler may require Administrator privileges for registration. Run PowerShell as Administrator if you get permission errors.

View tasks: `taskschd.msc` or `schtasks /query`

---

## Linux / macOS (cron)

`Install` prints the cron job lines to add manually:

```bash
crontab -e
```

Then add the displayed lines. Example:

```
# Daily validation of all JSON and workspace files
0 9 * * * pwsh -NoProfile -File '/home/user/vscode/Templates/scripts/Run-Validate.ps1'

# Weekly backup of templates, profiles, and meta
0 12 * * 1 pwsh -NoProfile -File '/home/user/vscode/Templates/scripts/Auto-Backup.ps1'

# Monthly check for workspace manager updates
0 8 1 * * pwsh -NoProfile -File '/home/user/vscode/Templates/scripts/Update-Self.ps1' -DryRun
```

---

## GitHub Scheduled Checks

A GitHub Actions workflow (`scheduled-checks.yml`) runs every Monday at 09:00 UTC:
- Validates all JSON and workspace files
- Scans for secrets
- Checks project structure
- Creates an issue automatically if anything fails

No setup needed — it runs as long as the repo is on GitHub. View at: `Actions → Scheduled Checks`.

---

## Auto-Backup

Backs up all user data (templates, profiles, meta, prompts) to a timestamped zip:

```powershell
# Back up to default location (exports/)
pwsh -NoProfile -File scripts\Auto-Backup.ps1

# Back up to custom path, keep last 10
pwsh -NoProfile -File scripts\Auto-Backup.ps1 -OutputPath D:\backups -KeepLast 10
```

- Archives are named `backup-yyyyMMdd-HHmmss.zip`
- Older backups are automatically pruned (default: keep last 5)
- Excludes `.git`, `scripts`, `docs`, CI files

---

## Automation Decision Matrix

| I want to… | Best tool |
|------------|----------|
| Validate every day automatically | `Schedule-Tasks.ps1 install` |
| Back up weekly | `Schedule-Tasks.ps1 install -Tasks backup` |
| Get notified of updates monthly | `Schedule-Tasks.ps1 install -Tasks update` |
| Run validation on every push | CI: `validate.yml` |
| Weekly health check with GitHub alert | CI: `scheduled-checks.yml` |
| One-time backup right now | `Auto-Backup.ps1` |
| See what's scheduled | `Schedule-Tasks.ps1 -Action list` |
| Remove all schedules | `Schedule-Tasks.ps1 -Action uninstall` |
