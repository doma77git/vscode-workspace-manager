---
name: vscode-helper
description: Using the C:\VSCode universal launcher? Load first — always dispatch via vscode, never run scripts or edit registry directly.
type: project
runAs: inline
allowedTools: [read_file, write_file, edit_file, bash, ask, grep, glob]
---

# C:\VSCode Universal Launcher — Operations

Full reference for using the `vscode` universal launcher: discover, dispatch, register, and manage tools.

## When to use
- User says "run a tool", "launch something", "vscode", "universal launcher"
- User needs to add, remove, or discover tools in the launcher
- User asks what tools are available
- User wants to run validation, tests, or the workspace manager

## Quick Commands

```powershell
vscode                    # Interactive menu (discover all tools)
vscode list               # Compact tool list (id + description)
vscode list -Json         # JSON output for programmatic use
vscode help               # Usage help
vscode <id> [args]        # Dispatch directly: vscode wsm validate
vscode init               # Regenerate registry from scan
```

## The Cardinal Rule

**ALWAYS dispatch via `vscode`.** Never run scripts under `C:\VSCode\` directly:

```
✅  vscode wsm validate         # Correct
✅  pwsh -File vscode.ps1 wsm   # Correct (from Templates root)
❌  pwsh -File scripts/Run-Validate.ps1   # Wrong — bypasses launcher
❌  pwsh -File wsm.ps1                    # Wrong — use vscode wsm instead
```

Why? The launcher discovers tools, handles path resolution, and provides a consistent interface. Running scripts directly breaks discoverability and skips the menu.

## Tool Discovery

### List available tools

```powershell
vscode list                           # Human-readable
vscode list -Json                     # Machine-readable JSON
pwsh -NoProfile -File vscode.ps1 list # From Templates root
```

### Registry (`vscode-tools.json`)

The primary source of truth is `C:\VSCode\Templates\vscode-tools.json`. Each entry:

```json
{
  "id": "tool-id",
  "name": "Display Name",
  "description": "What it does",
  "path": "relative\\path.ps1",
  "type": "ps1",
  "category": "Category"
}
```

### Scan fallback (`### VSCodeTool:` headers)

Tools without registry entries are discovered by scanning for this header comment:

```powershell
### VSCodeTool: id="my-tool", name="My Tool", desc="Description", category="Category"
```

## Adding a Tool

**Never edit vscode-tools.json by hand.** Two ways:

### Option A: Registry (preferred)

Use `vscode init` to regenerate the registry from scan headers, then manually add if needed:

```powershell
vscode init   # Regenerate from scan headers
```

OR add the `### VSCodeTool:` header to the script itself — `vscode init` will discover it.

### Option B: Direct add (use `vscode add`)

```powershell
# Not yet implemented — use Option A for now
```

## Dispatching Tools

### By ID (any directory)

```powershell
vscode wsm                    # Workspace Manager
vscode wsm validate           # Pass args through
vscode wsm validate -Json     # JSON output
vscode multiboot              # Build Multiboot
```

### Interactive menu (any directory)

```powershell
vscode                        # Shows numbered menu
```

Select a number → tool runs. Press `?` for help, `L` for tool list, `0` to exit.

## Existing Tools

| ID | Name | Description | Category |
|----|------|-------------|----------|
| `wsm` | Workspace Manager | Manage templates, profiles, trust, BYOK | VS Code |
| `multiboot` | Build Multiboot | WinPE + Ventoy USB builder | System |

## Planning a New Tool

**REQUIRED SUB-SKILL:** Use the **superpowers-brainstorming** skill before adding any new tool to the launcher. Every tool needs a design: purpose, arguments, output, error handling. Don't create scripts or registry entries without an approved design.

## Conventions

- **Do NOT create files the user didn't ask for** — if a script path doesn't exist, ask the user before creating it
- **Do NOT edit vscode-tools.json by hand** — use `vscode init` or add the scan header to the script
- **Do NOT run scripts directly** — always dispatch through `vscode`
- **ALWAYS ask before modifying** the registry, creating tools, or writing new scripts
- UTF-8 without BOM for all files
- PowerShell: PascalCase functions, `-NoProfile -File` execution

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Running `Run-Validate.ps1` directly | Use `vscode wsm validate` instead |
| Editing `vscode-tools.json` by hand | Add `### VSCodeTool:` header to script, run `vscode init` |
| Creating scripts without asking | Stop. Ask the user what they want. |
| Dispatching with wrong path | Use `vscode list` to find the correct tool ID |
| Forgetting to run `vscode init` after adding a header | Re-run to update registry |
