# Agents Window Integration — VS Code Workspace Manager

How this project integrates with the [VS Code Agents Window](https://code.visualstudio.com/docs/agents/agents-window).

---

## What the Agents Window Is

The Agents window is a dedicated VS Code window optimized for agent-first workflows. It gives you access to all workspaces from one place, lets you run multiple agent sessions in parallel, and shares the same agent sessions, settings, and keybindings with the main VS Code window.

**Agent types supported:** Copilot CLI, Copilot Cloud, Claude agent
**This project supports:** Copilot CLI + Claude agent (local), DeepSeek v4 (via BYOK)

---

## How Our Project Integrates

### 1. Workspace Trust
The Agents window requires folder trust before agents can run. Our `meta/trust.json` tracks trust decisions and is shared between the editor and Agents window:

```json
{
  "emptyWorkspaceTrust": false,
  "trustedParentFolders": ["C:\\TrustedRepos"],
  "decisions": [...]
}
```

**Recommendation:** Keep `emptyWorkspaceTrust: false` for security. Trust parent folders once, and all subfolders inherit trust in both windows.

### 2. Agent Customizations Panel
The Agents window has a Customizations panel for:

| Customization | Our Project Support |
|---------------|-------------------|
| Agents | Custom agent personas — our 4 Reasonix skills |
| Skills | `skills/` directory — 3 installable skills |
| Instructions | `prompts/agent-templates.md` — ready-to-use configs |
| Hooks | `scripts/pre-commit`, `pre-push`, `post-commit` |
| MCP Servers | Installable via our skill system |

### 3. Tasks for Agent Validation
Configure tasks in the Agents window to validate agent changes:

```json
{
  "label": "Validate Project",
  "command": "pwsh",
  "args": ["-NoProfile", "-File", "scripts/Run-All.ps1", "-Quick"],
  "runOptions": { "runOn": "folderOpen" }
}
```

Add to any `.code-workspace` file under `tasks.tasks` or use `Terminal → Configure Tasks` in the Agents window.

### 4. Terminal in Agents Window
The integrated terminal in the Agents window uses the same profiles configured in our workspace templates. All 6 Windows profiles are available.

### 5. Settings Scoped to Agents Window
Override settings for the Agents window only:

```json
{
  "window.title": "${dirty} ${activeEditorShort} — Agents [Workspace Manager]",
  "terminal.integrated.defaultProfile.windows": "PowerShell 7 (fast)",
  "workbench.colorTheme": "Default Dark+"
}
```

---

## Recommended Agent Workflow

```
1. Open Agents Window: code --agents
   └─ or Ctrl+Shift+P → Chat: Open Agents Window

2. Select workspace: C:\VSCode\Templates
   └─ Trust if prompted (or use meta/trust.json)

3. Choose agent type:
   ├─ Copilot CLI — for local file operations
   ├─ Claude agent — for complex reasoning
   └─ DeepSeek v4 — via BYOK (configure in meta/deepseek-byok.json)

4. Add context:
   ├─ AGENTS.md — project context
   ├─ prompts/agent-flows.md — decision trees
   └─ prompts/agent-templates.md — task templates

5. Run tasks to validate agent changes:
   ├─ make test (53 checks)
   ├─ make validate
   └─ make checks

6. Review changes in the Changes panel
   └─ Commit, merge, or request edits
```

---

## DeepSeek v4 Agent Configuration

```toml
# reasonix.toml
config_version = 3
default_model = "deepseek-flash"

[agent]
temperature = 0.0
reasoning_language = "en"
planner_model = "deepseek-v4"        # DeepSeek v4 for complex planning
subagent_model = "deepseek-pro"      # Pro for subagents
subagent_models = {
    review = "deepseek-v4",          # DeepSeek v4 for code review
    security_review = "deepseek-v4", # DeepSeek v4 for security
    explore = "deepseek-pro",
    research = "deepseek-v4"         # DeepSeek v4 for research
}
subagent_efforts = {
    review = "high",
    security_review = "max",
    research = "high"
}

[skills]
paths = [".reasonix/skills"]
```

---

## Agent-Specific Workspace Settings

Add to your `.code-workspace` file for optimal agent experience:

```json
{
  "settings": {
    "chat.agent.workspaceContext": true,
    "chat.agent.terminal.enabled": true,
    "sessions.changes.openSingleFileDiff": false,
    "terminal.integrated.automationProfile.windows": {
      "path": "pwsh.exe",
      "args": ["-NoProfile", "-Command"]
    },
    "extensions.supportAgentsWindow": {
      "editorconfig.editorconfig": true
    }
  }
}
```

---

## Quick Commands

```powershell
# Open Agents Window
code --agents

# Open project in Agents Window
code --agents C:\VSCode\Templates

# Run validation from agent terminal
make test

# Check trust status
Get-Content meta\trust.json | ConvertFrom-Json

# Install custom skills for agents
# → Agents Window → Customizations panel → Skills → Install from C:\VSCode\Templates\skills\
```
