# Project guidance

## Skills — STOP. Load a skill before you act.

This project ships skills (playbooks) under `skills/`. They only work if you load them.

**The rule:** before you do ANYTHING non-trivial — before you `explore`, run `bash`,
write code, or answer — STOP and check the skills index. If a skill might fit, load it.
Loading a skill is cheap. Skipping it is the #1 mistake. Process skill FIRST. Action SECOND.

Do NOT jump straight to `explore` or `bash` or a direct answer. The skill tells you HOW
to explore, debug, build, and verify. So it comes first, every time.

Match the situation:

| If… | Load this FIRST |
|---|---|
| starting a feature, or you have a rough idea | **superpowers-brainstorming** |
| a bug, a failing or flaky test, or anything surprising | **superpowers-systematic-debugging** |
| writing or fixing any code | **superpowers-test-driven-development** |
| you have a spec for a multi-step task | **superpowers-writing-plans** |
| executing a written plan in this session | **superpowers-executing-plans** |
| about to say "done" / "fixed" / "passing" | **superpowers-verification-before-completion** |
| work is done and tests pass | **superpowers-finishing-a-development-branch** |
| you got code-review feedback (from `review` or a human) | **superpowers-receiving-code-review** |
| need an isolated workspace | **superpowers-using-git-worktrees** |
| making or editing a skill | **superpowers-writing-skills** |

Load it: `run_skill({ name: "<skill-name>", arguments: "<the task>" })`.

These skills **supplement** Reasonix's native tools — they don't replace them. For
dispatching subagents, code review, parallel work, and codebase exploration, use the
native tools directly: **`task`** (run a subagent), **`review`** (code-review a diff),
**`wait`** (join parallel jobs), **`explore`** (investigate the codebase). There is no
skill for these — reach for the native tool.

If you catch yourself about to explore, fix, or answer without loading a skill — STOP and load it.

## Red flags — these thoughts mean STOP. You are rationalizing.

| You think | Reality |
|---|---|
| "Just a simple question" | Questions are tasks. Check for a skill. |
| "Let me explore / look first" | The skill tells you HOW to explore. Skill first. |
| "I'll just do this one thing first" | Check BEFORE doing anything. |
| "This skill is overkill" | Simple turns complex. Load it. |
| "I already know this" | Knowing ≠ doing. Load the current skill. |

If more than one skill fits, load the **process skill first** — superpowers-brainstorming,
superpowers-systematic-debugging, superpowers-verification-before-completion — then the implementation skill.
"Build X" → superpowers-brainstorming first. "Fix this bug" → superpowers-systematic-debugging first.

## Priority

1. The user's explicit instructions (this file, `REASONIX.md`, direct asks) win over everything.
2. Skills override default behavior where they conflict.
3. A user request says WHAT to do, never "skip the skill." "Add X" still means: load the skill, then add X.

---

# VS Code Workspace Manager — Project Context

## Project Identity

PowerShell toolkit for managing VS Code workspace templates, profiles, trust settings, and DeepSeek BYOK metadata.

- **Root:** `C:\VSCode\Templates\`
- **Stack:** PowerShell 7+ (`pwsh`), VS Code CLI (`code`), git, GitHub Actions
- **No package manager** — pure PowerShell, no manifests

## Architecture

```
C:\VSCode\Templates\
├── scripts/              ← All .ps1 scripts (entry points, modules, helpers)
│   ├── WorkspaceManager.ps1        Interactive menu (15 options)
│   ├── Init-TemplatesRepo.ps1      One-time git + hooks setup
│   ├── Helper-Functions.ps1        Shared library (path, display, validation, git, count helpers)
│   ├── Invoke-*.ps1                Menu modules dot-sourced by WorkspaceManager
│   ├── Run-*.ps1                   Standalone validators and test runners
│   ├── Open-WithProfile.ps1        Auto-open with VS Code profile
│   ├── Update-Self.ps1             Self-update from git remote
│   ├── Auto-Backup.ps1             Backup templates/profiles/meta to zip
│   ├── Schedule-Tasks.ps1          Cross-platform task scheduler
│   ├── Runner.ps1                  Universal runner (task dispatcher)
│   └── Navigate-Project.ps1        Interactive project browser
├── templates/            ← *.code-workspace files
├── profiles/             ← VS Code profile exports (JSON)
├── meta/                 ← deepseek-byok.json, trust.json, *.meta.json
├── docs/                 ← Architecture, UML, setup, guides, FAQ
├── prompts/              ← Reasonix prompt library
├── skills/               ← Reasonix installable skills
├── .github/              ← CI, agent configs, PR templates
├── Makefile              ← Convenience targets
├── package.json          ← npm scripts (convenience wrappers)
├── wsm.ps1               ← Portable launcher (PS, from any directory)
└── wsm.cmd               ← Portable launcher (batch, from any directory)
```

**Scripts: ~20 PowerShell · Docs: ~15 guides · Prompts: ~9 prompt · Skills: 3 Reasonix · CI: 1 workflows · Tests: ~34 checks**

## Conventions

- **Encoding:** UTF-8 without BOM for all files. PowerShell 7 compatible.
- **PowerShell functions:** PascalCase (`New-WorkspaceTemplate`, `Set-DeepSeekBYOK`). Run with `-NoProfile -ExecutionPolicy Bypass`.
- **Template variables:** `${PROJECT_NAME}` and `${GIT_REMOTE}` substituted at creation time.
- **BYOK security:** Never store real keys. `meta/deepseek-byok.json` = metadata + KMS commands only. In `.gitignore`.
- **Documentation:** Mermaid for diagrams (`docs/ARCHITECTURE.md`). Keep `CHANGELOG.md`.
- **Module compilation:** `Compile-Module.ps1` generates .psm1/.psd1 for PSGallery publishing.

## Commands

| Category | Command |
|----------|---------|
| Launch (any dir) | `wsm` or `pwsh -File wsm.ps1` |
| Launch menu | `make manager` or `npm run manager` |
| Init repo | `pwsh -NoProfile -ExecutionPolicy Bypass -File "scripts\Init-TemplatesRepo.ps1"` |
| Validate JSON | `make validate` or `npm run validate` |
| Full checks | `make checks` or `npm run checks` |
| All operations | `make all` or `npm run all` |
| Self-update | `make update` or `npm run update` |
| Quick tests | `make test` |
| Open with profile | `npm run open -- .` |
| Health check | `make doctor` |
| Schedule tasks | `make schedule` |

## Before committing

- Run `make test` — all checks pass
- Update `CHANGELOG.md`
- Update docs if behavior changed
- No secrets in commit (pre-commit hook enforces)

