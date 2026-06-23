# DeepSeek + Reasonix — Recommendations & Best Practices

Covers model selection, configuration, prompt engineering, BYOK, and troubleshooting for DeepSeek models with Reasonix.

---

## 1. Model Selection

| Model | Use case | Strengths | Weaknesses |
|-------|----------|-----------|------------|
| **deepseek-flash** | Default for all day-to-day tasks | Fast, cheap, good enough for file ops, simple refactors, config changes | Struggles with very complex multi-step reasoning |
| **deepseek-pro** | Planning, architecture, review, research | Strong reasoning, handles ambiguity, good for security reviews | Slower, more expensive per turn |
| **deepseek-v4** | Latest model, largest context windows | Best reasoning quality, handles very long files | Slowest, highest cost |

### Recommended setup

```toml
# reasonix.toml
default_model = "deepseek-flash"

[agent]
planner_model = "deepseek-pro"      # Plan mode uses pro for architecture thinking
subagent_model = "deepseek-pro"     # Subagents default to pro
subagent_models = {
    review          = "deepseek-pro",
    security_review = "deepseek-pro",
    explore         = "deepseek-pro",
    research        = "deepseek-pro"
}
subagent_efforts = {
    review          = "high",
    security_review = "max"
}
```

**Why this split:**
- Flash handles 80% of tasks (file edits, simple queries, config) — keeps costs low
- Pro handles the 20% that need deep reasoning (planning, reviewing, exploring) — worth the cost
- Security reviews always get `max` effort — never save money on security

---

## 2. Configuration Tuning

### Temperature

DeepSeek works best at **low temperatures** for code tasks:

| Task type | Recommended temperature |
|-----------|------------------------|
| Code generation / editing | `0.0` — deterministic, consistent |
| Exploration / research | `0.1–0.2` — slight creativity for pattern matching |
| Creative writing / docs | `0.3–0.5` — more natural language |

```toml
[agent]
temperature = 0.0   # Default for code work
```

### Reasoning language

DeepSeek's reasoning tokens are most fluent in **English**. Set this explicitly:

```toml
reasoning_language = "en"
```

Chinese-language reasoning works but may produce mixed-language artifacts in code contexts.

### Compaction

DeepSeek handles long contexts well, but compaction keeps costs down:

```toml
[agent]
soft_compact_ratio  = 0.5   # Start thinking about compaction at 50%
compact_ratio       = 0.8   # Compact at 80%
compact_force_ratio = 0.9   # Force compact at 90%
cold_resume_prune   = true  # Clean up stale tool results on session resume
```

---

## 3. Prompt Engineering for DeepSeek

DeepSeek models respond best to **structured, imperative** prompts — not conversational ones.

### DO — patterns that work

```
# Structured goal with explicit steps
Goal: Add rate limiting to the API gateway.
- Read src/gateway/rate_limiter.ts
- Add token bucket implementation
- Wire into middleware chain
- Add tests in src/gateway/__tests__/
Stop when: all tests pass and no new lint errors.
```

```
# Concrete example-driven
Update the error handler to match this pattern:
Example input:  { code: "AUTH_EXPIRED", status: 401 }
Example output: { error: "Authentication expired", statusCode: 401, retry: false }
Apply to: src/errors/handler.ts. Keep existing log format.
```

```
# Explicit constraints
Refactor the config loader.
- Do NOT change the public API (Config.get, Config.set)
- Do NOT add new dependencies
- Keep backward compatibility with config.json format
```

### DON'T — patterns to avoid

```
❌ "Could you maybe take a look at the auth module and see if there's
   anything that could be improved? Whatever you think is best."
→ Too vague. DeepSeek will over-think and produce a sprawling response.

❌ "Let's think about how to make this better. What are your thoughts?"
→ Open-ended. DeepSeek's reasoning is strong but needs direction.

❌ A 500-word system prompt explaining the project history.
→ DeepSeek doesn't need it. Short context works better.
```

### Prompt template for complex tasks

```
Context: {1–2 sentences about what this code does}
Task: {imperative verb — add, fix, refactor, remove}
Rules:
- {constraint 1}
- {constraint 2}
- {constraint 3}
Output: {what success looks like}

Example: {short before/after if applicable}
```

---

## 4. BYOK (Bring Your Own Key)

