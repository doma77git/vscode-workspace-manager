# Onboarding — 5 Minutes to Productive

> New here? Follow these steps. You'll be managing workspaces like a pro.

---

## Minute 0 — Prerequisites

```powershell
pwsh --version        # 7+
git --version         # any recent
code --version        # VS Code CLI
```

Missing `code`? Open VS Code → `Ctrl+Shift+P` → `Shell Command: Install 'code' command in PATH`.

---

## Minute 1 — Clone & Init

```powershell
git clone <your-remote> C:\VSCode\Templates
cd C:\VSCode\Templates
pwsh -NoProfile -ExecutionPolicy Bypass -File "scripts\Init-TemplatesRepo.ps1"
```

This creates the git repo, makes first commit, and installs the pre-commit hook. ⌛ Done.

---

## Minute 2 — Launch & Explore

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File "scripts\WorkspaceManager.ps1"
```

You see:

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
  9) Search templates
  0) Exit
```

Pick **1** — it shows your VS Code environment health.

---

## Minute 3 — Create Your First Template

Select **2 → New workspace template**:

```
Template name: quick-test
Project name: Quick Test App
Git remote (optional): https://github.com/me/quick-test.git
Multi-root? (y/n): n
Assign a profile? (y/n): n
```

Saved to `templates\quick-test.code-workspace`. Open it: select **6 → quick-test**.

---

## Minute 4 — Set Workspace Trust

Select **5 → Set Empty Workspace Trust**. Choose:
- `true` — empty windows trusted (default, convenient)
- `false` — empty windows Restricted Mode (safer)

Trust decisions are recorded in `meta/trust.json`.

---

## Minute 5 — Export Your Profile

1. In VS Code, configure settings, extensions, keybindings as you like
2. `Ctrl+Shift+P` → `Profiles: Export Profile`
3. Save the JSON to `C:\VSCode\Templates\profiles\`
4. In WorkspaceManager: **7 → Import profile** → pick your file
5. Next template: assign this profile to it

---

## You're Done. What's Next?

| Want to... | Read |
|------------|------|
| Understand architecture | [`docs/ARCHITECTURE.md`](./docs/ARCHITECTURE.md) |
| Tune DeepSeek | [`docs/DEEPSEEK-RECOMMENDATIONS.md`](./docs/DEEPSEEK-RECOMMENDATIONS.md) |
| Dive into trust | [`docs/WORKSPACE-TRUST.md`](./docs/WORKSPACE-TRUST.md) |
| See daily workflows | [`docs/WORKFLOW.md`](./docs/WORKFLOW.md) |
| Something broken? | [`HELP.md`](./HELP.md) |
| Detailed setup | [`docs/SETUP.md`](./docs/SETUP.md) |
| Use Reasonix prompts | [`prompts/`](./prompts/) |
| BYOK configuration | [`docs/BYOK-GUIDE.md`](./docs/BYOK-GUIDE.md) |

---

## Cheat Sheet

```powershell
# Daily driver
pwsh -NoProfile -ExecutionPolicy Bypass -File "C:\VSCode\Templates\scripts\WorkspaceManager.ps1"

# Quick create and open
# → 2 → enter name → enter → enter → 6 → choose template → done

# Export profile from VS Code
# Ctrl+Shift+P → Profiles: Export Profile → save to C:\VSCode\Templates\profiles\

# Open with specific profile
code --profile python-dev C:\VSCode\Templates\templates\my-app.code-workspace
```
