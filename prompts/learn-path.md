# Learning Path — From Zero to Workspace Manager Master

Follow these stages in order. Each stage takes about 10 minutes.

---

## Stage 1: Install & Launch (10 min)

```powershell
# 1. Clone
git clone <your-remote> C:\VSCode\Templates
cd C:\VSCode\Templates

# 2. Initialize
make install

# 3. Launch
make manager
```

**You now see:** a 14-option menu with live stats.
**Try:** Option 1 (check settings), Option 12 (about).

---

## Stage 2: Create Your First Workspace (10 min)

1. In the menu, select **Option 2 → New workspace template**
2. Name it `learning-test`
3. Set project name to `Learning Test`
4. Leave git remote blank
5. Answer `n` to multi-root and profile
6. Select **Option 6 → Open workspace** → pick `learning-test`

**You now have:** a `.code-workspace` file in `templates/` and VS Code opened with it.

---

## Stage 3: Profiles & Terminal (10 min)

1. In VS Code, set up your preferred settings (font, theme, extensions)
2. `Ctrl+Shift+P` → `Profiles: Export Profile` → save to `profiles/my-profile.json`
3. In the menu: **Option 7 → Import profile** → pick your file
4. **Option 13 → Scan project** → scan your new project → assign the profile
5. Open the project: **Option 6** → pick it → use the profile

**You now have:** a profile assigned to your workspace. VS Code opens with the right extensions.

---

## Stage 4: Run Validation (5 min)

```powershell
# From the menu: Option 10
# Or from terminal:
make validate
make test
```

**You now know:** how to check everything is healthy before pushing.

---

## Stage 5: Understand Trust & Security (10 min)

1. Read `docs/WORKSPACE-TRUST.md` — what Restricted Mode blocks
2. Check `meta/trust.json` — your empty workspace trust setting
3. Option 5 — toggle trust
4. Read `SECURITY.md` — BYOK, secrets, reporting

**Key concept:** Never commit real keys. BYOK stores only metadata.

---

## Stage 6: Terminal Profiles & Tasks (15 min)

1. Read `docs/TERMINAL.md`
2. In VS Code: `Terminal → Run Task` — explore the 7 pre-configured tasks
3. Try `Ctrl+Shift+B` (run build task)
4. Try `Ctrl+`` (toggle terminal) — check shell integration is working
5. Hover the terminal tab to see integration quality

**You now know:** how terminal profiles, shell integration, and tasks work together.

---

## Stage 7: Customize for Your Team (15 min)

1. Create profiles for each stack your team uses
2. Create templates for each repo
3. Assign profiles to templates
4. Update `meta/trust.json` with trusted parent folders
5. Run `make checks` to validate everything

**You now have:** a team-ready workspace management system.

---

## Stage 8: Automate with Make & npm (5 min)

```bash
make validate    # Quick check
make checks      # Pre-push check
make test        # Full suite
make update      # Self-update
```

**You now know:** the fastest paths for daily use.

---

## Stage 9: Go Deep (optional)

| Topic | Resource |
|-------|----------|
| Architecture | `docs/ARCHITECTURE.md` |
| DeepSeek tuning | `docs/DEEPSEEK-RECOMMENDATIONS.md` |
| CI/CD | `docs/CI-CD.md` |
| All prompts | `prompts/goals.md` |
| Run cookbook | `prompts/run-cookbook.md` |
| Self-update guide | `docs/SELF-UPDATE.md` |

---

## Quick-Reference Card

```
Launch     : make manager
Validate   : make validate
Test       : make test
Update     : make update
Open       : pwsh -File scripts\Open-WithProfile.ps1 path
Scan       : menu → Option 13
Docs       : menu → Option 11
About      : menu → Option 12
```
