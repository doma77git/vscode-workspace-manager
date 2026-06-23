# Help — VS Code Workspace Manager

Troubleshooting, FAQ, and quick fixes.

---

## Quick Diagnostic

Run this to check system health:

```powershell
pwsh -NoProfile -Command "& 'C:\VSCode\Templates\scripts\WorkspaceManager.ps1'" 
# Select 1) Check VS Code settings.json
```

This checks: `code` CLI, PowerShell version, template/profile counts, `settings.json` location.

---

## Common Issues

### "code is not recognized"

**Symptom:** `code : The term 'code' is not recognized...`

**Fix:**
1. Open VS Code
2. `Ctrl+Shift+P` → type `Shell Command: Install 'code' command in PATH`
3. Restart terminal

### "Permission denied" when running .ps1

**Symptom:** `...cannot be loaded because running scripts is disabled...`

**Fix:** Use `-ExecutionPolicy Bypass`:
```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File "C:\VSCode\Templates\scripts\WorkspaceManager.ps1"
```

### Pre-commit hook blocks my commit

**Symptom:** `COMMIT BLOCKED: Potential secret in <file>`

**Options:**
1. **If it's a real secret:** Remove it. Never commit secrets.
2. **If it's a false positive** (docs mentioning "password" etc.):
   ```powershell
   git commit --no-verify
   ```
3. **Add the file to `.gitignore`** if it contains legitimate secrets.

### "CursorPosition: The handle is invalid"

**Symptom:** Red error when launching WorkspaceManager in a non-interactive shell.

**Fix:** This is harmless — it's `Clear-Host` failing without a real console. The menu still loads. Ignore it or run in a real terminal.

### Git commit fails with "Author identity unknown"

**Symptom:** `fatal: unable to auto-detect email address`

**Fix:**
```powershell
cd C:\VSCode\Templates
git config user.email "you@example.com"
git config user.name "Your Name"
```

### JSON validation fails in CI

**Symptom:** CI workflow red on "JSON Lint" step.

**Fix:**
1. Check which file failed — the CI log names it
2. Open the file in VS Code — it highlights JSON errors
3. Common causes: trailing commas, unquoted keys, BOM characters

### DeepSeek BYOK file is missing

**Symptom:** `meta/deepseek-byok.json` not found.

**Fix:** Run WorkspaceManager → **4) Set DeepSeek BYOK** → choose a provider. This creates the placeholder file.

### "Workspace Trust" prompt keeps appearing

**Symptom:** Every time you open a folder, VS Code asks about trust.

**Fix:**
1. Trust the folder once (click "Yes, I trust the authors")
2. OR: Trust the parent folder — all subfolders inherit trust
3. OR: Set `security.workspace.trust.enabled` to `false` (not recommended)

---

## FAQ

### Q: Can I use this without git?

Yes. Skip `Init-TemplatesRepo.ps1`. Only run `WorkspaceManager.ps1`. Files still save to `templates/` and `profiles/`. You lose: pre-commit hook, CI validation, version history.

### Q: How do I share templates with my team?

Push to a shared git remote. Team members clone and run `Init-TemplatesRepo.ps1` once. Templates, profiles, and trust metadata are versioned together.

### Q: Are my VS Code settings stored here?

Your **user** settings (`%APPDATA%\Code\User\settings.json`) are not in this repo. Only **workspace** settings (inside `.code-workspace` files) and **profile exports** (`profiles/`) are stored.

### Q: Can I have multiple template repos?

Yes. Create separate repos (e.g., `C:\VSCode\Templates-Python`, `C:\VSCode\Templates-Web`). Each has its own git history, profiles, and trust metadata. Use `WorkspaceManager.ps1` from whichever is relevant.

### Q: What happens if I commit a real secret by accident?

1. **Immediately** rotate the secret in your KMS/provider
2. `git reset HEAD~1` to undo the commit
3. Or use `git filter-branch` / `BFG Repo-Cleaner` to scrub history
4. Force push: `git push --force`
5. The pre-commit hook should have blocked it — if it didn't, check that `.git/hooks/pre-commit` exists

### Q: Does this work on macOS/Linux?

The scripts are PowerShell 7 (`pwsh`), which is cross-platform. Paths reference `C:\VSCode\Templates` — change to `~/VSCode/Templates` or similar. The pre-commit hook is POSIX shell (works everywhere). `.gitattributes` handles line endings.

### Q: How do I reset everything?

```powershell
Remove-Item C:\VSCode\Templates -Recurse -Force
git clone <your-remote> C:\VSCode\Templates
cd C:\VSCode\Templates
pwsh -NoProfile -ExecutionPolicy Bypass -File "scripts\Init-TemplatesRepo.ps1"
```

---

## Error Code Reference

| Code | Meaning | Action |
|------|---------|--------|
| `COMMIT BLOCKED` | Pre-commit hook caught a secret pattern | Remove secret or use `--no-verify` for false positives |
| `CursorPosition invalid` | Running in non-interactive shell | Harmless — ignore |
| `Author identity unknown` | Git user not configured | `git config user.email` + `user.name` |
| `cannot be loaded` | PowerShell execution policy | Add `-ExecutionPolicy Bypass` |
| `code: command not found` | VS Code CLI not in PATH | Install via VS Code Command Palette |
| `ConvertFrom-Json` error | Invalid JSON in template/profile | Fix trailing commas, unquoted keys, BOM |

---

## Still Stuck?

1. Run the diagnostic: WorkspaceManager → option 1
2. Check `docs/SETUP.md` for step-by-step verification
3. File an issue on your repo's issue tracker
4. Review `docs/ARCHITECTURE.md` to understand what touches what
