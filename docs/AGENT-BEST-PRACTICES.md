# Agent Best Practices — Our Implementation

Based on [VS Code Agent Best Practices](https://code.visualstudio.com/docs/agents/best-practices) and [Memory](https://code.visualstudio.com/docs/agents/memory).

---

## 1. Project Optimization for AI

Our project implements all recommended AI configurations:

| Mechanism | Our Implementation | Status |
|-----------|-------------------|--------|
| Custom instructions | `AGENTS.md` in root | ✅ Generated via `/init` |
| Custom agents | 3 Reasonix skills in `skills/` | ✅ Installed |
| Skills | `deepseek-byok`, `deepseek-reasonix`, `workspace-manager` | ✅ |
| Tools/MCP | Pre-commit, pre-push, post-commit hooks | ✅ |
| Search exclusion | `.vscode/settings.json` excludes `.git`, `node_modules` | ✅ |
| Concise instructions | `AGENTS.md` kept under 200 lines | ✅ |

---

## 2. Agent Memory System

### Local Memory (VS Code Memory Tool)

We use the memory tool's 3 scopes:

```
.reasonix/memories/
├── user/           → Preferences, patterns (persists across workspaces)
│   └── coding-style.md
├── repo/           → Codebase conventions (stays in this project)
│   └── project-context.md
└── session/        → Task-specific context (cleared when chat ends)
    └── plan.md
```

Memory files are auto-loaded into agent context. Ask the agent:
- "Remember that..." to store
- "What are our conventions for..." to recall

### Copilot Memory (GitHub-hosted)

Enabled for team collaboration:
- Repository-scoped insights shared across Copilot surfaces
- Automatic 28-day expiration
- Owner: doma77git/vscode-workspace-manager

---

## 3. Write Effective Prompts

Our `prompts/` library follows the best practices:

| Practice | Our Implementation |
|----------|-------------------|
| Be specific | `prompts/goals.md` — 10 structured goal templates |
| Break down tasks | `prompts/agent-flows.md` — 8 decision trees |
| Include expected output | Each goal has "Stop when:" condition |
| Avoid vague prompts | All prompts are imperative + constrained |
| Iterate | `prompts/improve.md` — continuous improvement loop |

---

## 4. Provide the Right Context

| Context Type | Our Implementation |
|-------------|-------------------|
| File references | `AGENTS.md` Architecture section with file paths |
| Codebase conventions | `prompts/agent-memories.md` — key facts |
| Environment context | `Check-Environment.ps1` reports full health |
| Web context | `docs/UML.md` + `docs/ARCHITECTURE.md` diagrams |

---

## 5. Choose the Right Model

```toml
# reasonix.toml — model selection by task
default_model = "deepseek-flash"        # 80% of tasks
planner_model = "deepseek-v4"          # Planning/architecture
subagent_models = {
    review = "deepseek-v4",            # Code review
    security_review = "deepseek-v4",   # Security analysis
    research = "deepseek-v4"           # Research
}
subagent_efforts = {
    review = "high",
    security_review = "max"
}
```

---

## 6. Plan First, Then Implement

Our workflow:
```
1. Explore   → prompts/agent-research.md (8 investigation paths)
2. Plan      → prompts/goals.md structured templates
3. Implement → scripts/Run-*.ps1 for validation
4. Review    → scripts/Run-Checks.ps1 (validation + secret scan)
```

---

## 7. Review and Verify

| Step | Tool |
|------|------|
| Review before accepting | `make test` before commit |
| Run tests after changes | `make all` — full pipeline |
| Use checkpoints | Git commits + `pre-push` hook |
| Security check | `make checks` — secret scan |

---

## 8. Manage Context and Sessions

| Practice | Our Implementation |
|----------|-------------------|
| Start new sessions | `prompts/agent-flows.md` — fresh decision trees |
| Remove irrelevant history | AGENTS.md auto-loads only essentials |
| Compact context | `soft_compact_ratio = 0.5` in reasonix.toml |
| Use subagents | `subagent_models` config for explore/review/research |
| Parallel sessions | `subagent_efforts` for review (high) and security (max) |

---

## Quick Reference

```powershell
# Store a memory
# → Ask agent: "Remember that this project uses..."

# Recall
# → Ask agent: "What's our convention for..."

# View memories
# → Ctrl+Shift+P → Chat: Show Memory Files

# Clear
# → Ctrl+Shift+P → Chat: Clear All Memory Files

# Regenerate project config
# → /init (in chat)
```
