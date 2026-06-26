# Code Review Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the 8 verified bugs from the code review of the current working diff.

**Architecture:** Targeted fixes to existing files — no new architecture. Move `Validate-JsonFile` into the shared helper, fix the CI workflow subshell bug, correct the Write-Banner metric mismatch, replace the dead WebException catch with the correct pwsh 7 exception type, revert the trust.json security default, extract a `Get-TestCount` helper, fix the hardcoded gist string, and move `Get-CronLine` before `exit 0`.

**Tech Stack:** PowerShell 7+, GitHub Actions (bash), JSON

## Global Constraints

- PowerShell 7.0+ (from psd1 PowerShellVersion)
- All shared functions live in `scripts/Helper-Functions.ps1`
- Callers already dot-source Helper-Functions.ps1 via the module or directly

---

### Task 1: Move Validate-JsonFile to Helper-Functions.ps1

The function is defined only in `WorkspaceManager.ps1:27-41` but called by `Invoke-ProfileOperations.ps1:29`, `Invoke-TemplateOperations.ps1:96,114`, and `Invoke-WorkspaceOperations.ps1:29`. When the module is loaded via `Import-Module VSCodeWorkspaceManager`, WorkspaceManager.ps1 is never dot-sourced, so these calls throw `CommandNotFoundException`.

**Files:**
- Modify: `scripts/Helper-Functions.ps1:143` (add function before Export section)
- Modify: `scripts/WorkspaceManager.ps1:27-41` (delete the function definition)
- Modify: `VSCodeWorkspaceManager.psd1` (add `Validate-JsonFile` to FunctionsToExport)

**Interfaces:**
- Produces: `Validate-JsonFile` available in module scope for all Invoke-*.ps1 callers

- [ ] **Step 1: Add Validate-JsonFile to Helper-Functions.ps1**

Insert before the `# ── Export ──` section at line 143:

```powershell
function Validate-JsonFile {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        Write-Host "[ERROR] File not found: $Path" -ForegroundColor Red
        return $false
    }
    try {
        $null = Get-Content $Path -Raw -Encoding UTF8 | ConvertFrom-Json
        Write-Host "[OK] Valid JSON: $Path" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "[ERROR] Invalid JSON in $Path : $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}
```

- [ ] **Step 2: Delete Validate-JsonFile from WorkspaceManager.ps1**

Remove lines 27-41 (the entire `function Validate-JsonFile { ... }` block).

- [ ] **Step 3: Add Validate-JsonFile to FunctionsToExport in psd1**

In `VSCodeWorkspaceManager.psd1`, add `'Validate-JsonFile'` to the `FunctionsToExport` array.

- [ ] **Step 4: Verify**

Run: `pwsh -NoProfile -Command "Import-Module ./VSCodeWorkspaceManager.psd1 -Force; Get-Command Validate-JsonFile"`

Expected: Shows the command info without error.

- [ ] **Step 5: Commit**

```bash
git add scripts/Helper-Functions.ps1 scripts/WorkspaceManager.ps1 VSCodeWorkspaceManager.psd1
git commit -m "fix: move Validate-JsonFile to Helper-Functions for module scope"
```

---

### Task 2: Fix CI JSON lint subshell bug

Lines 21 and 28 of `validate.yml` use `find ... | while read f; do ... exit 1 ... done`. The `exit 1` only kills the subshell created by the pipe — the pipeline exits 0 (find succeeded). Invalid JSON passes CI silently. Apply the same process-substitution fix already used for the secrets-scan step.

**Files:**
- Modify: `.github/workflows/validate.yml:19-31`

- [ ] **Step 1: Fix the JSON lint step (line 19-24)**

Replace:
```yaml
      - name: Validate .json files
        run: |
          find . -name "*.json" -not -path "./.git/*" | while read f; do
            echo "Validating: $f"
            jq . "$f" > /dev/null || { echo "INVALID JSON: $f"; exit 1; }
          done
```

With:
```yaml
      - name: Validate .json files
        run: |
          FAIL=0
          while IFS= read -r f; do
            echo "Validating: $f"
            jq . "$f" > /dev/null || { echo "INVALID JSON: $f"; FAIL=1; }
          done < <(find . -name "*.json" -not -path "./.git/*")
          [ "$FAIL" -eq 0 ] || exit 1
```

