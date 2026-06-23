---
name: deepseek-reasonix
description: Optimize Reasonix prompts and configuration for DeepSeek models — model selection, temperature, reasoning, compaction, prompt patterns, and prompt library integration.
type: global
runAs: inline
allowedTools: [read_file, edit_file, bash, ask]
---

# DeepSeek + Reasonix — Optimization Skill

Tune Reasonix configuration and prompt patterns for DeepSeek models (deepseek-flash, deepseek-pro, deepseek-v4). This project includes a comprehensive prompt library for agent workflows.

## When to use
- User says "optimize for DeepSeek", "tune DeepSeek", "best settings for deepseek"
- Setting up a new project with DeepSeek as the default model
- Switching from another model to DeepSeek
- Debugging poor responses or timeout issues with DeepSeek
- User wants to use the project's prompt library (goals, flows, research paths)

## Steps

### 1. Check current configuration
Read `reasonix.toml` (project-local first, then global). Verify:
```toml
config_version = 3
default_model = "deepseek-flash"

[agent]
temperature = 0.0
reasoning_language = "en"
```

### 2. Model selection guidance

| Model | Best for | Context | Speed |
|-------|----------|---------|-------|
| `deepseek-flash` | Quick edits, simple tasks, file ops | Standard | Fast |
| `deepseek-pro` | Complex reasoning, planning, review | Large | Medium |
| `deepseek-v4` | Latest capabilities, long contexts | Very large | Slow |

### 3. Apply full optimizations

```toml
[agent]
temperature = 0.0
reasoning_language = "en"
planner_model = "deepseek-pro"
subagent_model = "deepseek-pro"
subagent_models = { review = "deepseek-pro", security_review = "deepseek-pro", explore = "deepseek-pro", research = "deepseek-pro" }
subagent_efforts = { review = "high", security_review = "max", explore = "high" }
soft_compact_ratio = 0.5
compact_ratio = 0.8
compact_force_ratio = 0.9
cold_resume_prune = true

[skills]
paths = [".reasonix/skills"]
```

### 4. Prompt patterns that work well with DeepSeek

DeepSeek responds best to:
- **Structured, imperative instructions** (not conversational)
- **Explicit constraints** ("Do NOT do X", "Stop when Y")
- **Concrete examples** over abstract descriptions
- **Short system prompts** — DeepSeek's reasoning is strong; don't over-explain

The project's prompt library (`prompts/`) provides ready-to-use templates:
- `agent-flows.md` — decision trees for common tasks
- `agent-research.md` — systematic investigation paths
- `goals.md` — copy-paste goal templates
- `improve.md` — evolution prompts
- `learn-path.md` — guided learning

### 5. Verify
Ask the user to restart Reasonix for config changes to take effect. Run `make test` to verify the project is healthy.
