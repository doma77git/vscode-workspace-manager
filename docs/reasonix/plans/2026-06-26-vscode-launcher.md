# C:\VSCode Universal Launcher — Implementation Plan

> **For agentic workers:** implement this plan task-by-task — dispatch a fresh subagent per task with the native `task` tool (recommended for quality), or use the superpowers-executing-plans skill to work through it inline. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build `vscode.ps1` — a single universal launcher at `C:\VSCode\` that discovers, lists, and dispatches to any tool under `C:\VSCode` from any directory.

**Architecture:** One PowerShell script (`vscode.ps1`) with a JSON registry (`vscode-tools.json`) as the primary tool catalog and a regex scan fallback for unregistered tools. Thin batch/bash stubs for cross-platform PATH integration. No dependencies on subdirectory internals.

**Tech Stack:** PowerShell 7+, batch, bash. No npm/pip/cargo.

**Spec:** `docs/reasonix/specs/2026-06-26-vscode-launcher-design.md`

---

### Task 1: Test Fixtures

**Files:**
- Create: `tests/valid-tool.ps1`
- Create: `tests/bad-tool.ps1`

- [ ] **Step 1: Create valid-tool.ps1 test fixture**

```powershell
### VSCodeTool: id="test-backup", name="Test Backup", desc="Test backup tool for scan discovery", category="Testing"
Write-Host "[test-backup] Running..." -ForegroundColor Green
```

- [ ] **Step 2: Create bad-tool.ps1 test fixture (no header)**

```powershell
Write-Host "[bad-tool] No VSCodeTool header — should not be discovered" -ForegroundColor Yellow
```

- [ ] **Step 3: Commit**

```bash
git add tests/valid-tool.ps1 tests/bad-tool.ps1
git commit -m "test: add VSCodeTool scan discovery test fixtures"
```

---

### Task 2: Registry File (vscode-tools.json)

**Files:**
- Create: `vscode-tools.json`

- [ ] **Step 1: Create initial registry with two default tools**

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

- [ ] **Step 2: Validate JSON syntax**

Run: `pwsh -NoProfile -Command "Get-Content vscode-tools.json -Raw | ConvertFrom-Json; Write-Host 'OK'"`

Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add vscode-tools.json
git commit -m "feat: add vscode-tools.json registry with wsm and multiboot entries"
```

---

### Task 3: Core Launcher Script (vscode.ps1)

**Files:**
- Create: `vscode.ps1`

- [ ] **Step 1: Write the failing test — load vscode-tools.json and verify tool count**

Run: `pwsh -NoProfile -Command ". vscode.ps1; Get-VScodeTools | Measure-Object | Select-Object -ExpandProperty Count"`

Expected: FAIL (function not defined yet)

- [ ] **Step 2: Write vscode.ps1 skeleton — path resolution, registry loading, help/list/init commands**

```powershell
<#
.SYNOPSIS
    C:\VSCode Universal Launcher — discover and launch any tool under C:\VSCode.
.DESCRIPTION
    Interactive menu by default. Dispatch directly with: vscode <tool-id> [args...].
    Source of truth: vscode-tools.json registry. Fallback: ### VSCodeTool: headers.
.EXAMPLE
    vscode                  # Interactive menu
    vscode wsm validate     # Dispatch directly to Workspace Manager
    vscode list             # List all tools
    vscode init             # Regenerate registry from scan
#>

$ErrorActionPreference = "Stop"
$VSCodeRoot = $PSScriptRoot
$RegistryPath = Join-Path $VSCodeRoot "vscode-tools.json"

# ── Registry helpers ──────────────────────────────

function Read-Registry {
    <# Returns tool objects from vscode-tools.json, or $null if missing/invalid. #>
    if (-not (Test-Path $RegistryPath)) { return $null }
    try {
        $reg = Get-Content $RegistryPath -Raw -Encoding UTF8 | ConvertFrom-Json
        return $reg.tools
    } catch {
        Write-Host "[WARN] vscode-tools.json is invalid: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "  Fix or delete it, then run 'vscode init' to regenerate." -ForegroundColor DarkGray
        return $null
    }
}

function Write-Registry($tools) {
    <# Writes a default registry from a list of tool objects. #>
    $reg = @{ version = "1.0"; tools = @($tools) }
    $reg | ConvertTo-Json -Depth 4 | Set-Content -Path $RegistryPath -Encoding UTF8 -NoNewline
}

function Initialize-Registry {
    <# Scan for VSCodeTool headers and generate a fresh registry. #>
    Write-Host "Scanning C:\VSCode for discoverable tools..." -ForegroundColor Cyan
    $found = @()
    $files = Get-ChildItem -Path $VSCodeRoot -Recurse -Include @("*.ps1","*.bat","*.cmd") -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '\\.git\\' }
    foreach ($f in $files) {
        $matches = Select-String -Path $f.FullName -Pattern '### VSCodeTool:' -SimpleMatch -ErrorAction SilentlyContinue
        foreach ($m in $matches) {
            $line = $m.Line
            $tool = @{ id = ""; name = ""; desc = ""; category = "Discovered" }
            if ($line -match 'id="([^"]*)"') { $tool.id = $matches[1] }
            if ($line -match 'name="([^"]*)"') { $tool.name = $matches[1] }
            if ($line -match 'desc="([^"]*)"') { $tool.desc = $matches[1] }
            if ($line -match 'category="([^"]*)"') { $tool.category = $matches[1] }
            if ($tool.id) {
                $relPath = $f.FullName.Replace($VSCodeRoot + "\", "").Replace("\", "\\")
                $tool.path = $relPath
                $tool.type = $f.Extension.TrimStart('.')
                $tool.args = ""
                $tool.description = $tool.desc
                $tool.PSObject.Properties.Remove('desc')
                $found += $tool
                Write-Host "  Found: $($tool.id) — $($tool.description)" -ForegroundColor Green
            }
        }
    }
    if ($found.Count -eq 0) {
        Write-Host "  No discoverable tools found." -ForegroundColor Yellow
    }
    Write-Registry @($found)
    return $found
}
```

