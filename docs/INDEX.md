# Documentation Index — VS Code Workspace Manager

Master portal for all project documentation. Start here.

---

## 🚀 Getting Started

| Document | What it covers | Time |
|----------|---------------|------|
| [`ONBOARDING.md`](../ONBOARDING.md) | 7-minute interactive setup with checklist | 7 min |
| [`LANDING.md`](../LANDING.md) | Project overview, features, directory map | 3 min |
| [`README.md`](../README.md) | Quick-start, what-it-does table, design decisions | 5 min |
| [`docs/SETUP.md`](SETUP.md) | Detailed prerequisites and verification | 10 min |

---

## 📖 Learning Path

| Stage | Document | Topic |
|-------|----------|-------|
| 1 | [`ONBOARDING.md`](../ONBOARDING.md) | Install & launch |
| 2 | [`prompts/learn-path.md`](../prompts/learn-path.md) | 9-stage guided learning |
| 3 | [`prompts/run-cookbook.md`](../prompts/run-cookbook.md) | Every command, every way to run |
| 4 | [`docs/HOWTO.md`](HOWTO.md) | 12 common recipes |
| 5 | [`docs/WORKFLOW.md`](WORKFLOW.md) | Day-to-day usage patterns |

---

## 🏗️ Architecture & Design

| Document | What it covers |
|----------|---------------|
| [`docs/ARCHITECTURE.md`](ARCHITECTURE.md) | Full system architecture, component diagrams, data structures |
| [`docs/UML.md`](UML.md) | Standalone UML collection: system, menu flow, self-update, validation, data structures |
| [`ROADMAP.md`](../ROADMAP.md) | v1.2.0 → v2.0.0 planned releases + backlog |
| [`TODO.md`](../TODO.md) | Tracking document for immediate and planned work |
| [`SUGGESTIONS.md`](../SUGGESTIONS.md) | Future ideas across 10 categories |

---

## ⚙️ Features

| Document | Feature |
|----------|---------|
| [`docs/TERMINAL.md`](TERMINAL.md) | Terminal profiles, shell integration, VS Code tasks |
| [`docs/WORKSPACE-TRUST.md`](WORKSPACE-TRUST.md) | VS Code Restricted Mode, trust inheritance, security boundaries |
| [`docs/BYOK-GUIDE.md`](BYOK-GUIDE.md) | DeepSeek BYOK: Azure Key Vault, AWS KMS, HashiCorp Vault |
| [`docs/SELF-UPDATE.md`](SELF-UPDATE.md) | Self-update system: pipeline, safety, troubleshooting |
| [`docs/AUTOMATION.md`](AUTOMATION.md) | Scheduled tasks, auto-backup, GitHub scheduled CI |

---

## 🔧 Operations

| Document | Topic |
|----------|-------|
| [`docs/TUNEUP.md`](TUNEUP.md) | Performance tuning, startup speed, terminal output, disk usage |
| [`docs/CI-CD.md`](CI-CD.md) | GitHub Actions workflows, local `act` runs |
| [`docs/FAQ.md`](FAQ.md) | 20+ frequently asked questions |
| [`HELP.md`](../HELP.md) | Troubleshooting guide |

---

## 🤖 Prompts & AI Integration

| Document | Use case |
|----------|----------|
| [`prompts/goals.md`](../prompts/goals.md) | Copy-paste Reasonix goal templates |
| [`prompts/usage-prompts.md`](../prompts/usage-prompts.md) | 14 common task prompts |
| [`prompts/improve.md`](../prompts/improve.md) | Evolution and enhancement prompts |
| [`prompts/workspace-manager-prompt.md`](../prompts/workspace-manager-prompt.md) | Full spec for regenerating via Reasonix |
| [`prompts/reasonix-prompt-reference.md`](../prompts/reasonix-prompt-reference.md) | Complete Reasonix prompt reference |

---

## 🔒 Security & Governance

| Document | Topic |
|----------|-------|
| [`SECURITY.md`](../SECURITY.md) | Vulnerability reporting, BYOK rules, hardening |
| [`CONTRIBUTING.md`](../CONTRIBUTING.md) | Development workflow, code guidelines, review process |
| [`LICENSE`](../LICENSE) | MIT license |

---

## 📊 Project Health

| Document | What it shows |
|----------|--------------|
| [`CHANGELOG.md`](../CHANGELOG.md) | Version history and changes |
| [`RECOMMENDATIONS.md`](../RECOMMENDATIONS.md) | Best practices: trust, security, terminal, tasks, team workflow |
| [`scripts/Check-Environment.ps1`](../scripts/Check-Environment.ps1) | Run: `make doctor` for live health check |

---

## 🧭 Navigation

| Tool | What it does |
|------|-------------|
| `pwsh -File scripts/Navigate-Project.ps1` | Interactive project browser |
| `pwsh -File scripts/WorkspaceManager.ps1` → Option 11 | Browse and open docs from menu |
| `make manager` | Launch the full menu |

---

## Quick Document Map

```
                    ┌─────────────────────────┐
                    │     Getting Started      │
                    │ ONBOARDING → LANDING     │
                    │ → README → SETUP         │
                    └───────────┬─────────────┘
                                │
          ┌─────────────────────┼─────────────────────┐
          │                     │                     │
  ┌───────▼──────┐    ┌────────▼───────┐    ┌───────▼──────┐
  │ Architecture │    │    Features     │    │  Operations  │
  │ ARCHITECTURE │    │ TERMINAL        │    │ TUNEUP       │
  │ UML          │    │ WORKSPACE-TRUST │    │ FAQ          │
  │ ROADMAP      │    │ BYOK-GUIDE      │    │ HELP         │
  │ TODO         │    │ SELF-UPDATE     │    │ CI-CD        │
  │ SUGGESTIONS  │    │ AUTOMATION      │    │ HOWTO        │
  └──────────────┘    └─────────────────┘    └──────────────┘
                                │
                     ┌──────────▼──────────┐
                     │   Prompts & AI      │
                     │ goals, improve,     │
                     │ usage, learn-path,  │
                     │ run-cookbook        │
                     └─────────────────────┘
```
