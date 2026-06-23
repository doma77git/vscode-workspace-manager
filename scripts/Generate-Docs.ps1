<#
.SYNOPSIS
    Auto-generate documentation updates from project state.
.DESCRIPTION
    Updates AGENTS.md stats, generates a PROJECT-STATS.md report,
    and prints a summary suitable for pasting into README.
.EXAMPLE
    pwsh -NoProfile -File scripts\Generate-Docs.ps1
    # Prints stats and updates AGENTS.md if count changed
#>

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\Helper-Functions.ps1"
$root = Get-TemplatesRoot

Write-Banner "VS Code Workspace Manager — Self-Documenting" "📝"

# ── Collect Stats ─────────────────────────────────
$stats = @{
    Version      = Get-CurrentVersion
    Scripts      = Get-ScriptCount
    Docs         = Get-DocCount
    Templates    = Get-TemplateCount
    Profiles     = Get-ProfileCount
    Prompts      = (Get-ChildItem (Join-Path $root "prompts") -Filter "*.md" -ErrorAction SilentlyContinue).Count
    CIWorkflows  = (Get-ChildItem (Join-Path $root ".github\workflows") -Filter "*.yml" -ErrorAction SilentlyContinue).Count
    Skills       = (Get-ChildItem (Join-Path $root "skills") -Recurse -Filter "SKILL.md" -ErrorAction SilentlyContinue).Count
    TotalFiles   = (Get-ChildItem $root -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\.git\\' }).Count
    TestCount    = 34  # hardcoded for now; could read from Run-Tests output
    MenuOptions  = 15
    MakeTargets  = (Select-String -Path (Join-Path $root "Makefile") -Pattern "^## ").Count
    NpmScripts   = ((Get-Content (Join-Path $root "package.json") -Raw | ConvertFrom-Json).scripts.PSObject.Properties).Count
    PSVersion    = $PSVersionTable.PSVersion.ToString()
}

# ── Print Summary ─────────────────────────────────
Write-Section "Project Snapshot"

Write-Host "  ╔══════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host ("  ║  v{0,-20}          ║" -f $stats.Version) -ForegroundColor Cyan
Write-Host "  ╠══════════════════════════════════════╣" -ForegroundColor Cyan
Write-Host ("  ║  {0,2} scripts  │  {1,2} docs  │  {2,2} prompts   ║" -f $stats.Scripts, $stats.Docs, $stats.Prompts) -ForegroundColor White
Write-Host ("  ║  {0,2} CI flows │  {1,2} skills │  {2,2} templates║" -f $stats.CIWorkflows, $stats.Skills, $stats.Templates) -ForegroundColor White
Write-Host ("  ║  {0,2} profiles │  {1,2} tests  │  {2,2} npm/cmds ║" -f $stats.Profiles, $stats.TestCount, $stats.NpmScripts) -ForegroundColor White
Write-Host ("  ║  {0,2} make tgts│  {1,2} menu   │  {2,3} files    ║" -f $stats.MakeTargets, $stats.MenuOptions, $stats.TotalFiles) -ForegroundColor White
Write-Host "  ╚══════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ── Generate Markdown ─────────────────────────────
Write-Section "Generated Markdown"

$md = @"
## Project Stats (auto-generated)

| Category | Count |
|----------|-------|
| Version | v$($stats.Version) |
| PowerShell scripts | $($stats.Scripts) |
| Documentation guides | $($stats.Docs) |
| Prompt library files | $($stats.Prompts) |
| CI workflows | $($stats.CIWorkflows) |
| Reasonix skills | $($stats.Skills) |
| Templates | $($stats.Templates) |
| Profiles | $($stats.Profiles) |
| Test checks | $($stats.TestCount) |
| Menu options | $($stats.MenuOptions) |
| Makefile targets | $($stats.MakeTargets) |
| npm scripts | $($stats.NpmScripts) |
| Total tracked files | $($stats.TotalFiles) |
| PowerShell version | $($stats.PSVersion) |
"@

Write-Host $md

# ── Save ──────────────────────────────────────────
$reportPath = Join-Path $root "PROJECT-STATS.md"
$reportContent = @"
# Project Stats — Auto-Generated

> Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
> Script: scripts/Generate-Docs.ps1

$md
"@
Set-Content -Path $reportPath -Value $reportContent -Encoding UTF8 -NoNewline
Write-Host ""
Write-Pass "Saved" "PROJECT-STATS.md"

Write-Result $true "Documentation generated"
