---
name: deepseek-reasonix
description: Optimize Reasonix prompts and configuration for DeepSeek models — model selection, temperature, reasoning, prompt patterns.
type: global
runAs: inline
allowedTools: [read_file, edit_file, bash, ask]
---

# DeepSeek + Reasonix — Optimization Skill

Tune Reasonix configuration and prompt patterns for DeepSeek models (deepseek-flash, deepseek-pro, deepseek-v4).

## When to use
- User says "optimize for DeepSeek", "tune DeepSeek", "best settings for deepseek"
- Setting up a new project with DeepSeek as the default model
- Switching from another model to DeepSeek
- Debugging poor responses or timeout issues with DeepSeek

## Steps

### 1. Check current configuration
Read `reasonix.toml` (project-local first, then global at `~/AppData/Roaming/reasonix/config.toml`).

Verify these settings:
```toml
config_version = 3
default_model = "deepseek-flash"   # or deepseek-pro / deepseek-v4

[agent]
temperature = 0.0                   # DeepSeek works best at 0.0–0.3
reasoning_language = "en"           # DeepSeek reasoning in English is most reliable
# planner_model = "deepseek-pro"    # Optional: use pro for planning phase
# subagent_model = "deepseek-pro"   # Optional: use pro for subagents
```

### 2. Model selection guidance

| Model | Best for | Context | Speed |
|-------|----------|---------|-------|
| `deepseek-flash` | Quick edits, simple tasks, file ops | Standard | Fast |
| `deepseek-pro` | Complex reasoning, planning, review | Large | Medium |
| `deepseek-v4` | Latest capabilities, long contexts | Very large | Slow |

Recommended split:
- Default model: `deepseek-flash` (cheap, fast, good enough for 80% of tasks)
- Planner model: `deepseek-pro` (when using plan mode for complex architecture)
- Subagent model: `deepseek-pro` (for review/security_review/explore)

### 3. Apply optimizations

Update `reasonix.toml`:

```toml
[agent]
temperature = 0.0
reasoning_language = "en"
soft_compact_ratio = 0.5
compact_ratio = 0.8
compact_force_ratio = 0.9
cold_resume_prune = true
```

Recommended per-skill model overrides:
```toml
[agent]
subagent_models = { review = "deepseek-pro", security_review = "deepseek-pro", explore = "deepseek-pro", research = "deepseek-pro" }
subagent_efforts = { review = "high", security_review = "max" }
```

### 4. Prompt patterns that work well with DeepSeek

DeepSeek responds best to:
- **Structured, imperative instructions** (not conversational)
- **Explicit constraints** ("Do NOT do X", "Stop when Y")
- **Concrete examples** over abstract descriptions
- **Short system prompts** — DeepSeek's reasoning is strong; don't over-explain

### 5. Verify
Ask the user to restart Reasonix for config changes to take effect.