- [ ] **Step 3: Run syntax check**

```bash
pwsh -NoProfile -Command "& { $null = [System.Management.Automation.Language.Parser]::ParseFile('vscode.ps1', [ref]$null, [ref]$null); Write-Host 'OK' }"
```

Expected: `OK`

- [ ] **Step 4: Commit**

```bash
git add vscode.ps1
git commit -m "feat: add vscode.ps1 skeleton — registry load/save, init scan"
```

---

### Task 4: Tool Discovery (registry + scan merge)

**Files:**
- Modify: `vscode.ps1`

- [ ] **Step 1: Write the failing test — scan discovers valid-tool.ps1**

```bash
pwsh -NoProfile -Command ". vscode.ps1; Initialize-Registry; $tools = Read-Registry; ($tools | Where-Object { $_.id -eq 'test-backup' }).Count"
```

Expected: FAIL (Initialize-Registry may exist, but not scanning tests/ yet — or returns 0)

- [ ] **Step 2: Add Get-AllTools function (registry-first, scan-fallback, dedup)**

Append to `vscode.ps1`:

```powershell
# ── Tool discovery ─────────────────────────────────

function Get-AllTools {
    <# Returns all tools: registry entries first, then scan discoveries.
       Registry wins on duplicate IDs. Scan duplicates get "duplicate-" prefix. #>
    $tools = @(Read-Registry)
    $seen = @{}
    $result = @()
    foreach ($t in $tools) {
        $seen[$t.id] = $true
        $result += $t
    }

    # Scan for unregistered tools
    $files = Get-ChildItem -Path $VSCodeRoot -Recurse -Include @("*.ps1","*.bat","*.cmd") -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '\\.git\\' }
    foreach ($f in $files) {
        $matches = Select-String -Path $f.FullName -Pattern '### VSCodeTool:' -SimpleMatch -ErrorAction SilentlyContinue
        foreach ($m in $matches) {
            $line = $m.Line
            $id = ""; if ($line -match 'id="([^"]*)"') { $id = $matches[1] }
            if (-not $id) { continue }

            if ($seen.ContainsKey($id)) {
                Write-Host "[WARN] Duplicate tool ID '$id' — skipping scan entry" -ForegroundColor Yellow
                continue
            }
            $seen[$id] = $true

            $name = ""; if ($line -match 'name="([^"]*)"') { $name = $matches[1] }
            $desc = ""; if ($line -match 'desc="([^"]*)"') { $desc = $matches[1] }
            $cat = "Discovered"
            if ($line -match 'category="([^"]*)"') { $cat = $matches[1] }

            $relPath = $f.FullName.Replace($VSCodeRoot + "\", "").Replace("\", "\\")
            $ext = $f.Extension.TrimStart('.')

            $result += [PSCustomObject]@{
                id = $id
                name = $name
                description = $desc
                path = $relPath
                type = $ext
                category = $cat
                args = ""
            }
        }
    }
    return $result
}
```

