# Module: Invoke-OpenDocs
# Dot-sourced by WorkspaceManager.ps1

function Invoke-OpenDocs {
    Write-Host ""
    Write-Host "  ── Open Documentation ────────────────────────" -ForegroundColor DarkGray
    $docs = @(
        @{ Name = "Documentation Portal (INDEX)";        Path = "docs\INDEX.md" },
        @{ Name = "Terminal (profiles, tasks)";           Path = "docs\TERMINAL.md" },
        @{ Name = "Architecture (UML diagrams)";          Path = "docs\ARCHITECTURE.md" },
        @{ Name = "UML Diagrams (standalone)";            Path = "docs\UML.md" },
        @{ Name = "Workspace Trust (security)";           Path = "docs\WORKSPACE-TRUST.md" },
        @{ Name = "DeepSeek Recommendations";             Path = "docs\DEEPSEEK-RECOMMENDATIONS.md" },
        @{ Name = "Automation & Scheduling";              Path = "docs\AUTOMATION.md" },
        @{ Name = "Self-Update Guide";                    Path = "docs\SELF-UPDATE.md" },
        @{ Name = "How-To Recipes";                       Path = "docs\HOWTO.md" },
        @{ Name = "Tune-Up Guide";                        Path = "docs\TUNEUP.md" },
        @{ Name = "FAQ";                                  Path = "docs\FAQ.md" },
        @{ Name = "BYOK Guide";                           Path = "docs\BYOK-GUIDE.md" }
    )

    for ($i = 0; $i -lt $docs.Count; $i++) {
        $docPath = Join-Path $TemplatesRoot $docs[$i].Path
        if (Test-Path $docPath) {
            Write-Host ("  {0,2}) 📖  {1}" -f ($i+1), $docs[$i].Name) -ForegroundColor Green
        } else {
            Write-Host ("  {0,2}) ⚠️  {1} [not found]" -f ($i+1), $docs[$i].Name) -ForegroundColor DarkGray
        }
    }
    Write-Host "   0) 🚪  Back"
    Write-Host ""

    $docChoice = Read-Host "Select doc to open"
    if ($docChoice -match '^\d+$' -and [int]$docChoice -gt 0 -and [int]$docChoice -le $docs.Count) {
        $selected = $docs[[int]$docChoice - 1]
        $fullPath = Join-Path $TemplatesRoot $selected.Path
        if (Test-Path $fullPath) {
            & code $fullPath
            Write-Host "  ✅  Opening: $fullPath" -ForegroundColor Green
        } else {
            Write-Host "  ❌  File not found: $fullPath" -ForegroundColor Red
        }
    }
    Pause
}
