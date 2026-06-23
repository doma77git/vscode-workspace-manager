# PRD — VS Code Workspace Manager

Product Requirements Document · v1.1.0 · June 2026

---

## 1. Executive Summary

**VS Code Workspace Manager** is a single-repository toolkit for managing every aspect of the VS Code developer experience: workspace templates, profiles, terminal configuration, tasks, trust settings, and automation. One `git clone` → `make install` → fully configured development environment.

**Tagline:** "One repository. Every workspace. Zero trust surprises."

---

## 2. Problem Statement

| Problem | Impact |
|---------|--------|
| Workspaces scattered across machines, no version control | Lost configs, inconsistent setups |
| Profiles tied to one machine | Can't share IDE setup with team |
| "Do I trust this repo?" — unsure every time | Security anxiety, Restricted Mode confusion |
| Secret keys accidentally committed | Security breaches |
| Onboarding new team members takes hours | Productivity loss |
| No standard way to open workspaces with profiles | Manual `code --profile` guesswork |
| Terminal/tasks configured ad-hoc per project | Inconsistent developer experience |

---

## 3. Target Users

| Persona | Need | Primary feature |
|---------|------|----------------|
| **Individual developer** | Consistent workspace across machines | Templates + profiles |
| **Engineering manager** | Onboard new hires in minutes | `git clone` + `make install` |
| **DevSecOps engineer** | No secrets in repos, trust tracking | BYOK metadata, pre-commit hooks |
| **Full-stack / polyglot dev** | Switch stacks instantly | Project scanner + auto-open |
| **OSS maintainer** | Professional repo with CI + community | Full CI suite, templates, CODEOWNERS |
| **AI agent user (Reasonix)** | Agentic workflow automation | 11 prompt files, 3 skills, agent-flows |

---

## 4. Core Features (Current — v1.1.0)

### 4.1 Workspace Management
- ✅ Interactive menu (15 options) with box-drawn UI, live clock, keyboard shortcuts
- ✅ Create templates with `${PROJECT_NAME}` / `${GIT_REMOTE}` variable substitution
- ✅ Save existing `.code-workspace` files as timestamped templates
- ✅ Multi-root workspace support
- ✅ Search templates by name, content, or metadata

### 4.2 Profile Management
- ✅ Import / export / list VS Code profiles
- ✅ Bulk export all profiles with manifest
- ✅ Assign profiles to templates via `meta/<template>.meta.json`
- ✅ Profile metadata template with tags, description, version
- ✅ Tab-completion for profile names in CLI
- ✅ Project scanner: 15 indicator files → suggested profile

### 4.3 Terminal & Tasks
- ✅ 6 pre-configured Windows terminal profiles (PowerShell, Git Bash, cmd, WSL)
- ✅ 7 VS Code tasks (JSON validation, CI, compound Full Validation)
- ✅ Shell integration enabled (command decorations, sticky scroll, IntelliSense)
- ✅ Automation profile for task/debug shells
- ✅ Cross-platform path detection (Windows/Linux/macOS)

### 4.4 Security
- ✅ BYOK metadata storage (Azure Key Vault / AWS KMS / HashiCorp Vault)
- ✅ Pre-commit hook: blocks secrets before commit
- ✅ Pre-push hook: blocks push if tests fail
- ✅ Post-commit hook: informational validation
- ✅ 4 CI workflows: validate, release, scheduled, auto-changelog
- ✅ Secrets scan (grep for patterns)
- ✅ Workspace trust tracking (`meta/trust.json`)
- ✅ `.gitignore` excludes BYOK files + exports

### 4.5 Automation
- ✅ Scheduled tasks (daily validate, weekly backup, monthly update check)
- ✅ Auto-backup to timestamped zip with pruning
- ✅ Self-update from git remote (stash → fetch → merge → restore → validate)
- ✅ Self-repair: auto-fix JSON, line endings, missing dirs, git hooks
- ✅ Self-compile: generate .psm1, update .psd1, create zip
- ✅ Self-documenting: auto-generate PROJECT-STATS.md, update AGENTS.md
- ✅ Auto-update check on menu launch