- [ ] **Step 3: Verify test-backup fixture is discovered**

```bash
pwsh -NoProfile -Command ". vscode.ps1; $tools = Get-AllTools; $t = $tools | Where-Object { $_.id -eq 'test-backup' }; Write-Host $t.name"
```

Expected: `Test Backup`

- [ ] **Step 4: Commit**

```bash
git add vscode.ps1
git commit -m "feat: add Get-AllTools — registry-first with scan fallback and dedup"
```

---

### Task 5: Menu Rendering

**Files:**
- Modify: `vscode.ps1`

- [ ] **Step 1: Add Show-Menu function**

Append to `vscode.ps1`:

```powershell
# ── Menu rendering ─────────────────────────────────

function Show-Menu($tools) {
    Clear-Host
    $termWidth = if ($host.UI.RawUI.WindowSize.Width -gt 0) { $host.UI.RawUI.WindowSize.Width } else { 80 }
    $w = [Math]::Min($termWidth - 2, 72)
    $bar = "─" * $w

    Write-Host "╭$bar╮" -ForegroundColor Cyan
    Write-Host "│" -NoNewline -ForegroundColor Cyan
    Write-Host "  🏠  C:\VSCode — Universal Launcher" -ForegroundColor White -NoNewline
    $pad = $w - 32
    if ($pad -gt 0) { Write-Host (" " * $pad) -NoNewline }
    Write-Host " │" -ForegroundColor Cyan
    Write-Host "├$bar┤" -ForegroundColor Cyan

    # Group by category
    $categories = $tools | Group-Object category
    $index = 1
    $map = @{}
    foreach ($group in $categories) {
        Write-Host "│" -NoNewline -ForegroundColor Cyan
        Write-Host "  ── $($group.Name) " -NoNewline -ForegroundColor DarkGray
        $headerLen = 6 + $group.Name.Length
        $pad = $w - 2 - $headerLen
        if ($pad -gt 0) { Write-Host ("─" * $pad) -NoNewline }
        Write-Host " │" -ForegroundColor Cyan
        foreach ($tool in $group.Group) {
            $exists = Test-Path (Join-Path $VSCodeRoot $tool.path)
            $marker = if ($exists) { "✅" } else { "⚠️ " }
            $color = if ($exists) { "Green" } else { "Yellow" }
            $label = "[$index]$marker $($tool.name)"
            $rest = $w - 4 - $label.Length
            Write-Host "│ " -NoNewline -ForegroundColor Cyan
            Write-Host $label -NoNewline -ForegroundColor White
            if ($rest -gt 1) {
                Write-Host " " -NoNewline
                Write-Host $tool.description.Substring(0, [Math]::Min($tool.description.Length, $rest - 1)) -NoNewline -ForegroundColor DarkGray
                $rest = $rest - 1 - [Math]::Min($tool.description.Length, $rest - 1)
            }
            if ($rest -gt 0) { Write-Host (" " * $rest) -NoNewline }
            Write-Host " │" -ForegroundColor Cyan
            $map["$index"] = $tool
            $index++
        }
    }

    Write-Host "╰$bar╯" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [0] Exit   ·   ? Help   ·   L List" -ForegroundColor DarkGray
    Write-Host ""
    return $map
}
```

- [ ] **Step 2: Run syntax check**

```bash
pwsh -NoProfile -Command "& { $null = [System.Management.Automation.Language.Parser]::ParseFile('vscode.ps1', [ref]$null, [ref]$null); Write-Host 'OK' }"
```

Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add vscode.ps1
git commit -m "feat: add Show-Menu — box-drawn, category-grouped, with status markers"
```

---

### Task 6: Dispatch & Main Loop

**Files:**
- Modify: `vscode.ps1`

- [ ] **Step 1: Add Invoke-Tool function**

Append to `vscode.ps1`:

```powershell
# ── Dispatch ───────────────────────────────────────

function Invoke-Tool($tool, $args) {
    $fullPath = Join-Path $VSCodeRoot $tool.path
    if (-not (Test-Path $fullPath)) {
        Write-Host "[ERROR] Tool '$($tool.id)' not found at: $fullPath" -ForegroundColor Red
        exit 1
    }
    & pwsh -NoProfile -ExecutionPolicy Bypass -File $fullPath @args
    exit $LASTEXITCODE
}

