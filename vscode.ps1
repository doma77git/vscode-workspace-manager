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
