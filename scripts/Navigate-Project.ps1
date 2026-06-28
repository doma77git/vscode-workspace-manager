<#
.SYNOPSIS
    Interactive project navigator — browse the workspace manager structure.
.DESCRIPTION
    Provides an interactive menu for exploring the project: view directory tree,
    read file contents, jump to documentation, see architecture overview.
    Useful for understanding the codebase without leaving the terminal.
.EXAMPLE
    pwsh -NoProfile -File scripts\Navigate-Project.ps1
#>

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\Helper-Functions.ps1"

$root = Get-TemplatesRoot
$choice = ""

do {
    try { Clear-Host } catch { Write-Host "" }
    Write-Banner "VS Code Workspace Manager — Navigator" "🧭"

    Write-Host "  ── Explore ───────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "  1) 📁  Directory tree"
    Write-Host ("  2) 📄  Script catalog ({0} scripts)" -f (Get-ScriptCount))
    Write-Host "  3) 📚  Documentation index"
    Write-Host "  4) 📋  Menu option map"
    Write-Host ""
    Write-Host "  ── Inspect ───────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "  5) 🔍  Search files"
    Write-Host "  6) 📖  Read a file"
    Write-Host "  7) 📊  Project stats"
    Write-Host ""
    Write-Host "  ── Architecture ──────────────────────────────" -ForegroundColor DarkGray
    Write-Host "  8) 🏗️   Architecture overview"
    Write-Host "  9) 🔗  Component dependency map"
    Write-Host ""
    Write-Host "   0) 🚪  Exit"
    Write-Host ""

    $choice = Read-Host "Select"

    switch ($choice) {
        "1" { Show-DirectoryTree }
        "2" { Show-ScriptCatalog }
        "3" { Show-DocIndex }
        "4" { Show-MenuMap }
        "5" { Invoke-SearchFiles }
        "6" { Invoke-ReadFile }
        "7" { Show-ProjectStats }
        "8" { Show-ArchitectureOverview }
        "9" { Show-ComponentMap }
    }
} while ($choice -ne "0")

# ── Navigation Functions ─────────────────────────

function Show-DirectoryTree {
    Write-Banner "Directory Tree" "📁"
    Push-Location $root
    try {
        & git ls-files --others --exclude-standard --cached 2>$null | Out-Null
        Write-Host "  $(Split-Path $root -Leaf)/" -ForegroundColor Cyan
        Get-ChildItem -Directory | ForEach-Object {
            Write-Host "  ├── $($_.Name)/" -ForegroundColor White
            Get-ChildItem $_.FullName -File | Select-Object -First 5 | ForEach-Object {
                Write-Host "  │   ├── $($_.Name)" -ForegroundColor DarkGray
            }
            $remaining = (Get-ChildItem $_.FullName -File).Count - 5
            if ($remaining -gt 0) {
                Write-Host "  │   └── ... +$remaining more" -ForegroundColor DarkGray
            }
        }
        Get-ChildItem -File | ForEach-Object {
            Write-Host "  ├── $($_.Name)" -ForegroundColor DarkGray
        }
    } finally { Pop-Location }
    Write-Host ""
    Pause
}

function Show-ScriptCatalog {
    Write-Banner "Script Catalog" "📄"
    $scripts = Get-ChildItem (Join-Path $root "scripts") -Filter "*.ps1" | Sort-Object Name

    Write-Host "  $(Split-Path $root -Leaf)/scripts/" -ForegroundColor Cyan
    Write-Host ""
    foreach ($s in $scripts) {
        $content = Get-Content $s.FullName -Raw
        $synopsis = ""
        if ($content -match '\.SYNOPSIS\s*\n\s*(.+)') { $synopsis = $matches[1].Trim() }

        $badge = switch -Wildcard ($s.Name) {
            "Run-*"       { "🏃 Runner" }
            "Check-*"     { "🔍 Checker" }
            "Helper-*"    { "🔧 Helper" }
            "Open-*"      { "🚀 Launcher" }
            "Update-*"    { "🔄 Updater" }
            "Auto-*"      { "💾 Backup" }
            "Schedule-*"  { "⏰ Scheduler" }
            "Recommend-*" { "💡 Recommender" }
            "Workspace*"  { "⚙️  Manager" }
            "Init-*"      { "🏗️  Setup" }
            default       { "📄 Script" }
        }
        Write-Host "  $badge  $($s.Name)" -ForegroundColor White
        if ($synopsis) { Write-Host "          $synopsis" -ForegroundColor DarkGray }
        Write-Host ""
    }
    Pause
}

