<#
.SYNOPSIS
    Full maintenance routine — test, repair, update, backup, clean.
.DESCRIPTION
    Runs the complete maintenance pipeline in order:
    test → repair → backup → docs-gen → update-gists → clean.
    Exits 0 if all pass, 1 if any fail.
.PARAMETER Quick
    Skip backup and update (faster).
.EXAMPLE
    pwsh -NoProfile -File scripts\Maintain-Project.ps1
    pwsh -NoProfile -File scripts\Maintain-Project.ps1 -Quick
#>

param([switch]$Quick)

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\Helper-Functions.ps1"
$root = Get-TemplatesRoot
$start = Get-Date
$failed = 0

Write-Banner "VS Code Workspace Manager — Maintenance" "🔧"

# 1. Test
Write-Host "  ── 1/5 : Test Suite ──────────────────────────" -ForegroundColor DarkGray
& pwsh -NoProfile -File (Join-Path $PSScriptRoot "Run-All.ps1") -Quick
if ($LASTEXITCODE -ne 0) { $failed++ }

# 2. Repair
Write-Host "  ── 2/5 : Self-Repair ──────────────────────────" -ForegroundColor DarkGray
& pwsh -NoProfile -File (Join-Path $PSScriptRoot "Repair-Project.ps1") -Force
if ($LASTEXITCODE -ne 0) { $failed++ }

if (-not $Quick) {
    # 3. Backup
    Write-Host "  ── 3/5 : Backup ───────────────────────────────" -ForegroundColor DarkGray
    & pwsh -NoProfile -File (Join-Path $PSScriptRoot "Auto-Backup.ps1")
    if ($LASTEXITCODE -ne 0) { $failed++ }

    # 4. Update docs
    Write-Host "  ── 4/5 : Update Docs ──────────────────────────" -ForegroundColor DarkGray
    & pwsh -NoProfile -File (Join-Path $PSScriptRoot "Generate-Docs.ps1")
    & pwsh -NoProfile -File (Join-Path $PSScriptRoot "Update-Gists.ps1")
}

# 5. Clean old backups
Write-Host "  ── 5/5 : Clean Old Backups ────────────────────" -ForegroundColor DarkGray
$exports = Join-Path $root "exports"
if (Test-Path $exports) {
    $old = Get-ChildItem $exports -Filter "backup-*.zip" -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -Skip 5
    if ($old) {
        $old | Remove-Item -Force
        Write-Pass "Cleaned" "$($old.Count) old backup(s)"
    } else { Write-Host "  ✅  Backups clean" -ForegroundColor DarkGray }
}

# Summary
$elapsed = (Get-Date) - $start
Write-Host ""
Write-Result ($failed -eq 0) "Maintenance complete ($($elapsed.TotalSeconds.ToString('0.0'))s)"
exit $failed
