<#
.SYNOPSIS
    Full updater — updates self, docs, gists, and skills in one command.
.DESCRIPTION
    Runs: self-update → repair → docs-gen → update-gists → compile.
    Single command to bring everything up to date. Exits 0 if all pass.
.PARAMETER DryRun
    Show what would be done without making changes.
.EXAMPLE
    pwsh -NoProfile -File scripts\Full-Update.ps1
    pwsh -NoProfile -File scripts\Full-Update.ps1 -DryRun
#>

[CmdletBinding()]

param([switch]$DryRun)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$start = Get-Date
$failed = 0

Write-Host ""
Write-Host "╭──────────────────────────────────────╮" -ForegroundColor Cyan
Write-Host "│  🔄  Full System Update              │" -ForegroundColor Cyan
Write-Host "╰──────────────────────────────────────╯" -ForegroundColor Cyan

# 1. Self-update
Write-Host "  ── 1/5 : Self-Update ──────────────────────────" -ForegroundColor DarkGray
if ($DryRun) {
    Write-Host "  [DRY-RUN] Would pull latest from git remote" -ForegroundColor Yellow
} else {
    & pwsh -NoProfile -File (Join-Path $PSScriptRoot "Update-Self.ps1") -Force -SkipTests
    if ($LASTEXITCODE -ne 0) { $failed++ }
}

# 2. Repair
Write-Host "  ── 2/5 : Self-Repair ──────────────────────────" -ForegroundColor DarkGray
if ($DryRun) {
    Write-Host "  [DRY-RUN] Would fix line endings, JSON, dirs, hooks" -ForegroundColor Yellow
} else {
    & pwsh -NoProfile -File (Join-Path $PSScriptRoot "Repair-Project.ps1") -Force
    if ($LASTEXITCODE -ne 0) { $failed++ }
}

# 3. Docs
Write-Host "  ── 3/5 : Generate Docs ────────────────────────" -ForegroundColor DarkGray
if ($DryRun) {
    Write-Host "  [DRY-RUN] Would update PROJECT-STATS.md, README.md" -ForegroundColor Yellow
} else {
    & pwsh -NoProfile -File (Join-Path $PSScriptRoot "Generate-Docs.ps1")
    if ($LASTEXITCODE -ne 0) { $failed++ }
}

# 4. Gists
Write-Host "  ── 4/5 : Update Gists ─────────────────────────" -ForegroundColor DarkGray
if ($DryRun) {
    Write-Host "  [DRY-RUN] Would update prompts with live stats" -ForegroundColor Yellow
} else {
    & pwsh -NoProfile -File (Join-Path $PSScriptRoot "Update-Gists.ps1")
    if ($LASTEXITCODE -ne 0) { $failed++ }
}

# 5. Final validation
Write-Host "  ── 5/5 : Final Validation ─────────────────────" -ForegroundColor DarkGray
if ($DryRun) {
    Write-Host "  [DRY-RUN] Would run Full-Check.ps1" -ForegroundColor Yellow
} else {
    & pwsh -NoProfile -File (Join-Path $PSScriptRoot "Full-Check.ps1")
    if ($LASTEXITCODE -ne 0) { $failed++ }
}

$elapsed = [math]::Round(((Get-Date)-$start).TotalSeconds,1)
Write-Host ""
Write-Host "  ── Result ────────────────────────────────────" -ForegroundColor DarkGray
if ($failed -eq 0) { Write-Host "  ✅  FULL UPDATE COMPLETE  (${elapsed}s)" -ForegroundColor Green }
else { Write-Host "  ❌  $failed STEP(S) FAILED  (${elapsed}s)" -ForegroundColor Red }
Write-Host ""

exit $failed