DeepSeek BYOK lets you use your own encryption keys instead of provider-managed ones.

### How it works in this project

1. `meta/deepseek-byok.json` stores **metadata only** (provider, key reference URL, instructions)
2. At runtime, your application retrieves the real key from your KMS
3. The file is in `.gitignore` — never committed
4. The pre-commit hook blocks any file containing `api_key` or `private_key`

### KMS provider comparison

| Provider | CLI | Best for | Key reference format |
|----------|-----|----------|---------------------|
| **Azure Key Vault** | `az keyvault` | Azure workloads, Entra ID integration | `https://<vault>.vault.azure.net/secrets/<name>` |
| **AWS KMS** | `aws kms` | AWS workloads, IAM integration | `arn:aws:kms:<region>:<account>:key/<id>` |
| **HashiCorp Vault** | `vault` | Multi-cloud, on-prem, air-gapped | `secret/deepseek` |

### Setup flow

```
1. Choose a provider
2. Create a key/secret in your KMS
3. Run: WorkspaceManager.ps1 → Set DeepSeek BYOK
4. Enter provider name and key reference (NOT the key)
5. At runtime: your app calls KMS API → retrieves key → authenticates
```

### Security checklist

- [ ] `meta/deepseek-byok.json` is in `.gitignore`
- [ ] `meta/deepseek-keys.json` is in `.gitignore`
- [ ] Pre-commit hook blocks secrets
- [ ] No real keys on disk — only key references
- [ ] KMS access is logged and audited
- [ ] Key rotation is configured in your KMS

---

## 5. Troubleshooting

### "DeepSeek API returned an error"

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| 401 Unauthorized | Invalid or expired API key | Check `DEEPSEEK_API_KEY` env var. Rotate key if needed. |
| 429 Rate limited | Too many requests | Add delay between turns. Reduce subagent parallelism. |
| 500 Server error | DeepSeek infra issue | Retry after 30s. Check status.deepseek.com. |
| Timeout | Response took too long | Switch to `deepseek-flash`. Reduce context size. Compact earlier. |

### "Reasoning is in Chinese / mixed language"

Set explicitly:
```toml
language = "en"
reasoning_language = "en"
```

### "Response is too verbose / over-explains"

Add to your prompt:
```
Be concise. Do not explain what you are doing unless asked.
```

### "Model is slow for simple tasks"

Switch default to flash:
```toml
default_model = "deepseek-flash"
```

And use pro only for subagents that need it.

---

## 6. Cost Optimization

| Strategy | Saving | Trade-off |
|----------|--------|-----------|
| Use `deepseek-flash` as default | ~70% cheaper per turn | Slightly less reasoning depth |
| Compact at 70% instead of 80% | Fewer tokens per turn | May lose some context |
| Limit subagent parallelism | No parallel API calls | Slower overall, but cheaper |
| Prune stale tool results | Smaller context window | Slightly less history |
| Use `cold_resume_prune = true` | Clean resume context | May need to re-read files |

---

## 7. Skill Reference

This project includes two DeepSeek skills:

| Skill | Location | Purpose |
|-------|----------|---------|
| `deepseek-byok` | `skills/deepseek-byok/SKILL.md` | Manage BYOK metadata securely |
| `deepseek-reasonix` | `skills/deepseek-reasonix/SKILL.md` | Optimize Reasonix config for DeepSeek |

Install them:
```
Install skill from: C:\VSCode\Templates\skills\deepseek-byok
Install skill from: C:\VSCode\Templates\skills\deepseek-reasonix
```

---

## 8. Quick Reference Card

```toml
# Best all-round setup for DeepSeek + Reasonix
default_model = "deepseek-flash"

[agent]
temperature = 0.0
reasoning_language = "en"
planner_model = "deepseek-pro"
subagent_model = "deepseek-pro"
subagent_models = { review = "deepseek-pro", security_review = "deepseek-pro", explore = "deepseek-pro" }
subagent_efforts = { security_review = "max" }
soft_compact_ratio = 0.5
compact_ratio = 0.8
compact_force_ratio = 0.9
cold_resume_prune = true
```

```powershell
# Best prompt pattern
Goal: {one-line imperative}
- {step 1}
- {step 2}
Stop when: {measurable condition}
```
