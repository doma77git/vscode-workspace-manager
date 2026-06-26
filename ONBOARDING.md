# Onboarding — 7 Minutes to Productive

> New here? Follow these steps. You'll be managing workspaces like a pro.

**Checklist:** `[ ]` Mark as you go — takes ~7 minutes total.

- [ ] Minute 0: Check prerequisites
- [ ] Minute 1: Clone & initialize
- [ ] Minute 2: Launch & explore the menu
- [ ] Minute 3: Create your first workspace template
- [ ] Minute 4: Set workspace trust
- [ ] Minute 5: Export your VS Code profile
- [ ] Minute 6: Run validation checks
- [ ] Minute 7: Explore advanced features

---

## ⚡ Quick Start (if you know what you're doing)

```powershell
git clone <remote> C:\VSCode\Templates && cd C:\VSCode\Templates
make install
make manager
```

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
# Quick launch (after install)
wsm              # Portable launcher — works from any directory
vscode wsm       # Universal launcher — discovers & dispatches

# Verbose (always works)
pwsh -NoProfile -ExecutionPolicy Bypass -File "scripts\WorkspaceManager.ps1"
```

You see a box-drawn menu with 15 options organized into sections:

```
╔════════════════════════════════════════════════╗
║  ⚙️  VS Code Workspace Manager v1.1.0         ║
╠════════════════════════════════════════════════╣
║  📁 Templates: 1  │  📋 Profiles: 1            ║
╚════════════════════════════════════════════════╝

  ── Workspace ──    ── Profiles ──    ── Security ──    ── Tools ──
  1) 📄 Settings     7) 👤 Profiles    4) 🔑 BYOK        8) 🏗️  Init
  2) 🆕 New template 13) 🔬 Scan      5) 🛡️  Trust      10) ✅ Validate
  3) 💾 Save                                                11) 📖 Docs
  6) 🚀 Open                                                12) ℹ️  About
  9) 🔍 Search                                              14) 🔄 Updates
                                                            15) ⏰ Schedule
```

Pick **1** — it shows your VS Code environment health. Pick **12** — see project stats.

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

## Minute 6 — Run Validation Checks

Run a quick health check to confirm everything is working:

```powershell
# Standalone validation (all JSON + workspace files)
pwsh -NoProfile -File "scripts\Run-Validate.ps1"

# Full checks (validation + secret scan)
pwsh -NoProfile -File "scripts\Run-Checks.ps1"
```

Or from the interactive menu: **10 → Run validation checks**.

---

## Minute 7 — Explore Advanced Features

Now that you have the basics, try these:

**Auto-open a project with the right profile:**
```powershell
pwsh -File scripts\Open-WithProfile.ps1 path\to\project
```

**Scan a project for recommendations:**
```
Menu → Option 13 → enter project path → see detected stack and suggested profile
```

**Check your environment health:**
```powershell
pwsh -File scripts\Check-Environment.ps1
```

**Set up automated backups and validation:**
```
Menu → Option 15 → Install all tasks
```

**Self-update to the latest version:**
```powershell
make update
```

---

## You're Done. What's Next?

| Want to... | Read |
|------------|------|
| Understand architecture | [`docs/ARCHITECTURE.md`](./docs/ARCHITECTURE.md) |
| Set up terminal profiles | [`docs/TERMINAL.md`](./docs/TERMINAL.md) |
| Tune DeepSeek | [`docs/DEEPSEEK-RECOMMENDATIONS.md`](./docs/DEEPSEEK-RECOMMENDATIONS.md) |
| Dive into trust | [`docs/WORKSPACE-TRUST.md`](./docs/WORKSPACE-TRUST.md) |
| See daily workflows | [`docs/WORKFLOW.md`](./docs/WORKFLOW.md) |
| Something broken? | [`HELP.md`](./HELP.md) |
| Detailed setup | [`docs/SETUP.md`](./docs/SETUP.md) |
| Use Reasonix prompts | [`prompts/`](./prompts/) (goals, run cookbook, learn path, improve, usage) |
| BYOK configuration | [`docs/BYOK-GUIDE.md`](./docs/BYOK-GUIDE.md) |

---

## Cheat Sheet

```powershell
# Daily driver — pick one
wsm                          # Fastest (from anywhere in PATH)
vscode wsm                   # Universal launcher (discovers any C:\VSCode tool)
pwsh -NoProfile -ExecutionPolicy Bypass -File "C:\VSCode\Templates\scripts\WorkspaceManager.ps1"  # Verbose

# Quick create and open
# → 2 → enter name → enter → enter → 6 → choose template → done

# Export profile from VS Code
# Ctrl+Shift+P → Profiles: Export Profile → save to C:\VSCode\Templates\profiles\

# Open with specific profile
code --profile python-dev C:\VSCode\Templates\templates\my-app.code-workspace

# Validate everything
wsm validate                 # Quick
vscode wsm validate          # Via universal launcher
pwsh -NoProfile -File "scripts\Run-Validate.ps1"  # Verbose

# Full health check
wsm check                    # Quick
vscode wsm check             # Via universal launcher

# Environment doctor
make doctor

# Auto-open a project
pwsh -File scripts\Open-WithProfile.ps1 path\to\project

# Back up everything
make backup

# Schedule daily validation
make schedule

# Explore all C:\VSCode tools
vscode list
```
