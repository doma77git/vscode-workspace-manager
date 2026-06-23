# Roadmap — VS Code Workspace Manager

## Current: v1.1.0 — Feature-Rich Toolkit

✅ 15 menu options (box-drawn UI, live clock, keyboard shortcuts)  
✅ 23 PowerShell scripts (runners, checkers, helpers, backup, scheduler, compiler, exporter, navigator)  
✅ 16 documentation guides (including PRD, UML, GRAPHICS, INDEX)  
✅ 11 prompt library files (agent-flows, goals, gists, research, memories)  
✅ 4 CI workflows (validate, release, scheduled, auto-changelog)  
✅ 6 terminal profiles + 7 tasks in sample workspace  
✅ Self-update, auto-backup, self-repair, self-compile, self-documenting  
✅ 20 Makefile targets + 19 npm scripts  
✅ Cross-platform support (Windows/Linux/macOS)  
✅ Security: BYOK, pre-commit, pre-push, post-commit, secrets scan, dependabot  
✅ 41 automated tests (23 PS AST + 10 JSON + 6 YAML + 2 integration)  
✅ `--json` flag on all 8 primary scripts  
✅ Tab-completion for profile names  
✅ Module manifest (.psd1/.psm1) for PSGallery  
✅ Extension health checker  
✅ `.vscode/` exporter from template  
✅ 3 Reasonix skills installed  
✅ 3 git hooks (pre-commit, pre-push, post-commit)

---

## v1.2.0 — Polish & Ecosystem (target: next release)

- [ ] **Interactive onboarding wizard** — guided first-run experience (option 0 or auto-detect)
- [x] **PowerShell module packaging** — publish as `VSCodeWorkspaceManager` module to PSGallery
- [x] **Shell tab-completion** — argument completer for `Open-WithProfile.ps1` profile names
- [x] **Export to `.vscode/settings.json`** — generate workspace settings from template
- [ ] **Diff viewer for template changes** — show what changed between template versions
- [ ] **Template validation against JSON Schema** — validate `.code-workspace` against official schema
- [x] **Profile health check** — verify extensions exist and are installable
- [ ] **Batch operations** — apply same profile to multiple templates at once

---

## v1.3.0 — Collaboration & Teams (target: 2-3 months)

- [ ] **Team sync** — push/pull profiles and templates via shared git remote
- [ ] **Profile inheritance** — base profile + overrides pattern
- [ ] **Template analytics** — which templates/profiles are most used?
- [ ] **Multi-user trust dashboard** — aggregate trust decisions across team
- [ ] **Slack/Teams notifications** — alert on validation failures from CI
- [ ] **Web dashboard** — simple HTML page showing project health

---

## v2.0.0 — Platform Expansion (target: 4-6 months)

- [ ] **VS Code extension** — sidebar view for workspace management
- [ ] **Web UI** — browser-based management (no CLI needed)
- [ ] **REST API** — programmatic template/profile management
- [ ] **Docker image** — pre-configured workspace manager container
- [ ] **GitHub App** — auto-suggest profiles on PRs based on changed files
- [ ] **Plugin system** — community extensions for new languages/stacks

---

## Backlog — Unprioritized Ideas

- [ ] Template marketplace (share templates with community)
- [ ] AI-powered profile generation (describe your stack → get a profile)
- [ ] Integration with GitHub Codespaces / Dev Containers
- [ ] Workspace usage analytics dashboard
- [ ] Automated PR for dependency updates in templates
- [ ] Localization / i18n support
- [ ] Migration tool from other workspace managers
- [ ] Performance profiling and optimization pass
- [ ] Fuzz testing for JSON parsers
- [ ] Git hooks library (pre-push validation, commit-msg linting)

---

## How to Contribute

See `CONTRIBUTING.md` for guidelines. Pick an item from the roadmap, create a branch, implement, and open a PR.

Priorities are driven by community feedback. If a feature matters to you, open an issue with the `enhancement` label.