- [ ] **Step 2: Fix the workspace lint step (line 26-31)**

Replace:
```yaml
      - name: Validate .code-workspace files
        run: |
          find . -name "*.code-workspace" -not -path "./.git/*" | while read f; do
            echo "Validating: $f"
            jq . "$f" > /dev/null || { echo "INVALID JSON: $f"; exit 1; }
          done
```

With:
```yaml
      - name: Validate .code-workspace files
        run: |
          FAIL=0
          while IFS= read -r f; do
            echo "Validating: $f"
            jq . "$f" > /dev/null || { echo "INVALID JSON: $f"; FAIL=1; }
          done < <(find . -name "*.code-workspace" -not -path "./.git/*")
          [ "$FAIL" -eq 0 ] || exit 1
```

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/validate.yml
git commit -m "fix: JSON lint steps now fail CI on invalid files"
```

---

### Task 3: Fix Write-Banner byte/char mismatch

Line 32 uses `UTF8.GetByteCount` to size the box (emoji = 4 bytes), but line 40 uses `.Length` for padding (emoji = 2 chars in .NET). The two metrics disagree, misaligning the right `║` border. Fix: use `.Length` consistently — it's what the console uses to advance the cursor for `Write-Host`.

**Files:**
- Modify: `scripts/Helper-Functions.ps1:28-45`

- [ ] **Step 1: Replace GetByteCount with .Length**

Replace lines 30-33:
```powershell
    $innerWidth = 50
    $text = "  $emoji  $title"
    $textLen = [System.Text.Encoding]::UTF8.GetByteCount($text)
    if ($textLen -gt $innerWidth - 4) { $innerWidth = $textLen + 6 }
```

With:
```powershell
    $innerWidth = 50
    $text = "  $emoji  $title"
    if ($text.Length -gt $innerWidth - 4) { $innerWidth = $text.Length + 6 }
