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
$VSCodeRoot = Split-Path -Parent $PSScriptRoot
$RegistryPath = Join-Path $PSScriptRoot "vscode-tools.json"

# ── Registry helpers ──────────────────────────────

function Read-Registry {
    <# Returns tool objects from vscode-tools.json, or $null if missing/invalid. #>
    if (-not (Test-Path $RegistryPath)) { return @() }
    try {
        $reg = Get-Content $RegistryPath -Raw -Encoding UTF8 | ConvertFrom-Json
        return $reg.tools
    } catch {
        Write-Host "[WARN] vscode-tools.json is invalid: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "  Fix or delete it, then run 'vscode init' to regenerate." -ForegroundColor DarkGray
        return @()
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
        Where-Object { $_.FullName -notmatch '\\\.git\\' }
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
                $relPath = $f.FullName.Replace($VSCodeRoot + "\", "")
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

# ── Tool discovery ─────────────────────────────────

function Get-AllTools {
    <# Returns all tools: registry entries first, then scan discoveries.
       Registry wins on duplicate IDs. Scan duplicates get a warning. #>
    $tools = @(Read-Registry)
    $seen = @{}
    $result = @()
    foreach ($t in $tools) {
        $seen[$t.id] = $true
        $result += $t
    }

    # Scan for unregistered tools
    $files = Get-ChildItem -Path $VSCodeRoot -Recurse -Include @("*.ps1","*.bat","*.cmd") -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '\\\.git\\' }
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

            $relPath = $f.FullName.Replace($VSCodeRoot + "\", "")
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

# ── Menu rendering ─────────────────────────────────

function Show-Menu($tools) {
    try { Clear-Host } catch { try { [Console]::Clear() } catch {} }
    $termWidth = if ($host.UI.RawUI.WindowSize.Width -gt 0) { $host.UI.RawUI.WindowSize.Width } else { 80 }
    $w = [Math]::Min($termWidth - 2, 72)
    $bar = "-" * $w

    Write-Host ("╭{0}╮" -f $bar) -ForegroundColor Cyan
    Write-Host "│" -NoNewline -ForegroundColor Cyan
    Write-Host "  🏠  C:\VSCode — Universal Launcher" -ForegroundColor White -NoNewline
    $pad = $w - 32
    if ($pad -gt 0) { Write-Host (" " * $pad) -NoNewline }
    Write-Host " │" -ForegroundColor Cyan
    Write-Host ("├{0}┤" -f $bar) -ForegroundColor Cyan

    # Group by category, preserve registry order (not alphabetical)
    $categories = [System.Collections.Generic.List[object]]::new()
    $seenCats = @{}
    foreach ($tool in $tools) {
        $cat = if ($tool.category) { $tool.category } else { "Other" }
        if (-not $seenCats.ContainsKey($cat)) {
            $seenCats[$cat] = $true
            $categories.Add(@{ Name = $cat; Tools = @($tools | Where-Object { ($_.category -eq $cat) -or (-not $_.category -and $cat -eq 'Other') }) })
        }
    }

    $index = 1
    $map = @{}
    foreach ($group in $categories) {
        $header = "── $($group.Name) "
        $headerLen = 6 + $group.Name.Length
        $pad = $w - 2 - $headerLen
        Write-Host "│" -NoNewline -ForegroundColor Cyan
        Write-Host "  $header" -NoNewline -ForegroundColor DarkGray
        if ($pad -gt 0) { Write-Host ("-" * $pad) -NoNewline }
        Write-Host " │" -ForegroundColor Cyan

        foreach ($tool in $group.Tools) {
            $fullPath = Join-Path $VSCodeRoot $tool.path
            $exists = Test-Path $fullPath -ErrorAction SilentlyContinue
            $marker = if ($exists) { "✅" } else { "⚠️ " }
            $color = if ($exists) { "Green" } else { "Yellow" }
            $label = "[$index]$marker $($tool.name)"
            $rest = $w - 4 - $label.Length
            Write-Host "│ " -NoNewline -ForegroundColor Cyan
            Write-Host $label -NoNewline -ForegroundColor White
            if ($rest -gt 1 -and $tool.description) {
                Write-Host " " -NoNewline
                $desc = if ($tool.description.Length -gt $rest - 1) { $tool.description.Substring(0, $rest - 1) } else { $tool.description }
                Write-Host $desc -NoNewline -ForegroundColor DarkGray
                $rest = $rest - 1 - $desc.Length
            }
            if ($rest -gt 0) { Write-Host (" " * $rest) -NoNewline }
            Write-Host " │" -ForegroundColor Cyan
            $map["$index"] = $tool
            $index++
        }
    }

    Write-Host ("╰{0}╯" -f $bar) -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [0] Exit   ·   ? Help   ·   L List" -ForegroundColor DarkGray
    Write-Host ""
    return $map
}

# ── Dispatch ───────────────────────────────────────

function Invoke-Tool($tool) {
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
    Write-Host "  -----------------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  vscode              Interactive menu"
    Write-Host "  vscode <id> [args]  Dispatch directly to tool"
    Write-Host "  vscode list         Compact tool list (add -Json for JSON output)"
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
        if ($rest -contains "-Json") {
            $tools | Select-Object id, name, description, path, type, category |
                ConvertTo-Json -Depth 3 | Write-Host
        } else {
            foreach ($t in $tools) {
                Write-Host ("{0,-16} — {1}" -f $t.id, $t.description)
            }
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
            } else {
                Write-Host "  Invalid option." -ForegroundColor Red
                Start-Sleep -Seconds 1
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

# ── Tab completion ──────────────────────────────────

Register-ArgumentCompleter -CommandName 'vscode.ps1', 'vscode' -ParameterName 'id' -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $root = Split-Path -Parent $commandAst.Extent.File
    $regPath = Join-Path $root "vscode-tools.json"
    if (Test-Path $regPath) {
        $tools = (Get-Content $regPath -Raw -Encoding UTF8 | ConvertFrom-Json).tools
        foreach ($t in $tools) {
            if ($t.id -like "$wordToComplete*") {
                [System.Management.Automation.CompletionResult]::new($t.id, $t.id, 'ParameterValue', $t.description)
            }
        }
    }
}
