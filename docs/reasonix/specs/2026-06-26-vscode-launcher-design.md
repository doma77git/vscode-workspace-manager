# C:\VSCode Universal Launcher — Design Spec

**Date:** 2026-06-26  
**Status:** Design approved · awaiting implementation plan

## Goal

One command — `vscode` — to discover, list, and launch any tool under `C:\VSCode` from any directory. Interactive menu by default, direct dispatch with arguments.

## Architecture

```
C:\VSCode\
├── vscode.ps1              ← Universal launcher (main script, ~150 lines)
├── vscode.cmd               ← Windows batch stub
├── vscode.sh                ← Bash stub (Linux/macOS/WSL)
├── vscode-tools.json        ← Tool registry (curated, primary source of truth)
├── Build-Multiboot-Final.ps1
├── Templates/               ← Workspace Manager (existing)
│   └── wsm.ps1
└── ...
```

`vscode.ps1` auto-discovers its own location via `$PSScriptRoot`. All tool paths in the registry are relative to `$PSScriptRoot` (resolved to absolute at runtime). Zero dependency on any subdirectory internals — it calls `pwsh -File`, never dot-sources.

## Tool Registry (`vscode-tools.json`)

```json
{
  "version": "1.0",
  "tools": [
    {
      "id": "wsm",
      "name": "Workspace Manager",
      "description": "Manage VS Code workspaces, profiles, trust, BYOK",
      "path": "Templates\\wsm.ps1",
      "type": "ps1",
      "category": "VS Code",
      "args": ""
    },
    {
      "id": "multiboot",
      "name": "Build Multiboot",
      "description": "WinPE + Ventoy multiboot USB builder",
      "path": "Build-Multiboot-Final.ps1",
      "type": "ps1",
      "category": "System",
      "args": ""
    }
  ]
}
```

**Fields:** `id` (unique, kebab-case), `name` (display), `description` (one line), `path` (relative to `C:\VSCode`, forward or backslash), `type` (ps1/bat/cmd), `category` (grouping), `args` (reserved for future, currently unused).

## Scan Fallback (Discovery Marker)

Tools not in the registry are discovered by scanning for a comment header:

```powershell
### VSCodeTool: id="backup", name="Auto Backup", desc="Backup everything to zip", category="Maintenance"
```

Scan logic: `Select-String -Pattern '### VSCodeTool:'` across `*.ps1`, `*.bat`, `*.cmd`. Parsed key=value pairs get added to the tool list under a "Discovered" category. Registry entries take priority; duplicates get a "duplicate-" prefix with a warning.

## Dispatch Flow

```
Input: vscode [name] [args...]

1. Resolve $PSScriptRoot → set $VSCodeRoot
2. Load vscode-tools.json (if missing → generate from scan → write default)
3. Scan for unregistered tools (VSCodeTool headers)
4. Merge: registry first, scan discoveries last

If name provided:
  a. Find tool by id → resolve path: Join-Path $VSCodeRoot $tool.path
  b. Verify file exists → dispatch: pwsh -NoProfile -File <fullPath> @args
  c. Exit with same code as the tool
  d. Not found: "Unknown tool: <name>. Run 'vscode' to see menu." Exit 1

If no name:
  a. Group tools by category
  b. Render interactive menu (box-drawn, emoji icons)
  c. User picks number → dispatch
```

## Special Commands

| Command | Behavior |
|---------|----------|
| `vscode help` | Show tool list + usage |
| `vscode list` | Compact: `id — description` per line |
| `vscode init` | Regenerate `vscode-tools.json` from scan |
| `vscode add <path> [name] [desc] [category]` | Add/update a tool entry |

## Menu Format

```
╭──────────────────────────────────────────────────────╮
│  🏠  C:\VSCode — Universal Launcher                  │
├──────────────────────────────────────────────────────┤
│  ── VS Code ────────────────────────────────────────│
│  [1] 📄 Workspace Manager   Manage workspaces, profiles
│  ── System ─────────────────────────────────────────│
│  [2] 💿 Build Multiboot     WinPE + Ventoy USB builder
│  ── Discovered ─────────────────────────────────────│
│  [3] 💾 Auto Backup         Backup everything to zip
├──────────────────────────────────────────────────────┤
│  [0] Exit   ·   ? Help                               │
╰──────────────────────────────────────────────────────╯
▶
```

Categories only shown if they have tools. "Discovered" section only if scan found unregistered entries. Max one category per tool.

## Error Handling

| Scenario | Behavior |
|----------|----------|
| `vscode-tools.json` missing | Warn, scan, generate default, write it, proceed |
| `vscode-tools.json` invalid JSON | "Invalid JSON. Fix or delete it to regenerate." Exit 1 |
| Tool path doesn't exist | Menu: skip with ⚠️ marker. Dispatch: "[ERROR] not found" Exit 1 |
| Unknown tool name | "Unknown tool: <name>. Try 'vscode' to see all." Exit 1 |
| Tool crashes | Exit with same code. No wrapper masking. |
| Duplicate IDs | First registry entry wins. Scan duplicates get "duplicate-" prefix + warning |
| Called from wrong directory | No effect — `$PSScriptRoot` always resolves to `C:\VSCode` |
| No `pwsh` (batch stub) | Fall back to `powershell.exe`, then error with install link |

## Stub Launchers

### `vscode.cmd` (Windows)
```batch
@echo off
set "ROOT=%~dp0"
where pwsh >nul 2>&1
if %errorlevel% neq 0 (powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%vscode.ps1" %* & exit /b)
pwsh -NoProfile -ExecutionPolicy Bypass -File "%ROOT%vscode.ps1" %*
```

### `vscode.sh` (Linux/macOS/WSL)
```bash
#!/usr/bin/env bash
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
pwsh -NoProfile -ExecutionPolicy Bypass -File "$SCRIPT_DIR/vscode.ps1" "$@"
```

## Testing

| Test | Command |
|------|---------|
| AST parse | Auto-covered by `Run-Tests.ps1` (scans all .ps1) |
| JSON validation | Auto-covered by `Run-Validate.ps1` (scans all .json) |
| `vscode wsm validate -Json` | Should return JSON — tests registry dispatch |
| `vscode nonexistent` | Exit 1, error message |
| `vscode list` | Prints tool list |
| Scan fallback | Test script with `### VSCodeTool:` header appears in discovered |

Test fixtures in `Templates/tests/`: `valid-tool.ps1` (has header), `bad-tool.ps1` (no header).

## Non-Goals

- **No cross-tool orchestration** — `vscode` dispatches to one tool at a time
- **No tool versioning** — tool versions are managed by their own repositories
- **No GUI** — terminal-only, like the Workspace Manager
- **No plugin loading** — no dot-sourcing, no in-process execution
- **No logging** — tools handle their own output

## Dependencies

- PowerShell 7+ (`pwsh`)
- Git Bash or WSL (for `vscode.sh` on Linux/macOS)
- No npm/pip/cargo — pure PowerShell

## Conventions

- UTF-8 without BOM
- Exit 0 on success, 1 on failure
- `pwsh -NoProfile -File` for all dispatches
- Box-drawn terminal UI with rounded corners (╭╮╰╯) and emoji icons
