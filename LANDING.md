# 🏠 VS Code Workspace Manager — Dashboard

> **One repository. Every workspace. Zero trust surprises.**

---

## 📊 Live Project Snapshot

```
╔══════════════════════════════════════════════════════════╗
║  v1.1.0  ·  214 files  ·  34 scripts  ·  82+ checks     ║
╠══════════════════════════════════════════════════════════╣
║                                                          ║
║  📁 8 templates   │  Python · Node · Go · Rust · Java   ║
║                    │  C++ · .NET · Base                  ║
║  📋 6 profiles    │  python-dev · web-dev · go-dev      ║
║                    │  rust-dev · sample · template       ║
║  ⚡ 34 scripts     │  runners · checkers · helpers       ║
║                    │  launchers · update · repair        ║
║  📖 21 docs        │  guides · UML · PRD · HOWTO         ║
║  💬 13 prompts     │  goals · flows · gists · recipes    ║
║  🧠 4 skills       │  vscode-helper · deepseek-byok      ║
║                    │  deepseek-reasonix                  ║
║                    │  workspace-manager                  ║
║  ⚙️ 5 CI workflows  │  validate · release · scheduled     ║
║                    │  auto-changelog · auto-deploy       ║
║                                                          ║
║  ✅ 82+ checks pass  ·  50ms scan  ·  🌍 Cross-platform ║
║  🔒 No secrets  ·  🛡️ 3 git hooks  ·  🌍 Cross-platform ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
```

---

## 🚀 Quick Start

```powershell
# One-liner
irm https://raw.githubusercontent.com/doma77git/vscode-workspace-manager/main/install.ps1 | iex

# Or manual
git clone https://github.com/doma77git/vscode-workspace-manager.git C:\VSCode\Templates
cd C:\VSCode\Templates && make install && make manager
```

---

## ⚡ Quick Commands

| Action | Command |
|--------|---------|
| Launch menu | `make manager` |
| Universal launcher | `vscode` / `vscode wsm validate` |
| Quick launch | `wsm` / `wsm validate` / `wsm test` |
| Run tests | `make test` |
| Full pipeline | `make all` |
| Self-update | `make update` |
| Backup | `make backup` |
| Repair | `make repair` |
| Compile | `make compile` |
| Export .vscode/ | `make export` |
| Health check | `make doctor` |

---

## 📂 Directory

```
C:\VSCode\Templates\
├── install.ps1              ← One-line installer
├── wsm.ps1 / wsm.cmd        ← Portable launchers
├── vscode.ps1 / vscode.cmd   ← Universal launcher + stubs
├── vscode.sh / vscode-tools.json
├── tests/                    ← Test fixtures
├── scripts/ (37 files)      ← Runners, checkers, helpers
├── templates/ (8 files)     ← .code-workspace templates
├── profiles/ (6 files)      ← VS Code profile exports
├── meta/                    ← Trust + BYOK metadata
├── docs/ (21 files)         ← Full documentation
├── prompts/ (13 files)      ← AI agent library
├── skills/ (4 skills)       ← Reasonix installable
└── .github/workflows/ (4)   ← CI/CD pipelines
```

---

## 🧭 Navigation

| I want to... | Go here |
|-------------|---------|
| Get started | [`ONBOARDING.md`](./ONBOARDING.md) |
| Understand architecture | [`docs/ARCHITECTURE.md`](./docs/ARCHITECTURE.md) |
| See UML diagrams | [`docs/UML.md`](./docs/UML.md) |
| Product requirements | [`docs/PRD.md`](./docs/PRD.md) |
| Roadmap | [`ROADMAP.md`](./ROADMAP.md) |
| Common questions | [`docs/FAQ.md`](./docs/FAQ.md) |
| How-to recipes | [`docs/HOWTO.md`](./docs/HOWTO.md) |
| Agent best practices | [`docs/AGENT-BEST-PRACTICES.md`](./docs/AGENT-BEST-PRACTICES.md) |
| Agents Window setup | [`docs/AGENTS-WINDOW.md`](./docs/AGENTS-WINDOW.md) |
| Terminal + tasks | [`docs/TERMINAL.md`](./docs/TERMINAL.md) |
| Something broken? | [`HELP.md`](./HELP.md) |
| Prompt library | [`prompts/`](./prompts/) |
| Agent flows | [`prompts/agent-flows.md`](./prompts/agent-flows.md) |
| Run cookbook | [`prompts/run-cookbook.md`](./prompts/run-cookbook.md) |
| Workspace recipes | [`prompts/workspace-recipes.md`](./prompts/workspace-recipes.md) |
| Launcher design spec | [`docs/reasonix/specs/2026-06-26-vscode-launcher-design.md`](./docs/reasonix/specs/2026-06-26-vscode-launcher-design.md) |
| Launcher implementation plan | [`docs/reasonix/plans/2026-06-26-vscode-launcher.md`](./docs/reasonix/plans/2026-06-26-vscode-launcher.md) |

---

## ✅ Stack Coverage

| Stack | Template | Profile | Tasks |
|-------|----------|---------|-------|
| **Python** | `python-dev.code-workspace` | `python-dev.json` | pytest · black · ruff |
| **Node.js** | `node-dev.code-workspace` | `web-dev.json` | dev · test · lint · build |
| **Go** | `go-dev.code-workspace` | `go-dev.json` | run · test · lint · build |
| **Rust** | `rust-dev.code-workspace` | `rust-dev.json` | run · test · clippy · release |
| **Java** | `java-dev.code-workspace` | — | Maven · Gradle |
| **C/C++** | `cpp-dev.code-workspace` | — | CMake · CTest |
| **.NET** | `dotnet-dev.code-workspace` | — | dotnet build · test · run |
| **Base** | `sample-project.code-workspace` | `sample-profile.json` | JSON validate · CI |

---

## 🔗 Links

- **GitHub:** [doma77git/vscode-workspace-manager](https://github.com/doma77git/vscode-workspace-manager)
- **License:** MIT
- **PowerShell:** 97%
- **Status:** 🟢 All systems operational
