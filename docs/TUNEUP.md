# Tune-Up Guide — Performance & Polish

Keep the workspace manager running fast and looking sharp.

---

## Fast Startup

| Tip | How | Impact |
|-----|-----|--------|
| Disable auto-update check on startup | Set `autoUpdateCheck: false` in `meta/trust.json` | Saves ~1-2s per launch |
| Use `-NoProfile` flag | Always: `pwsh -NoProfile -File scripts\...` | Skips PS profile load (~0.5-2s) |
| Reduce template count | Archive unused templates to `exports/` | Fewer files to scan |
| Use `make` instead of menu | `make validate` is faster than launching the full menu | Direct execution |

---

## Script Performance

| Script | Optimization | Before → After |
|--------|-------------|----------------|
| `Run-Validate.ps1` | Single `Get-ChildItem -Include` instead of two scans | 2 loops → 1 loop |
| `Run-Tests.ps1` | Already optimized — single pass per file | N/A |
| `WorkspaceManager.ps1` | Git fetch only once per session (cached) | Already optimized |
| `Auto-Backup.ps1` | Uses `Compress-Archive` (native) | Fast |

---

## Terminal Output

- **Box-drawing characters** (╔╗╚╝) — render beautifully in VS Code terminal and Windows Terminal. May show as `?` in older terminals. Switch to ASCII if needed.
- **Emoji** (✅❌🧪🔍) — supported in VS Code 1.60+. Falls back gracefully in older terminals.
- **Colors** — all scripts use `-ForegroundColor` consistently. Green=pass, Red=fail, Yellow=warn, Cyan=header, DarkGray=detail.

---

## Disk Usage

```powershell
# Check exports/ size
Get-ChildItem exports\ -Recurse | Measure-Object Length -Sum

# Clean old backups
make clean
```

- Backups: `exports/backup-*.zip` — keep last 5 by default, configurable with `-KeepLast`
- Templates: negligible (< 1KB each)
- Profiles: ~1-10KB each

---

## Common Slowdowns

| Symptom | Cause | Fix |
|---------|-------|-----|
| Menu takes > 3s to appear | Many templates or slow git fetch | Reduce template count; disable auto-update check |
| Validation slow on first run | Recursive file scan | Subsequent runs are cached; first run is expected |
| `make` not found | Git Bash missing from PATH | Install Git for Windows with Git Bash option |
| `npm run` slow | Node.js startup time | Use `make` instead (~0.1s vs ~0.5s) |

---

## Recommended Settings

In `meta/trust.json`:
```json
{
  "autoUpdateCheck": true,     // Keep enabled for production repos
  "emptyWorkspaceTrust": false  // Safer: require explicit trust
}
```

In `templates/sample-project.code-workspace`:
```json
{
  "terminal.integrated.gpuAcceleration": "auto",
  "terminal.integrated.shellIntegration.enabled": true,
  "terminal.integrated.suggest.quickSuggestions": true
}
```

---

## Update Cycle

| Frequency | Action | Command |
|-----------|--------|---------|
| Daily | Quick validation | `make validate` |
| Weekly | Full checks | `make checks` |
| Monthly | Self-update | `make update` |
| On push | CI validates | Automatic via `validate.yml` |

---

## Tune-Up Checklist

- [ ] Run `make doctor` — check prerequisites
- [ ] Run `make test` — all tests pass
- [ ] Run `make checks` — no secrets
- [ ] Check `exports/` — clean old backups
- [ ] Review `meta/trust.json` — settings correct
- [ ] Run `make update` — latest version
- [ ] Review `ROADMAP.md` — upcoming features
