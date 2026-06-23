# Terminal — Profiles, Shell Integration & Tasks

A comprehensive guide to VS Code terminal configuration for this project — covering terminal profiles, shell integration setup, automated tasks, and best practices.

Based on official VS Code documentation:
- [Terminal Profiles](https://code.visualstudio.com/docs/terminal/profiles)
- [Shell Integration](https://code.visualstudio.com/docs/terminal/shell-integration)
- [Tasks](https://code.visualstudio.com/docs/debugtest/tasks)

---

## 1. Terminal Profiles

Terminal profiles define which shell executables are available in VS Code's integrated terminal. Profiles are platform-specific and can include custom arguments, environment variables, and icons.

### Profiles in This Project

The sample workspace (`templates/sample-project.code-workspace`) pre-configures these Windows profiles:

| Profile | Shell | Use Case |
|---------|-------|----------|
| **PowerShell 7 (fast)** | `pwsh.exe -NoProfile` | Quick commands, no startup overhead |
| **PowerShell 7 (full)** | `pwsh.exe` | Full profile with modules and customizations |
| **Windows PowerShell** | `powershell.exe` | Legacy scripts, system administration |
| **Git Bash** | `bash.exe --login` | POSIX commands, git workflows |
| **Command Prompt** | `cmd.exe` | Batch files, legacy tools |
| **WSL (Ubuntu)** | `wsl.exe -d Ubuntu` | Linux environment on Windows |

### Adding Your Own Profiles

To add a custom profile, open VS Code settings (`Ctrl+,`) and add to `terminal.integrated.profiles.windows`:

```json
{
  "terminal.integrated.profiles.windows": {
    "Custom Init": {
      "path": "pwsh.exe",
      "args": ["-noexit", "-file", "${env:APPDATA}\\PowerShell\\custom-init.ps1"]
    }
  },
  "terminal.integrated.defaultProfile.windows": "Custom Init"
}
```

**Profile properties:**

| Property | Type | Description |
|----------|------|-------------|
| `path` | string | Path to the shell executable |
| `source` | string | Auto-detect source (`PowerShell` or `Git Bash` on Windows) |
| `args` | string[] | Command-line arguments passed to the shell |
| `overrideName` | boolean | Replace dynamic title with the profile name |
| `env` | object | Environment variables (set `null` to delete) |
| `icon` | string | Icon ID (e.g., `terminal-powershell`, `terminal-bash`) |
| `color` | string | Theme color ID for the icon |

### Setting the Default Profile

Use the **Terminal: Select Default Profile** command from the command palette or set it directly:

```json
"terminal.integrated.defaultProfile.windows": "PowerShell 7 (full)"
```

### The Automation Profile

Tasks and debugging use a separate profile by default. Configure it for a fast, non-interactive shell:

```json
"terminal.integrated.automationProfile.windows": {
  "path": "pwsh.exe",
  "args": ["-NoProfile", "-Command"]
}
```

### Removing Built-in Profiles

To hide a default profile from the dropdown, set it to `null`:

```json
"terminal.integrated.profiles.windows": {
  "Git Bash": null
}
```

### Profile-Specific Keyboard Shortcuts

Bind a key to launch a terminal with a specific profile:

```json
{
  "key": "ctrl+shift+t",
  "command": "workbench.action.terminal.newWithProfile",
  "args": { "profileName": "PowerShell 7 (fast)" }
}
```

---

## 2. Shell Integration

Shell integration gives VS Code deep awareness of what's happening inside the terminal — command boundaries, exit codes, working directory, and more.

### What Shell Integration Enables

| Feature | Description |
|---------|-------------|
| **Command decorations** | Green check ✓ or red X ✗ next to each command based on exit code |
| **Command navigation** | `Ctrl+↑`/`Ctrl+↓` to jump between commands |
| **Sticky scroll** | Keep the current command visible when scrolling through output |
| **Recent command** | `Ctrl+Alt+R` to search and re-run past commands |
| **Recent directory** | `Ctrl+G` to navigate to previously visited directories |
| **Quick fixes** | VS Code suggests actions based on command output (e.g., kill a port in use) |
| **IntelliSense** | Tab-completion for files, folders, and command arguments inside the terminal |
| **CWD detection** | Links in terminal output reliably open the correct file |
| **Enhanced accessibility** | Audio cues on command failure, accessible command navigation |

### Automatic Injection (Default)

Shell integration scripts are automatically injected when the terminal starts. This works for:
- **Windows:** PowerShell 7+, Windows PowerShell, Git Bash
- **Linux/macOS:** bash, fish, zsh, pwsh

> **Windows note:** VS Code shell integration requires permission to run PowerShell scripts. If you see restrictions, run:
> ```powershell
> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```

If automatic injection doesn't work (sub-shells, SSH sessions, complex setups), use manual installation below.

### Manual Installation

Set `"terminal.integrated.shellIntegration.enabled": false` first, then add to your shell init file.

#### PowerShell 7 (pwsh)

Add to `$PROFILE` (`code $Profile` to open):

```powershell
if ($env:TERM_PROGRAM -eq "vscode") {
  . "$(code --locate-shell-integration-path pwsh)"
}
```

#### bash / Git Bash

Add to `~/.bashrc`:

```bash
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path bash)"
```

#### zsh

Add to `~/.zshrc`:

```zsh
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"
```

#### fish

Add to `$__fish_config_dir/config.fish`:

```fish
string match -q "$TERM_PROGRAM" "vscode"
and . (code --locate-shell-integration-path fish)
```

### Performance Tip

The `code --locate-shell-integration-path` command starts Node.js, adding a small delay. For faster startup, resolve the path ahead of time and inline it:

```bash
# Resolve once:
code --locate-shell-integration-path bash
# → /usr/share/code/resources/app/out/vs/workbench/contrib/terminal/browser/media/shell-integration.sh

# Then hardcode in your init file:
[[ "$TERM_PROGRAM" == "vscode" ]] && . "/path/from/above/shell-integration.sh"
```

### Checking Shell Integration Status

Hover the terminal tab to see the integration quality:
- **Rich** — Full command detection with exit codes
- **Basic** — Command detection without exit status
- **None** — No shell integration active

---

## 3. Tasks

Tasks automate common workflows — building, testing, linting, and running scripts — directly from VS Code.

### Tasks in This Project

The sample workspace defines these tasks (run via **Terminal → Run Task** or `Ctrl+Shift+B` for build tasks):

| Task | Group | What It Does |
|------|-------|-------------|
| **Validate All JSON** | `test` | Validates every `.json` file in the project |
| **Validate All .code-workspace** | `test` | Validates every `.code-workspace` file |
| **Run CI Checks Locally** | `test` | Runs the GitHub Actions workflow via `act` |
| **Launch Workspace Manager** | — | Opens the interactive `WorkspaceManager.ps1` menu |
| **Validate This Workspace JSON** | `test` | Validates the current workspace file itself |
| **Check VS Code Prerequisites** | — | Reports PowerShell, VS Code CLI, and git versions |
| **Full Validation** | `test` | Chains all validation tasks via `dependsOn` (JSON + workspace + CI) |

**Task groups:**
- `build` — Accessible via `Ctrl+Shift+B`
- `test` — Accessible via the **Run Test Task** command
- `none` — Only accessible via **Run Task**

### Task Configuration Reference

Tasks live in `.vscode/tasks.json` for a workspace folder, or directly in a `.code-workspace` file under the `"tasks"` property.

```json
{
  "label": "Task Name",           // Display name
  "detail": "What this task does", // Description shown in task picker
  "type": "shell",                // "shell" or "process"
  "command": "pwsh",              // Executable to run
  "args": ["-NoProfile", "..."],  // Arguments
  "group": "test",                // "build", "test", or "none"
  "dependsOn": ["Task A"],        // Run this task after dependencies
  "presentation": {
    "reveal": "always",           // When to show terminal: "always", "silent", "never"
    "panel": "new",               // Terminal panel: "shared", "dedicated", "new"
    "clear": true                 // Clear terminal before running
  },
  "problemMatcher": []            // Parse output for errors/warnings
}
```

### Key Task Settings

| Setting | Purpose |
|---------|---------|
| `detail` | Description shown in the task picker alongside the label |
| `options.cwd` | Working directory for the task |
| `options.env` | Environment variables |
| `options.shell` | Override the shell used (e.g., `cmd.exe` for batch scripts) |
| `dependsOn` | Chain tasks: array of task labels to run before this one |
| `runOptions` | Run behavior (e.g., `runOn: "folderOpen"` to auto-run) |
| `isBackground` | Mark a task as long-running/watching |
| `problemMatcher` | Parse output for errors and warnings |

### Chaining Tasks with `dependsOn`

```json
{
  "label": "Full Validation",
  "dependsOn": ["Validate All JSON", "Validate This Workspace JSON"],
  "group": "test",
  "presentation": {
    "panel": "dedicated"
  }
}
```

### Keyboard Shortcuts for Tasks

Bind a key to any task:

```json
{
  "key": "ctrl+shift+v",
  "command": "workbench.action.tasks.runTask",
  "args": "Validate All JSON"
}
```

---

## 4. Terminal Best Practices

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `` Ctrl+` `` | Toggle terminal panel |
| `Ctrl+Shift+` `` | Create new terminal |
| `Ctrl+Shift+5` | Split terminal |
| `Ctrl+↑` / `Ctrl+↓` | Navigate between commands (with shell integration) |
| `Ctrl+Alt+R` | Run recent command |
| `Ctrl+G` | Go to recent directory |
| `Ctrl+Shift+B` | Run build task |
| `Ctrl+Space` | Trigger terminal IntelliSense |
| `Alt+Click` | Move cursor to clicked position |

### Recommended Settings

These are already set in the sample workspace. The command guide (`showCommandGuide`) adds a visual bar beside commands when hovered, making it easier to identify and verifying shell integration is active:

```json
{
  "terminal.integrated.shellIntegration.enabled": true,
  "terminal.integrated.shellIntegration.decorationsEnabled": "both",
  "terminal.integrated.shellIntegration.showCommandGuide": true,
  "terminal.integrated.stickyScroll.enabled": true,
  "terminal.integrated.suggest.enabled": true,
  "terminal.integrated.suggest.quickSuggestions": true,
  "terminal.integrated.splitCwd": "inherited",
  "terminal.integrated.localEchoEnabled": "auto",
  "terminal.integrated.cursorBlinking": true,
  "terminal.integrated.cursorStyle": "line",
  "terminal.integrated.enableMultiLinePasteWarning": true,
  "terminal.integrated.gpuAcceleration": "auto"
}
```

### Using the Automation Profile

The automation profile (`terminal.integrated.automationProfile.*`) controls which shell tasks and debug features use. Configure a fast, lean shell here to avoid loading heavy startup scripts for every task run.

```json
"terminal.integrated.automationProfile.windows": {
  "path": "pwsh.exe",
  "args": ["-NoProfile", "-Command"]
}
```

---

## 5. Troubleshooting

### Shell Integration Not Working

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| No command decorations | Automatic injection failed | Manually install shell integration (see §2) |
| Decorations show when disabled | Another terminal's integration script is active | Set `"terminal.integrated.shellIntegration.decorationsEnabled": "never"` |
| Command decorations jump around (Windows) | ConPTY rendering offset | VS Code heuristics will correct it — this is normal |

### Task "command not found"

Tasks run as non-login, non-interactive shells — startup scripts are not sourced.

| Fix | How |
|-----|-----|
| Add command to system PATH | Best long-term fix |
| Run as login shell | `"options": { "shell": { "args": ["-c", "-l"] } }` |
| Use full executable path | Specify the absolute path to the tool |

### Duplicate PATH entries (macOS)

Terminal runs as a login shell, re-sourcing profile scripts. Fixes:

| Fix | Setting |
|-----|---------|
| Disable environment inheritance | `"terminal.integrated.inheritEnv": false` |
| Use non-login shell profile | Create a profile with empty `args` |

### Pre-commit Hook Blocks Your Commit

```bash
git commit --no-verify   # Bypass hook (only if you're sure it's a false positive)
```

---

## 6. Quick Reference

### Terminal Commands (PowerShell)

```powershell
# Open VS Code settings JSON
code $env:APPDATA\Code\User\settings.json

# Open PowerShell profile
code $Profile

# Set execution policy for shell integration
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Check shell integration script location
code --locate-shell-integration-path pwsh
```

### Task Commands

```powershell
# Run CI checks locally
act -W .github/workflows/validate.yml

# Validate a specific JSON file
jq . file.json

# Launch workspace manager
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts\WorkspaceManager.ps1
```
