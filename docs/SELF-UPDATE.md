# Self-Update — Keeping the Workspace Manager Current

The VS Code Workspace Manager can update itself from its git remote — pulling the latest version, running validation, and preserving your local changes.

---

## How It Works

```
git fetch origin → git merge origin/<branch> → stash local changes → merge → restore stash → validate
```

1. **Stash** — Your local uncommitted changes are safely stashed
2. **Fetch + merge** — Latest version is pulled from `origin/<current-branch>`
3. **Restore** — Local changes are unstashed back into your working tree
4. **Validate** — `Run-Tests.ps1` runs to confirm the update didn't break anything
5. **Report** — New version number is shown if different

If the merge has conflicts, the update is aborted and your stash is restored.

---

## Ways to Update

### From the Interactive Menu
Option **14 → Check for updates** — shows current version, remote URL, and offers "Run self-update now?"

### From PowerShell
```powershell
# Interactive (confirms before updating)
pwsh -NoProfile -File scripts\Update-Self.ps1

# Silent (no confirmation)
pwsh -NoProfile -File scripts\Update-Self.ps1 -Force

# Dry-run (shows what would happen)
pwsh -NoProfile -File scripts\Update-Self.ps1 -DryRun

# Silent + skip post-update tests
pwsh -NoProfile -File scripts\Update-Self.ps1 -Force -SkipTests
```

### From Make
```bash
make update
```

### From npm
```bash
npm run update
```

---

## Auto-Update Check on Startup

The workspace manager can automatically check for updates when you launch it. Controlled by `autoUpdateCheck` in `meta/trust.json`:

```json
{
  "autoUpdateCheck": true
}
```

- **`true`** (default) — Checks for new commits on every launch. If new commits are found, shows a yellow notification with the count.
- **`false`** — No automatic check. Use Option 14 manually.

The check is non-blocking — it runs a `git fetch` in the background and only notifies if there are new commits upstream.

---

## Safety

| What | Behavior |
|------|----------|
| Local uncommitted changes | Stashed before update, restored after |
| Merge conflicts | Update aborted, stash restored, error shown |
| Post-update tests fail | Warning shown, update is still applied |
| No git remote | Error — self-update requires `origin` |
| Not a git repo | Error — self-update requires git |

---

## Version Tracking

Versions are read from `CHANGELOG.md`. When you cut a new release:

1. Update the version in `CHANGELOG.md` (e.g., `## [1.2.0]`)
2. Push a tag: `git tag v1.2.0 && git push --tags`
3. The release workflow (`release.yml`) creates a GitHub Release automatically
4. Users running `Update-Self.ps1` or the auto-check will see the new version

---

## Troubleshooting

**Q: Update fails with "Not a git repository"**
A: Self-update only works if you cloned the repo with `git clone`. If you downloaded a ZIP, re-clone.

**Q: Stash conflicts when restoring**
A: Your local changes may conflict with files modified in the update. Run `git stash list` to see stashed changes and `git stash pop` to manually restore.

**Q: "Permission denied" when running the script**
A: Always use `-ExecutionPolicy Bypass`: `pwsh -NoProfile -ExecutionPolicy Bypass -File scripts\Update-Self.ps1`