function Show-DocIndex {
    Write-Banner "Documentation Index" "📚"

    $docs = Get-ChildItem (Join-Path $root "docs") -Filter "*.md" | Sort-Object Name
    $roots = Get-ChildItem $root -Filter "*.md" | Sort-Object Name

    Write-Host "  Core Docs (docs/)" -ForegroundColor Cyan
    foreach ($d in $docs) {
        Write-Host "  📖  $($d.Name)" -ForegroundColor White
    }

    Write-Host ""
    Write-Host "  Root Docs" -ForegroundColor Cyan
    foreach ($r in $roots) {
        Write-Host "  📄  $($r.Name)" -ForegroundColor DarkGray
    }

    Write-Host ""
    Write-Host "  Prompts Library (prompts/)" -ForegroundColor Cyan
    Get-ChildItem (Join-Path $root "prompts") -Filter "*.md" | ForEach-Object {
        Write-Host "  💬  $($_.Name)" -ForegroundColor DarkGray
    }
    Pause
}

function Show-MenuMap {
    Write-Banner "Menu Option Map" "📋"
    Write-Host "  ⚙️  WorkspaceManager.ps1 — 15 options" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  ── Workspace ─────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "   1  📄 Check VS Code settings      → Check-VSCodeSettings"
    Write-Host "   2  🆕 New workspace template       → New-WorkspaceTemplate"
    Write-Host "   3  💾 Save workspace template      → Save-WorkspaceTemplate"
    Write-Host "   6  🚀 Open workspace               → Open-Workspace"
    Write-Host "   9  🔍 Search templates             → Search-Templates"
    Write-Host ""
    Write-Host "  ── Profiles ──────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "   7  👤 Profiles management          → Submenu (list/import/export)"
    Write-Host "  13  🔬 Scan project                 → Invoke-ScanProject"
    Write-Host ""
    Write-Host "  ── Security ──────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "   4  🔑 Set DeepSeek BYOK           → Set-DeepSeekBYOK"
    Write-Host "   5  🛡️  Set Workspace Trust         → Set-EmptyWorkspaceTrust"
    Write-Host ""
    Write-Host "  ── Tools ─────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "   8  🏗️  Init repo                   → Init-TemplatesRepo"
    Write-Host "  10  ✅ Run validation               → Invoke-ValidateChecks"
    Write-Host "  11  📖 Open docs                    → Invoke-OpenDocs"
    Write-Host "  12  ℹ️  About / version             → Invoke-About"
    Write-Host "  14  🔄 Check for updates            → Invoke-UpdateCheck"
    Write-Host "  15  ⏰ Schedule tasks               → Invoke-ScheduleTasks"
    Write-Host ""
    Write-Host "   0  🚪 Exit"
    Pause
}

function Invoke-SearchFiles {
    Write-Host ""
    $query = Read-Host "Search for (file name or content pattern)"
    Write-Host ""
    # Name search
    $nameHits = Get-ChildItem $root -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match $query -and $_.FullName -notmatch '\\.git\\' }
    # Content search
    $contentHits = Get-ChildItem $root -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '\\.git\\' } |
        ForEach-Object {
            $c = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
            if ($c -match $query) { $_ }
        }

    if ($nameHits) {
        Write-Host "  📁  Name matches:" -ForegroundColor Green
        $nameHits | ForEach-Object {
            Write-Host "      $($_.Name)" -ForegroundColor Cyan
        }
        Write-Host ""
    }
    if ($contentHits) {
        Write-Host "  📄  Content matches:" -ForegroundColor Green
        $contentHits | ForEach-Object {
            Write-Host "      $($_.Name)" -ForegroundColor Cyan
        }
    }
    if (-not $nameHits -and -not $contentHits) {
        Write-Host "  No matches for '$query'" -ForegroundColor Yellow
    }
    Write-Host ""
    Pause
}

