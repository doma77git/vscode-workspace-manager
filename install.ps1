<#
.SYNOPSIS
    One-line installer — bootstrap the VS Code Workspace Manager from scratch.
.DESCRIPTION
    Clones the repo (or initializes locally), runs setup, installs hooks,
    validates, and launches the menu. Works on Windows, Linux, and macOS.
.PARAMETER RepoUrl
    Git remote URL to clone. Default: https://github.com/doma77git/vscode-workspace-manager.git
.PARAMETER InstallPath
    Where to install. Default: C:\VSCode\Templates (Windows) or ~/vscode/Templates (Linux/macOS)
.PARAMETER NoMenu
    Skip launching the menu after install.
.PARAMETER DryRun
    Show what would be done without making changes.
.EXAMPLE
    # One-line install from GitHub:
    irm https://raw.githubusercontent.com/doma77git/vscode-workspace-manager/main/install.ps1 | iex

.EXAMPLE
    pwsh -NoProfile -File install.ps1
    # Clones, initializes, validates, launches menu

.EXAMPLE
    pwsh -NoProfile -File install.ps1 -InstallPath D:\Dev\Templates -NoMenu
    # Custom path, skip menu launch
#>

param(
    [string]$RepoUrl = "https://github.com/doma77git/vscode-workspace-manager.git",
    [string]$InstallPath = "",
    [switch]$NoMenu,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$startTime = Get-Date

# ── Platform detection ─────────────────────────
if (-not $InstallPath) {
    if ($IsWindows -or (-not (Test-Path variable:IsWindows))) {
        $InstallPath = "C:\VSCode\Templates"
    } else {
        $InstallPath = "$env:HOME/vscode/Templates"
    }
}

if ($DryRun) {
    Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  🔧  VS Code Workspace Manager — Installer       ║" -ForegroundColor Cyan
    Write-Host "╠══════════════════════════════════════════════════╣" -ForegroundColor Cyan
    Write-Host "║  [DRY-RUN] Would:                               ║" -ForegroundColor Yellow
    Write-Host "║  1. Clone $RepoUrl" -ForegroundColor DarkGray
    Write-Host "║     → $InstallPath" -ForegroundColor DarkGray
    Write-Host "║  2. Run Init-TemplatesRepo.ps1" -ForegroundColor DarkGray
    Write-Host "║  3. Run Run-All.ps1 -Quick" -ForegroundColor DarkGray
    Write-Host "║  4. Launch WorkspaceManager.ps1" -ForegroundColor DarkGray
    Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan
    exit 0
}

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host "  🔧  VS Code Workspace Manager — Installer" -ForegroundColor White -NoNewline
Write-Host "       ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ── Step 1: Prerequisites ──────────────────────
Write-Host "  ── Step 1/4 : Prerequisites ────────────────────" -ForegroundColor DarkGray

# Check PowerShell
$psOk = $PSVersionTable.PSVersion.Major -ge 7
Write-Host ("  {0} PowerShell {1}" -f $(if ($psOk) { "✅" } else { "❌" }), $PSVersionTable.PSVersion) -ForegroundColor $(if ($psOk) { "Green" } else { "Red" })
if (-not $psOk) {
    Write-Host "  Install PowerShell 7+: https://github.com/PowerShell/PowerShell" -ForegroundColor Yellow
    exit 1
}

# Check Git
$gitOk = $null -ne (Get-Command git -ErrorAction SilentlyContinue)
Write-Host ("  {0} Git {1}" -f $(if ($gitOk) { "✅" } else { "⚠️ " }), $(if ($gitOk) { (& git --version) -replace 'git version ', '' } else { "not found" })) -ForegroundColor $(if ($gitOk) { "Green" } else { "Yellow" })

Write-Host ""

# ── Step 2: Clone ──────────────────────────────
Write-Host "  ── Step 2/4 : Clone ────────────────────────────" -ForegroundColor DarkGray

if (Test-Path $InstallPath) {
    Write-Host "  ⚠️  $InstallPath already exists." -ForegroundColor Yellow
    Write-Host "  To reinstall, remove it first: Remove-Item -Recurse -Force '$InstallPath'" -ForegroundColor Yellow
    $choice = Read-Host "  Continue in existing directory? (y/n)"
    if ($choice -ne 'y') { exit 0 }
} else {
    if ($gitOk) {
        Write-Host "  Cloning $RepoUrl ..." -ForegroundColor DarkGray
        & git clone $RepoUrl $InstallPath 2>&1 | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  ❌ Clone failed. Check the URL or your network." -ForegroundColor Red
            exit 1
        }
        Write-Host "  ✅ Cloned to $InstallPath" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Git not found — creating directory structure manually." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
        Write-Host "  Download the repo from: $RepoUrl" -ForegroundColor Yellow
    }
}

Write-Host ""
Push-Location $InstallPath

# ── Step 3: Initialize ─────────────────────────
Write-Host "  ── Step 3/4 : Initialize ───────────────────────" -ForegroundColor DarkGray

$initScript = Join-Path $InstallPath "scripts\Init-TemplatesRepo.ps1"
if (Test-Path $initScript) {
    & pwsh -NoProfile -ExecutionPolicy Bypass -File $initScript
    Write-Host "  ✅ Repo initialized" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Init script not found — skipping." -ForegroundColor Yellow
}

Write-Host ""

# ── Step 4: Validate ───────────────────────────
Write-Host "  ── Step 4/4 : Validate ─────────────────────────" -ForegroundColor DarkGray

$allScript = Join-Path $InstallPath "scripts\Run-All.ps1"
if (Test-Path $allScript) {
    & pwsh -NoProfile -File $allScript -Quick
} else {
    Write-Host "  ⚠️  Run-All.ps1 not found — skipping validation." -ForegroundColor Yellow
}

# ── Done ───────────────────────────────────────
$elapsed = (Get-Date) - $startTime
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host "  ✅  Installation complete!  $($elapsed.TotalSeconds.ToString('0.0'))s" -ForegroundColor Green -NoNewline
Write-Host "               ║" -ForegroundColor Cyan
Write-Host "╠══════════════════════════════════════════════════╣" -ForegroundColor Cyan
Write-Host "║  Location : $InstallPath" -ForegroundColor DarkGray
$pad = 49 - $InstallPath.Length
if ($pad -gt 0) { Write-Host ("║" + " " * $pad) -ForegroundColor Cyan -NoNewline }
Write-Host "║  Launch   : make manager" -ForegroundColor DarkGray
Write-Host "║  Update   : make update" -ForegroundColor DarkGray
Write-Host "║  Docs     : docs/INDEX.md" -ForegroundColor DarkGray
Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ── Launch menu ────────────────────────────────
if (-not $NoMenu) {
    $menuScript = Join-Path $InstallPath "scripts\WorkspaceManager.ps1"
    if (Test-Path $menuScript) {
        & pwsh -NoProfile -ExecutionPolicy Bypass -File $menuScript
    }
}

Pop-Location
exit 0
