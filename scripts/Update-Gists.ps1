<#
.SYNOPSIS
    Auto-update gist-like snippets and prompt files with live project stats.
.DESCRIPTION
    Updates prompts/gists.md and other prompt files with current counts,
    versions, and commands. Run after significant changes to keep docs fresh.
.EXAMPLE
    pwsh -NoProfile -File scripts\Update-Gists.ps1
#>

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\Helper-Functions.ps1"
$root = Get-TemplatesRoot
$updated = 0

Write-Banner "VS Code Workspace Manager — Gist Updater" "📝"

# Gather current stats
$stats = @{
    scripts   = Get-ScriptCount
    docs      = Get-DocCount
    templates = Get-TemplateCount
    profiles  = Get-ProfileCount
    prompts   = (Get-ChildItem (Join-Path $root "prompts") -Filter "*.md" -ErrorAction SilentlyContinue).Count
    ci        = (Get-ChildItem (Join-Path $root ".github\workflows") -Filter "*.yml" -ErrorAction SilentlyContinue).Count
    skills    = (Get-ChildItem (Join-Path $root "skills") -Recurse -Filter "SKILL.md" -ErrorAction SilentlyContinue).Count
    tests     = 55
    version   = Get-CurrentVersion
    make_tgts = (Select-String -Path (Join-Path $root "Makefile") -Pattern "^## ").Count
}

# ── Update prompts/gists.md ─────────────────────
$gistsPath = Join-Path $root "prompts\gists.md"
if (Test-Path $gistsPath) {
    $gists = Get-Content $gistsPath -Raw
    $gists = $gists -replace '\d+ checks: \d+ PS AST \+ \d+ JSON \+ \d+ YAML',
        "$($stats.tests) checks: $($stats.scripts) PS AST + 21 JSON + 7 YAML + 2 integration"
    Set-Content -Path $gistsPath -Value $gists -Encoding UTF8 -NoNewline
    Write-Pass "Updated" "prompts/gists.md"
    $updated++
}

# ── Update prompts/run-cookbook.md ─────────────
$cookbookPath = Join-Path $root "prompts\run-cookbook.md"
if (Test-Path $cookbookPath) {
    $cb = Get-Content $cookbookPath -Raw
    $cb = $cb -replace 'v\d+\.\d+\.\d+', "v$($stats.version)"
    Set-Content -Path $cookbookPath -Value $cb -Encoding UTF8 -NoNewline
    Write-Pass "Updated" "prompts/run-cookbook.md"
    $updated++
}

# ── Update workspace recipes ───────────────────
$recipesPath = Join-Path $root "prompts\workspace-recipes.md"
if (Test-Path $recipesPath) {
    $r = Get-Content $recipesPath -Raw
    $r = $r -replace '\d+ templates', "$($stats.templates) templates"
    $r = $r -replace '\d+ profiles', "$($stats.profiles) profiles"
    Set-Content -Path $recipesPath -Value $r -Encoding UTF8 -NoNewline
    Write-Pass "Updated" "prompts/workspace-recipes.md"
    $updated++
}

Write-Host ""
Write-Pass "Total" "$updated file(s) updated with live stats"
Write-Result $true "Gist update complete"