function Invoke-ReadFile {
    Write-Host ""
    $file = Read-Host "Enter file path (relative to project root)"
    $fullPath = Join-Path $root $file
    if (Test-Path $fullPath) {
        try { Clear-Host } catch { Write-Host "" }
        Write-Host "  📖  $file" -ForegroundColor Cyan
        Write-Host ("─" * 60) -ForegroundColor DarkGray
        Get-Content $fullPath | Select-Object -First 40 | ForEach-Object { Write-Host $_ -ForegroundColor DarkGray }
        $lines = (Get-Content $fullPath).Count
        if ($lines -gt 40) {
            Write-Host ("─" * 60) -ForegroundColor DarkGray
            Write-Host "  ... +$($lines - 40) more lines. Open full file: code $fullPath" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  ❌  File not found: $fullPath" -ForegroundColor Red
    }
    Write-Host ""
    Pause
}

function Show-ProjectStats {
    Write-Banner "Project Stats" "📊"
    Write-Pass "Templates" "$(Get-TemplateCount)"
    Write-Pass "Profiles" "$(Get-ProfileCount)"
    Write-Pass "Scripts" "$(Get-ScriptCount)"
    Write-Pass "Docs" "$(Get-DocCount)"
    Write-Pass "Prompts" "$((Get-ChildItem (Join-Path $root 'prompts') -Filter '*.md' -ErrorAction SilentlyContinue).Count)"
    Write-Pass "CI workflows" "$((Get-ChildItem (Join-Path $root '.github/workflows') -Filter '*.yml' -ErrorAction SilentlyContinue).Count)"
    Write-Pass "Version" "v$(Get-CurrentVersion)"

    $totalFiles = (Get-ChildItem $root -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\.git\\' }).Count
    Write-Pass "Total files" $totalFiles

    $psLines = (Get-ChildItem (Join-Path $root 'scripts') -Filter '*.ps1' | ForEach-Object { (Get-Content $_.FullName).Count } | Measure-Object -Sum).Sum
    Write-Pass "PS lines of code" $psLines
    Write-Host ""
    Pause
}

function Show-ArchitectureOverview {
    Write-Banner "Architecture Overview" "🏗️"
    Write-Host "  Layers:" -ForegroundColor White
    Write-Host "    🖥️   UI Layer       : WorkspaceManager.ps1 (15-option menu)" -ForegroundColor Cyan
    Write-Host "    🧠  Logic Layer     : 11 specialized scripts" -ForegroundColor Green
    Write-Host "    💾  Data Layer      : templates/, profiles/, meta/" -ForegroundColor Yellow
    Write-Host "    🔧  Utility Layer   : Helper-Functions.ps1" -ForegroundColor DarkGray
    Write-Host "    🔒  Security Layer  : pre-commit, CI, BYOK" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Data Flow:" -ForegroundColor White
    Write-Host "    User → Menu → Function → Script → File System" -ForegroundColor DarkGray
    Write-Host "    User → CLI (make/npm/pwsh) → Script → Output" -ForegroundColor DarkGray
    Write-Host "    CI → validate.yml → jq/grep → Pass/Fail" -ForegroundColor DarkGray
    Write-Host "    Scheduler → Schedule-Tasks → Auto-Backup/Validate/Update" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Full diagram: docs/ARCHITECTURE.md (Mermaid UML)" -ForegroundColor Yellow
    Pause
}

function Show-ComponentMap {
    Write-Banner "Component Dependency Map" "🔗"

    $comps = @(
        @{ Name = "WorkspaceManager.ps1";       Depends = "Helper-Functions.ps1, Run-Validate.ps1, Update-Self.ps1, Schedule-Tasks.ps1" },
        @{ Name = "Helper-Functions.ps1";        Depends = "(none — shared library)" },
        @{ Name = "Run-Validate.ps1";             Depends = "Helper-Functions.ps1" },
        @{ Name = "Run-Checks.ps1";               Depends = "Run-Validate.ps1, Helper-Functions.ps1" },
        @{ Name = "Run-Tests.ps1";                Depends = "Helper-Functions.ps1" },
        @{ Name = "Check-Environment.ps1";        Depends = "Helper-Functions.ps1" },
        @{ Name = "Open-WithProfile.ps1";         Depends = "Helper-Functions.ps1" },
        @{ Name = "Update-Self.ps1";              Depends = "Run-Tests.ps1" },
        @{ Name = "Auto-Backup.ps1";              Depends = "Helper-Functions.ps1" },
        @{ Name = "Schedule-Tasks.ps1";           Depends = "Run-Validate.ps1, Auto-Backup.ps1, Update-Self.ps1" },
        @{ Name = "Recommend-Extensions.ps1";     Depends = "Helper-Functions.ps1" },
        @{ Name = "Init-TemplatesRepo.ps1";       Depends = "(none — standalone)" }
    )

    foreach ($c in $comps) {
        Write-Host "  📦  $($c.Name)" -ForegroundColor White
        Write-Host "      ↳ depends: $($c.Depends)" -ForegroundColor DarkGray
        Write-Host ""
    }
    Pause
}