function Show-Help($tools) {
    Write-Host ""
    Write-Host "  C:\VSCode Universal Launcher" -ForegroundColor Cyan
    Write-Host "  ─────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  vscode              Interactive menu"
    Write-Host "  vscode <id> [args]  Dispatch directly to tool"
    Write-Host "  vscode list         Compact tool list"
    Write-Host "  vscode init         Regenerate registry from scan"
    Write-Host "  vscode help         This help"
    Write-Host ""
    if ($tools -and $tools.Count -gt 0) {
        Write-Host "  Available tools:" -ForegroundColor White
        foreach ($t in $tools) {
            Write-Host ("  {0,-16} — {1}" -f $t.id, $t.description) -ForegroundColor DarkGray
        }
    }
    Write-Host ""
}
```

- [ ] **Step 2: Add main entry point logic**

Append to `vscode.ps1`:

```powershell
# ── Main ───────────────────────────────────────────

$action = $args[0]
$rest = $args[1..$args.Count]

switch ($action) {
    "help" {
        $tools = Get-AllTools
        Show-Help $tools
        exit 0
    }
    "list" {
        $tools = Get-AllTools
        foreach ($t in $tools) {
            Write-Host ("{0,-16} — {1}" -f $t.id, $t.description)
        }
        exit 0
    }
    "init" {
        $tools = Initialize-Registry
        $count = if ($tools) { $tools.Count } else { 0 }
        Write-Host "[OK] Registry regenerated with $count tool(s)." -ForegroundColor Green
        exit 0
    }
    { $_ -in @("", $null) } {
        # Interactive menu
        $tools = Get-AllTools
        if ($tools.Count -eq 0) {
            Write-Host "[WARN] No tools found. Run 'vscode init' to scan for tools." -ForegroundColor Yellow
            exit 1
        }
        do {
            $map = Show-Menu $tools
            $choice = Read-Host "▶"
            if ($choice -eq "0") { Write-Host "Goodbye." -ForegroundColor Green; exit 0 }
            if ($choice -eq "?" -or $choice -eq "H" -or $choice -eq "h") { Show-Help $tools; Pause; continue }
            if ($choice -eq "L" -or $choice -eq "l") {
                foreach ($t in $tools) { Write-Host ("  {0,-16} — {1}" -f $t.id, $t.description) -ForegroundColor DarkGray }
                Pause; continue
            }
            if ($map.ContainsKey($choice)) {
                $tool = $map[$choice]
                Invoke-Tool $tool @()
            }
        } while ($true)
    }
    default {
        # Direct dispatch: vscode <tool-id> [args...]
        $tools = Get-AllTools
        $tool = $tools | Where-Object { $_.id -eq $action } | Select-Object -First 1
        if (-not $tool) {
            Write-Host "[ERROR] Unknown tool: $action" -ForegroundColor Red
            Write-Host "  Run 'vscode' to see all available tools." -ForegroundColor DarkGray
            exit 1
        }
        Invoke-Tool $tool @rest
    }
}
```

- [ ] **Step 3: Run syntax check**

```bash
pwsh -NoProfile -Command "& { $null = [System.Management.Automation.Language.Parser]::ParseFile('vscode.ps1', [ref]$null, [ref]$null); Write-Host 'OK' }"
```

Expected: `OK`

- [ ] **Step 4: Run integration test — direct dispatch to wsm validate**

```bash
pwsh -NoProfile -File vscode.ps1 wsm validate -Json 2>&1 | Select-String -Pattern '"passed"'
```

Expected: `"passed": true`

- [ ] **Step 5: Run integration test — list command**

```bash
pwsh -NoProfile -File vscode.ps1 list 2>&1
```

Expected: Shows `wsm` and `multiboot` entries

- [ ] **Step 6: Run integration test — unknown tool error**

```bash
pwsh -NoProfile -File vscode.ps1 nonexistent 2>&1; echo Exit: $LASTEXITCODE
```

Expected: Shows error, Exit 1

- [ ] **Step 7: Commit**

```bash
git add vscode.ps1
git commit -m "feat: add dispatch, main loop, help/list/init commands"
```

---

### Task 7: Launcher Stubs (vscode.cmd, vscode.sh)

**Files:**
- Create: `vscode.cmd`
- Create: `vscode.sh`

- [ ] **Step 1: Create vscode.cmd**

```batch
@echo off
set "ROOT=%~dp0"
where pwsh >nul 2>&1
if %errorlevel% neq 0 (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%vscode.ps1" %*
    exit /b %errorlevel%
)
pwsh -NoProfile -ExecutionPolicy Bypass -File "%ROOT%vscode.ps1" %*
exit /b %errorlevel%
```

- [ ] **Step 2: Create vscode.sh**

```bash
#!/usr/bin/env bash
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
pwsh -NoProfile -ExecutionPolicy Bypass -File "$SCRIPT_DIR/vscode.ps1" "$@"
exit $?
```

- [ ] **Step 3: Commit**

```bash
git add vscode.cmd vscode.sh
git commit -m "feat: add vscode.cmd and vscode.sh launcher stubs"
```

---

### Task 8: Installer Integration

**Files:**
- Modify: `install.ps1:154-174` (launcher stubs section)

- [ ] **Step 1: Add vscode stub creation to the launcher stubs section**

In the existing launcher stubs creation block in `install.ps1`, add vscode stubs alongside the existing wsm stubs. Insert after the wsm.sh creation block:

```powershell
        # vscode universal launcher stubs
        $vscodePsContent = "<#`r`n.SYNOPSIS`r`n    C:\\VSCode Universal Launcher — thin stub.`r`n.DESCRIPTION`r`n    Delegates to Templates\\vscode.ps1 (source of truth).`r`n#>  `$real = Join-Path `$PSScriptRoot ""Templates"" ""vscode.ps1"";`r`nif (Test-Path `$real) { & pwsh -NoProfile -ExecutionPolicy Bypass -File `$real @args; exit `$LASTEXITCODE }`r`nWrite-Host ""[ERROR] Launcher not found: `$real"" -ForegroundColor Red; exit 1`r`n"
        $vscodePsPath = Join-Path $parentDir "vscode.ps1"
        try {
            $vscodePsContent | Set-Content -Path $vscodePsPath -Encoding UTF8 -NoNewline
            Write-Host "  ✅  vscode.ps1 created" -ForegroundColor Green
        } catch { Write-Host "  ❌  vscode.ps1: $($_.Exception.Message)" -ForegroundColor Red }

        $vscodeCmdContent = "@echo off`r`nset ""REAL=%~dp0Templates\vscode.cmd""`r`nif not exist ""%REAL%"" (`r`n    echo [ERROR] Launcher not found: %REAL%`r`n    pause`r`n    exit /b 1`r`n)`r`ncall ""%REAL%"" %*`r`n"
        $vscodeCmdPath = Join-Path $parentDir "vscode.cmd"
        try {
            $vscodeCmdContent | Set-Content -Path $vscodeCmdPath -Encoding ASCII -NoNewline
            Write-Host "  ✅  vscode.cmd created" -ForegroundColor Green
        } catch { Write-Host "  ❌  vscode.cmd: $($_.Exception.Message)" -ForegroundColor Red }

        $vscodeShContent = "#!/usr/bin/env bash`nREAL=""`$(dirname ""`$0"")/Templates/vscode.sh""`nif [ ! -f ""`$REAL"" ]; then echo ""[ERROR] Launcher not found: `$REAL"" >&2; exit 1; fi`npwsh -NoProfile -ExecutionPolicy Bypass -File ""`$REAL"" ""`$@""`nexit `$?`n"
        $vscodeShPath = Join-Path $parentDir "vscode.sh"
        try {
            $vscodeShContent | Set-Content -Path $vscodeShPath -Encoding ASCII -NoNewline
            Write-Host "  ✅  vscode.sh created" -ForegroundColor Green
        } catch { Write-Host "  ❌  vscode.sh: $($_.Exception.Message)" -ForegroundColor Red }
```

- [ ] **Step 2: Commit**

```bash
git add install.ps1
git commit -m "feat: add vscode stub creation to installer"
```

---

### Task 9: Final Validation

- [ ] **Step 1: Run full test suite**

```bash
make test
```

Expected: All 37+ PS AST, 35+ JSON, 7 YAML, 3+ integration PASS. `vscode.ps1` and `vscode-tools.json` included in scans.

- [ ] **Step 2: Run vscode list from repo**

```bash
pwsh -NoProfile -File vscode.ps1 list 2>&1
```

Expected: Shows `wsm` and `multiboot` tools.

- [ ] **Step 3: Run vscode direct dispatch end-to-end**

```bash
pwsh -NoProfile -File vscode.ps1 wsm validate -Json 2>&1 | Select-String '"ok"'
```

Expected: Shows `"ok":35` or similar.

- [ ] **Step 4: Commit final validation results**

```bash
git add -A
git commit -m "test: final validation — all tests pass, vscode dispatch works end-to-end"
```
