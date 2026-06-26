### VSCodeTool: id="docs", name="Docs Portal", desc="Browse all project documentation", category="Docs"
<#
.SYNOPSIS
    Opens the documentation portal in VS Code.
    Called by vscode universal launcher or directly.
#>

[CmdletBinding()]
param(
    [switch]$ListOnly,
    [switch]$Help
)

$TemplatesRoot = Split-Path -Parent $PSScriptRoot

# If $ListOnly, print the doc catalog
if ($ListOnly) {
    Write-Host "`n  Documentation Portal" -ForegroundColor Cyan
    Write-Host "  ===============================================" -ForegroundColor DarkGray
    Write-Host ""
    
    $docs = @(
        @{ num = 1; name = "INDEX"; desc = "Master index" },
        @{ num = 2; name = "ARCHITECTURE"; desc = "UML diagrams, system design" },
        @{ num = 3; name = "UML"; desc = "Standalone UML collection" },
        @{ num = 4; name = "WORKFLOW"; desc = "Day-to-day usage patterns" },
        @{ num = 5; name = "HOWTO"; desc = "12 common recipes" },
        @{ num = 6; name = "BYOK-GUIDE"; desc = "DeepSeek BYOK explained" },
        @{ num = 7; name = "WORKSPACE-TRUST"; desc = "Trust settings deep-dive" },
        @{ num = 8; name = "TERMINAL"; desc = "Profiles, shell, tasks" },
        @{ num = 9; name = "DEEPSEEK-RECOMMENDATIONS"; desc = "Model tuning" },
        @{ num = 10; name = "AUTOMATION"; desc = "Scheduling" },
        @{ num = 11; name = "SELF-UPDATE"; desc = "Self-update guide" },
        @{ num = 12; name = "FAQ"; desc = "Frequent questions" },
        @{ num = 13; name = "SETUP"; desc = "Detailed setup" },
        @{ num = 14; name = "CI-CD"; desc = "GitHub Actions workflows" },
        @{ num = 15; name = "PRD"; desc = "Product requirements" },
        @{ num = 16; name = "GRAPHICS"; desc = "ASCII art reference" },
        @{ num = 17; name = "TUNEUP"; desc = "Optimization guide" },
        @{ num = 18; name = "AGENT-BEST-PRACTICES"; desc = "Agent guidelines" },
        @{ num = 19; name = "AGENTS-WINDOW"; desc = "Agents window setup" }
    )

    $docs | ForEach-Object {
        $prefix = "  $($_.num)".PadRight(5)
        $label = "[$($_.desc)]".PadRight(42)
        Write-Host "$prefix $label  " -NoNewline
        Write-Host "$($_.name).md" -ForegroundColor DarkGray
    }

    Write-Host ""
    Write-Host "  Open with:  vscode docs             (opens in VS Code)" -ForegroundColor Green
    Write-Host "  List only:  vscode docs --list      (this view)" -ForegroundColor Green
    return
}

# Open the portal in VS Code
$indexPath = Join-Path $TemplatesRoot "docs\INDEX.md"
if (Test-Path $indexPath) {
    Write-Host "Opening: $indexPath" -ForegroundColor Green
    code $indexPath
} else {
    Write-Host "File not found: $indexPath" -ForegroundColor Red
}
