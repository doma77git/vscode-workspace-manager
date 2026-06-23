# FAQ — VS Code Workspace Manager

## Workspace Templates

**Q: How do I create a template for my project?**
A: Run `WorkspaceManager.ps1` → Option 2 (New workspace template). Enter a name, project name, and optional git remote. Variables `${PROJECT_NAME}` and `${GIT_REMOTE}` are substituted automatically.

**Q: Can I save my existing `.code-workspace` files?**
A: Yes — Option 3 (Save workspace template). It copies your workspace file into `templates/` with a timestamp.

**Q: My template path doesn't work on another machine.**
A: Templates use relative paths (`"path": ".."`). As long as your repo structure is consistent, it works anywhere. Use `${PROJECT_NAME}` and `${GIT_REMOTE}` variables for per-machine customization.

---

## Profiles

**Q: How do I export my VS Code profile?**
A: In VS Code: `Ctrl+Shift+P` → `Profiles: Export Profile` → save the JSON to `C:\VSCode\Templates\profiles\`. Then use Option 7 → Import to register it.

**Q: How do I assign a profile to a template?**
A: When creating a template (Option 2), answer `y` to "Assign a profile?" and pick from the list. Or use `Invoke-ScanProject` (Option 13) to auto-suggest and assign.

**Q: How do I open a workspace with a specific profile?**
A: Use Option 6 (Open workspace), pick the template, and choose the profile. Or use the CLI: `code --profile my-profile templates/my-app.code-workspace`.

---

## Terminal & Tasks

**Q: My terminal doesn't show command decorations (green check/red X).**
A: Shell integration may need manual installation. See `docs/TERMINAL.md` §2 for step-by-step setup for your shell.

**Q: How do I run the pre-configured tasks?**
A: In VS Code: `Terminal → Run Task` → pick from the list. Or from the command line: `pwsh -File scripts/Run-Validate.ps1`.

**Q: I get "command not found" when running a task.**
A: Tasks run as non-login shells. Add your tool's path to the system PATH, or use full executable paths in the task definition.

---

## Security & BYOK

**Q: Can I store my DeepSeek API key in this repo?**
A: **No.** `meta/deepseek-byok.json` stores only metadata and KMS instructions. Real keys must be retrieved at runtime from Azure Key Vault, AWS KMS, or HashiCorp Vault.

**Q: A commit was blocked by the pre-commit hook.**
A: The hook detected a secret pattern (`password`, `secret`, `api_key`, `token`, `private_key`) in a staged file. Remove the secret or use `git commit --no-verify` if it's a false positive.

**Q: How do I change the workspace trust setting?**
A: Option 5 in the menu toggles `emptyWorkspaceTrust`. Trust decisions for specific workspaces are recorded in `meta/trust.json`.

---

## Running & Testing

**Q: How do I run all tests?**
A: `pwsh -File scripts/Run-Tests.ps1` — validates PowerShell syntax and JSON syntax. Also available as `make test` or `npm run test`.

**Q: How do I validate JSON files manually?**
A: `pwsh -File scripts/Run-Validate.ps1`, or `make validate`, or `npm run validate`.

**Q: How do I scan for secrets locally?**
A: `pwsh -File scripts/Run-Checks.ps1`, or `make checks`, or `npm run checks`. The same patterns as CI.

---

## Cross-Platform

**Q: Does this work on macOS or Linux?**
A: The scripts auto-detect the OS and adjust paths accordingly. The terminal profiles and sample workspace are Windows-configured by default — edit the profile paths for other platforms.

**Q: The `code` command is not found.**
A: In VS Code: `Ctrl+Shift+P` → `Shell Command: Install 'code' command in PATH`. On macOS, it should already be available. On Linux, install via your package manager.

---

## CI & Automation

**Q: How do I run CI locally?**
A: `act -W .github/workflows/validate.yml` (requires Docker). Or `make deps`.

**Q: Does Dependabot work?**
A: Yes — `.github/dependabot.yml` auto-updates GitHub Actions monthly. PRs are labeled `ci` and `dependencies`.

---

## Self-Update

**Q: How do I update the workspace manager to the latest version?**
A: `pwsh -File scripts/Update-Self.ps1` — stashes local changes, pulls latest from origin, runs validation, and restores your changes. Also available as `make update` or `npm run update`.

**Q: Can the manager check for updates automatically?**
A: Yes — `autoUpdateCheck` in `meta/trust.json` (default `true`). On each launch, it fetches from origin and shows a notification if new commits are available.

**Q: What if the update has conflicts?**
A: The update is aborted and your local changes are restored from the stash. You'll need to resolve conflicts manually with `git pull`.