```

- [ ] **Step 2: Verify visually**

Run: `pwsh -NoProfile -Command ". scripts/Helper-Functions.ps1; Write-Banner 'Extension Check' '🔌'"`

Expected: The `║` borders align with the `═` top/bottom borders.

- [ ] **Step 3: Commit**

```bash
git add scripts/Helper-Functions.ps1
git commit -m "fix: Write-Banner uses consistent .Length for box sizing and padding"
```

---

### Task 4: Fix dead WebException catch on pwsh 7

PowerShell 7's `Invoke-WebRequest` uses `HttpClient` and throws `Microsoft.PowerShell.Commands.HttpResponseException` for HTTP errors, not `System.Net.WebException`. The typed catch at line 72 never fires; all errors fall to the generic catch with an unhelpful message.

**Files:**
- Modify: `scripts/Check-Extensions.ps1:62-88`

- [ ] **Step 1: Replace WebException catch with HttpResponseException**

Replace lines 72-84:
```powershell
    } catch [System.Net.WebException] {
        $statusCode = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { 0 }
        if ($statusCode -eq 404) {
            $reason = "not found in marketplace"
        } elseif ($statusCode -eq 429) {
            $reason = "rate limited"
        } elseif ($statusCode -ge 500) {
            $reason = "marketplace server error"
        } else {
            $reason = "network issue ($($_.Exception.Message))"
        }
        $missing += $extId
        if (-not $Json) { Write-Warn $extId "$reason (from $source)" }
```

With:
```powershell
    } catch [Microsoft.PowerShell.Commands.HttpResponseException] {
        $statusCode = [int]$_.Exception.Response.StatusCode
        if ($statusCode -eq 404) {
            $reason = "not found in marketplace"
        } elseif ($statusCode -eq 429) {
            $reason = "rate limited"
        } elseif ($statusCode -ge 500) {
            $reason = "marketplace server error"
        } else {
            $reason = "HTTP $statusCode"
        }
        $missing += $extId
        if (-not $Json) { Write-Warn $extId "$reason (from $source)" }
```

- [ ] **Step 2: Verify the catch fires**

Run: `pwsh -NoProfile -Command ". scripts/Helper-Functions.ps1; . scripts/Check-Extensions.ps1 -Workspace templates/python-dev.code-workspace"`

Expected: Any 404 extensions show "not found in marketplace" rather than "unexpected error".

- [ ] **Step 3: Commit**

```bash
git add scripts/Check-Extensions.ps1
git commit -m "fix: catch HttpResponseException instead of WebException on pwsh 7"
```

---

### Task 5: Revert trust.json security default

`emptyWorkspaceTrust` was changed from `false` to `true`. This weakens the security posture — unknown workspaces are now auto-trusted. Also fix the missing trailing newline.

**Files:**
- Modify: `meta/trust.json`

- [ ] **Step 1: Revert emptyWorkspaceTrust and fix newline**

Set the full content of `meta/trust.json` to:
```json
{
  "version": "1.0",
  "emptyWorkspaceTrust": false,
  "autoUpdateCheck": true,
  "trustedParentFolders": [],
  "decisions": [],
  "updatedAt": "2026-06-23T20:15:00Z",
  "description": "Record of workspace trust decisions and auto-update preferences. Empty by default — populate decisions as workspaces are reviewed."
}
```

(Note: file must end with a newline.)

- [ ] **Step 2: Commit**

```bash
git add meta/trust.json
git commit -m "fix: revert emptyWorkspaceTrust to false (security default)"
```

---

### Task 6: Extract Get-TestCount helper and fix hardcoded gist string

The test-count formula is copy-pasted in `Generate-Docs.ps1:29`, `Launch-Reasonix.ps1:40`, and `Update-Gists.ps1:27`. It should be a `Get-TestCount` helper in `Helper-Functions.ps1` alongside the existing count helpers. Also fix `Update-Gists.ps1:39` which hardcodes "21 JSON + 7 YAML" instead of using computed values.

**Files:**
- Modify: `scripts/Helper-Functions.ps1:141` (add Get-TestCount after Get-ScriptCount)
- Modify: `scripts/Generate-Docs.ps1:29-31` (use Get-TestCount)
- Modify: `scripts/Launch-Reasonix.ps1:39-42` (use Get-TestCount)
- Modify: `scripts/Update-Gists.ps1:27-29` (use Get-TestCount)
- Modify: `scripts/Update-Gists.ps1:38-39` (fix hardcoded breakdown string)
- Modify: `VSCodeWorkspaceManager.psd1` (add Get-TestCount to FunctionsToExport)

**Interfaces:**
- Consumes: `Get-TemplatesRoot` from Helper-Functions.ps1
- Produces: `Get-TestCount` returning an integer

- [ ] **Step 1: Add Get-TestCount to Helper-Functions.ps1**

Insert after `Get-ScriptCount` (after line 141):

```powershell
function Get-TestCount {
    $root = Get-TemplatesRoot
    $ps1 = (Get-ChildItem -Path (Join-Path $root "scripts") -Recurse -Filter "*.ps1" -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\.git\\' }).Count
    $json = (Get-ChildItem $root -Recurse -Include @("*.json", "*.code-workspace") -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\.git\\' }).Count
    $yaml = (Get-ChildItem $root -Recurse -Include @("*.yml", "*.yaml") -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\.git\\' }).Count
    return $ps1 + $json + $yaml + 2
}
```

- [ ] **Step 2: Replace inline formula in Generate-Docs.ps1**

Replace lines 29-31:
```powershell
    TestCount    = (Get-ChildItem (Join-Path $root "scripts") -Recurse -Filter "*.ps1" -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\.git\\' }).Count `
                + (Get-ChildItem $root -Recurse -Include @("*.json", "*.code-workspace") -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\.git\\' }).Count `
                + (Get-ChildItem $root -Recurse -Include @("*.yml", "*.yaml") -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\.git\\' }).Count + 2
```

With:
```powershell
    TestCount    = Get-TestCount
```

- [ ] **Step 3: Replace inline formula in Launch-Reasonix.ps1**

Replace lines 39-42:
```powershell
$testCount = (Get-ChildItem (Join-Path (Get-TemplatesRoot) "scripts") -Recurse -Filter "*.ps1" -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\.git\\' }).Count `
           + (Get-ChildItem (Get-TemplatesRoot) -Recurse -Include @("*.json", "*.code-workspace") -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\.git\\' }).Count `
           + (Get-ChildItem (Get-TemplatesRoot) -Recurse -Include @("*.yml", "*.yaml") -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\.git\\' }).Count + 2
Write-Host ("  Tests: {0}  ·  Version: v{1}" -f $testCount, (Get-CurrentVersion)) -ForegroundColor Cyan
```

With:
```powershell
Write-Host ("  Tests: {0}  ·  Version: v{1}" -f (Get-TestCount), (Get-CurrentVersion)) -ForegroundColor Cyan
```

- [ ] **Step 4: Replace inline formula in Update-Gists.ps1**

Replace lines 27-29:
```powershell
    tests     = (Get-ChildItem (Join-Path $root "scripts") -Recurse -Filter "*.ps1" -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\.git\\' }).Count `
              + (Get-ChildItem $root -Recurse -Include @("*.json", "*.code-workspace") -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\.git\\' }).Count `
              + (Get-ChildItem $root -Recurse -Include @("*.yml", "*.yaml") -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\.git\\' }).Count + 2
```

With:
```powershell
    tests     = Get-TestCount
```

- [ ] **Step 5: Fix hardcoded breakdown in Update-Gists.ps1**

Replace lines 38-39:
```powershell
    $gists = $gists -replace '\d+ checks: \d+ PS AST \+ \d+ JSON \+ \d+ YAML',
        "$($stats.tests) checks: $($stats.scripts) PS AST + 21 JSON + 7 YAML + 2 integration"
```

With:
```powershell
    $jsonCount = (Get-ChildItem $root -Recurse -Include @("*.json", "*.code-workspace") -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\.git\\' }).Count
    $yamlCount = (Get-ChildItem $root -Recurse -Include @("*.yml", "*.yaml") -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\.git\\' }).Count
    $gists = $gists -replace '\d+ checks: \d+ PS AST \+ \d+ JSON \+ \d+ YAML',
        "$($stats.tests) checks: $($stats.scripts) PS AST + $jsonCount JSON + $yamlCount YAML + 2 integration"
```

- [ ] **Step 6: Add Get-TestCount to FunctionsToExport**

In `VSCodeWorkspaceManager.psd1`, add `'Get-TestCount'` to the `FunctionsToExport` array.

- [ ] **Step 7: Verify**

Run: `pwsh -NoProfile -Command ". scripts/Helper-Functions.ps1; Get-TestCount"`

Expected: Returns a number (the total file-based test count).

- [ ] **Step 8: Commit**

```bash
git add scripts/Helper-Functions.ps1 scripts/Generate-Docs.ps1 scripts/Launch-Reasonix.ps1 scripts/Update-Gists.ps1 VSCodeWorkspaceManager.psd1
git commit -m "refactor: extract Get-TestCount helper, fix hardcoded gist breakdown"
```

---

### Task 7: Move Get-CronLine before exit 0 in Schedule-Tasks.ps1

`Get-CronLine` is defined at line 168, after `exit 0` at line 165. PowerShell function definitions are executed statements — the function is never registered. Calls at lines 92 and 137 fail on Linux/macOS.

**Files:**
- Modify: `scripts/Schedule-Tasks.ps1`

- [ ] **Step 1: Cut Get-CronLine from line 168-183 and paste before line 60**

Move the entire function block to the top of the file, right after the `$taskDefs` setup and before any action logic. Place it before the `if ($Action -eq "list")` block. Delete the original at lines 167-183 (including the blank line after `exit 0`).

The function to move:
```powershell
function Get-CronLine($task) {
    $scriptPath = Join-Path $TemplatesRoot $task.Script
    $args = if ($task.Args) { " $($task.Args)" } else { "" }

    $time = $task.Time -split ":"
    $hour = [int]$time[0]
    $minute = [int]$time[1]

    $cronSchedule = switch ($task.Schedule) {
        "daily"   { "$minute $hour * * *" }
        "weekly"  { "$minute $hour * * 1" }
        "monthly" { "$minute $hour 1 * *" }
    }

    return "$cronSchedule pwsh -NoProfile -File '$scriptPath'$args"
}
```

Also remove the now-unnecessary `exit 0` at line 165 — the script will naturally end after the action blocks.

- [ ] **Step 2: Verify syntax**

Run: `pwsh -NoProfile -Command "& { $null = [System.Management.Automation.Language.Parser]::ParseFile('scripts/Schedule-Tasks.ps1', [ref]$null, [ref]$null) }; Write-Host 'OK'"`

Expected: `OK` (no parse errors).

- [ ] **Step 3: Commit**

```bash
git add scripts/Schedule-Tasks.ps1
git commit -m "fix: move Get-CronLine before exit so it is defined when called"
```

---