### 4.6 Developer Experience
- ✅ 23 PowerShell scripts (runners, checkers, helpers, scheduler, etc.)
- ✅ 16 documentation guides
- ✅ 11 prompt files for AI agents
- ✅ 3 Reasonix skills (deepseek-byok, deepseek-reasonix, workspace-manager)
- ✅ 20 Makefile targets + 19 npm scripts
- ✅ `.vscode/` exporter from template
- ✅ Extension health checker (VS Code Marketplace API)
- ✅ Environment health check (prerequisites, structure, git, validation)
- ✅ Project navigator (9-option interactive browser)

### 4.7 Testing
- ✅ 41 automated checks: 23 PS AST + 10 JSON syntax + 6 YAML syntax + 2 integration
- ✅ Performance benchmark (file scan ms)
- ✅ `--json` flag on all scripts for CI/automation
- ✅ `--quiet` flag for silent operation

---

## 5. Non-Functional Requirements

| Requirement | Status | Detail |
|-------------|--------|--------|
| **Performance** | ✅ | Full test suite: 3.0s, file scan: 28ms |
| **Cross-platform** | ✅ | Windows/Linux/macOS path detection |
| **Security** | ✅ | No real secrets, 3 git hooks, 4 CI workflows |
| **Maintainability** | ✅ | Modular architecture, Helper-Functions.ps1 shared lib |
| **Documentation** | ✅ | 16 guides + 11 prompts + INDEX portal |
| **CI/CD ready** | ✅ | `--json` on all scripts, 4 GitHub Actions workflows |
| **Self-healing** | ✅ | `make repair` fixes common issues automatically |

---

## 6. Success Metrics

| Metric | Current | Target v1.2.0 |
|--------|---------|---------------|
| Test pass rate | 41/41 (100%) | Maintain ≥ 39 |
| Test suite runtime | 3.0s | < 5s |
| File scan benchmark | 28ms | < 100ms |
| Scripts with `--json` flag | 8/8 (100%) | Maintain 100% |
| Documentation guides | 16 | ≥ 16 |
| CI workflows | 4 | ≥ 4 |
| Menu options | 15 | 16+ |
| PSGallery readiness | .psd1/.psm1 created | Published |

---

## 7. Architecture

```
UI Layer        : WorkspaceManager.ps1 (759 lines) + 4 Invoke-* modules
Logic Layer     : 16 standalone scripts (runners, checkers, backup, scheduler, compiler, exporter, navigator)
Data Layer      : templates/ (.code-workspace) + profiles/ (.json) + meta/ (trust, BYOK)
Shared Layer    : Helper-Functions.ps1 (Write-Banner, Write-Section, Write-Pass/Fail, validators)
Security Layer  : 3 git hooks (pre-commit, pre-push, post-commit) + 4 CI workflows
```

No circular dependencies. All scripts exit 0 on success, 1 on failure.

---

## 8. Roadmap

### v1.2.0 (Next)
- [ ] PowerShell Gallery publishing
- [ ] Interactive onboarding wizard
- [ ] Profile inheritance (base + overrides)
- [ ] Team sync (push/pull profiles via git)
- [ ] JSON Schema validation for `.code-workspace`

### v1.3.0
- [ ] VS Code extension sidebar
- [ ] Web dashboard
- [ ] Batch operations (apply profile to all templates)

### v2.0.0
- [ ] REST API
- [ ] Plugin system
- [ ] Docker image

---

## 9. Competitive Landscape

| Tool | Focus | Our Advantage |
|------|-------|---------------|
| chezmoi (20k★) | All dotfiles | VS Code-specific, interactive menu, security pipeline |
| yadm (6k★) | All dotfiles (git-based) | Profiles + templates + terminal + tasks in one repo |
| vscode-workspace topic (15 repos) | Workspace switching | Only project with full lifecycle management |
| Manual dotfiles | Shell/vim configs | Structured, tested, documented, self-repairing |

---

## 10. Repository

- **GitHub:** https://github.com/doma77git/vscode-workspace-manager
- **License:** MIT
- **Language:** PowerShell 97% · Shell 2% · Makefile 1%
- **Version:** v1.1.0 (18 commits)
- **Tests:** 41 checks · 23 scripts · 16 docs
