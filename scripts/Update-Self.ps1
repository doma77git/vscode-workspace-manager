<#
.SYNOPSIS
    Self-update the VS Code Workspace Manager from its git remote.
.DESCRIPTION
    Performs a safe self-update: checks prerequisites, stashes local changes,
    pulls latest from origin, runs validation, and restores stashed changes.
    Exits 0 on success, 1 on failure.
.PARAMETER DryRun
    Show what would be done without making changes.
.PARAMETER Force
    Skip confirmation prompt.
.PARAMETER SkipTests
    Skip post-update validation tests.
.EXAMPLE
    pwsh -NoProfile -File scripts\Update-Self.ps1
    # Interactive self-update with confirmation.

.EXAMPLE
    pwsh -NoProfile -File scripts\Update-Self.ps1 -Force -SkipTests
    # Silent update, no confirmation, skip tests.
#>

param(
    [switch]$DryRun,
    [switch]$Force,
    [switch]$SkipTests
)

$ErrorActionPreference = "Stop"
$TemplatesRoot = Split-Path -Parent $PSScriptRoot

Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host "  🔄  VS Code Workspace Manager — Self-Update" -ForegroundColor White -NoNewline
Write-Host "    ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Prerequisites check
Push-Location $TemplatesRoot
try {
    # Must be a git repo
    if (-not (Test-Path ".git")) {
        Write-Host "[ERROR] Not a git repository. Self-update requires git." -ForegroundColor Red
        Write-Host "  ↳ Clone the repo with: git clone <url> C:\VSCode\Templates" -ForegroundColor Yellow
        exit 1
    }

    # Check clean state
    $status = & git status --porcelain 2>$null
    $hasChanges = $status -and $status.Trim().Length -gt 0

    # Check current version
    $currentVersion = "unknown"
    if (Test-Path "CHANGELOG.md") {
        $changelog = Get-Content "CHANGELOG.md" -Raw
        if ($changelog -match '## \[(\d+\.\d+\.\d+)\]') {
            $currentVersion = $matches[1]
        }
    }

    # Get remote
    $remote = & git remote get-url origin 2>$null
    if (-not $remote) {
        Write-Host "[ERROR] No git remote 'origin' configured." -ForegroundColor Red
        exit 1
    }

    Write-Host "Current version : v$currentVersion" -ForegroundColor Green
    Write-Host "Remote          : $remote" -ForegroundColor DarkGray
    Write-Host ""

    if ($DryRun) {
        Write-Host "[DRY-RUN] Would fetch from origin and merge." -ForegroundColor Yellow
        exit 0
    }

    # Confirmation
    if (-not $Force) {
        $confirm = Read-Host "Proceed with self-update? (y/n)"
        if ($confirm -ne 'y') {
            Write-Host "Update cancelled." -ForegroundColor Yellow
            exit 0
        }
    }

    # Report local changes
    if ($hasChanges) {
        Write-Host "[INFO] Local changes detected — will stash and restore." -ForegroundColor Yellow
        Write-Host ""
        & git status --short
        Write-Host ""
    }

    # Stash if dirty
    $stashed = $false
    if ($hasChanges) {
        Write-Host "Stashing local changes..." -ForegroundColor DarkGray
        & git stash push -m "auto-stash: self-update $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" 2>$null
        $stashed = $true
    }

    # Fetch + merge
    Write-Host "Fetching latest from origin..." -ForegroundColor DarkGray
    & git fetch origin 2>$null

    $branch = & git rev-parse --abbrev-ref HEAD 2>$null
    Write-Host "Updating branch: $branch" -ForegroundColor DarkGray

    $mergeResult = & git merge "origin/$branch" 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Merge failed. Your local branch may have conflicts." -ForegroundColor Red
        Write-Host "$mergeResult" -ForegroundColor Red

        if ($stashed) {
            Write-Host "Restoring stashed changes..." -ForegroundColor Yellow
            & git stash pop 2>$null
        }
        exit 1
    }

    Write-Host "[OK] Repository updated." -ForegroundColor Green

    # Restore stash
    if ($stashed) {
        Write-Host "Restoring stashed changes..." -ForegroundColor DarkGray
        & git stash pop 2>$null
    }

    # Show new version
    if (Test-Path "CHANGELOG.md") {
        $changelog = Get-Content "CHANGELOG.md" -Raw
        if ($changelog -match '## \[(\d+\.\d+\.\d+)\]') {
            $newVersion = $matches[1]
            Write-Host "New version     : v$newVersion" -ForegroundColor Green
        }
    }

    # Run validation
    if (-not $SkipTests) {
        Write-Host ""
        Write-Host "Running post-update validation..." -ForegroundColor DarkGray
        $testScript = Join-Path $PSScriptRoot "Run-Tests.ps1"
        if (Test-Path $testScript) {
            & pwsh -NoProfile -File $testScript
            if ($LASTEXITCODE -ne 0) {
                Write-Host ""
                Write-Host "[WARN] Post-update tests failed — review the output above." -ForegroundColor Yellow
            }
        }
    }

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  SELF-UPDATE COMPLETE" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Restart the workspace manager to use the updated version." -ForegroundColor Yellow

} finally {
    Pop-Location
}

exit 0
