# Onboarding — VS Code Workspace Manager

Welcome. This page gets you from zero to productive in under 5 minutes.

---

## Step 1 — Prerequisites (30 seconds)

Open a terminal and check:

```powershell
pwsh --version        # Must be 7+
git --version         # Any recent version
code --version        # VS Code CLI
```

If `code` is missing: open VS Code → `Ctrl+Shift+P` → `Shell Command: Install 'code' command in PATH`.

---

## Step 2 — Initialize (10 seconds)

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File "C:\VSCode\Templates\scripts\Init-TemplatesRepo.ps1"
```

This creates the git repo, stages everything, makes the first commit, and installs the pre-commit hook. Run once.

---

## Step 3 — Launch the Manager

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File "C:\VSCode\Templates\scripts\WorkspaceManager.ps1"
```

You'll see:

```
========================================
  VS Code Workspace Manager
  C:\VSCode\Templates
========================================

  1) Check VS Code settings.json
  2) New workspace template
  3) Save workspace template
  4) Set DeepSeek BYOK
  5) Set Empty Workspace Trust
  6) Open workspace
  7) Profiles management
  8) Init repo
  0) Exit
```

---

## Step 4 — First Workflow

### Create your first template

1. Select **2) New workspace template**
2. Enter a name: `my-project`
3. Enter project name: `My App`
4. Enter Git remote (or leave blank)
5. Multi-root? `n` for now
6. Assign a profile? Skip for now

Your template is saved to `templates\my-project.code-workspace`.

### Open it

1. Select **6) Open workspace**
2. Choose `my-project.code-workspace`
3. VS Code opens with your workspace

---

## Step 5 — Add a Profile (optional)

1. In VS Code, configure your settings, extensions, and keybindings
2. `Ctrl+Shift+P` → `Profiles: Export Profile` → save the JSON to `C:\VSCode\Templates\profiles\`
3. In Workspace Manager: **7) Profiles management** → **2) Import profile**
4. Pick the file you exported
5. Next time you create a template, assign the profile to it

---

## Step 6 — BYOK (Bring Your Own Key)

The DeepSeek BYOK file at `meta\deepseek-byok.json` is a **placeholder** — no real keys. When you're ready:

1. Choose a KMS provider (Azure Key Vault, AWS KMS, HashiCorp Vault)
2. Run Workspace Manager → **4) Set DeepSeek BYOK**
3. Follow the prompts — only metadata is stored, never the key itself
4. At runtime, your app calls the KMS API to retrieve the real key

Full guide: `docs/BYOK-GUIDE.md`

---

## Security That Works

### Pre-commit hook

Try committing a file containing `password = xyz` — it will be blocked. The hook scans for:

```
password | secret | api_key | api-key | token | private_key
```

If you need to bypass for documentation files: `git commit --no-verify`

### CI pipeline

Push to GitHub and `.github/workflows/validate.yml` runs automatically:
- Lints every `.json` and `.code-workspace` file
- Scans every file for secrets
- Fails the build if anything is wrong

Run locally: `act -W .github/workflows/validate.yml`

---

## Files You Should Know

| File | Why |
|------|-----|
| `templates/*.code-workspace` | Your workspace templates — edit, share, version |
| `profiles/*.json` | Exported VS Code profiles — portable settings |
| `meta/trust.json` | Toggle `emptyWorkspaceTrust` for all workspaces |
| `meta/deepseek-byok.json` | BYOK metadata (excluded from git) |
| `.git/hooks/pre-commit` | Secret scanner — blocks bad commits |
| `.github/workflows/validate.yml` | CI that runs on push |

---

## Quick Reference

```powershell
# Create a template
pwsh -NoProfile -ExecutionPolicy Bypass -File "C:\VSCode\Templates\scripts\WorkspaceManager.ps1"
# → Select 2

# Open a workspace with a profile
pwsh -NoProfile -ExecutionPolicy Bypass -File "C:\VSCode\Templates\scripts\WorkspaceManager.ps1"
# → Select 6

# Export your current VS Code profile
# VS Code → Ctrl+Shift+P → Profiles: Export Profile → Save to C:\VSCode\Templates\profiles\

# Rebuild everything from scratch
pwsh -NoProfile -ExecutionPolicy Bypass -File "C:\VSCode\Templates\scripts\Init-TemplatesRepo.ps1"
```

---

## Next

- `docs/WORKFLOW.md` — daily usage patterns
- `docs/BYOK-GUIDE.md` — KMS integration details
- `prompts/usage-prompts.md` — Reasonix prompt snippets
