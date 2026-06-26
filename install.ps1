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
    Write-Host "║  4. Create launcher stubs at parent directory" -ForegroundColor DarkGray
    Write-Host "║  5. Offer to add PATH" -ForegroundColor DarkGray
    Write-Host "║  6. Launch WorkspaceManager.ps1" -ForegroundColor DarkGray
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
Write-Host "║  Quick    : wsm          (from any directory)" -ForegroundColor DarkGray
Write-Host "║  Docs     : docs/INDEX.md" -ForegroundColor DarkGray
Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ── PATH Setup ─────────────────────────────────
Write-Host "  ── Optional : Add to PATH ─────────────────────" -ForegroundColor DarkGray
Write-Host "  To run 'wsm' from any terminal, add this folder to your PATH:"
Write-Host "    $InstallPath" -ForegroundColor Cyan
Write-Host ""
$addPath = Read-Host "  Add to user PATH now? (y/n)"
if ($addPath -eq 'y') {
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($currentPath -notlike "*$InstallPath*") {
        $newPath = "$InstallPath;$currentPath"
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        Write-Host "  ✅  Added to user PATH. Restart your terminal to use 'wsm' from anywhere." -ForegroundColor Green
        # Also update current session
        $env:PATH = "$InstallPath;$env:PATH"
    } else {
        Write-Host "  ⚠️  Already in PATH — nothing changed." -ForegroundColor Yellow
    }
} else {
    Write-Host "  ℹ️  To add manually later, run:" -ForegroundColor DarkGray
    Write-Host "    [Environment]::SetEnvironmentVariable('PATH', \"`$InstallPath;\" + [Environment]::GetEnvironmentVariable('PATH', 'User'), 'User')" -ForegroundColor DarkGray
}
Write-Host ""

# ── Launcher Stubs at Parent Directory ────────
$parentDir = Split-Path $InstallPath -Parent
if ($parentDir -and (Test-Path $parentDir) -and $parentDir -ne $InstallPath) {
    Write-Host "  ── Optional : Launcher Stubs ──────────────────" -ForegroundColor DarkGray
    Write-Host "  Create 'wsm' launchers at the parent directory so you can"
    Write-Host "  run them from a shorter path, or add the parent to PATH:"
    Write-Host "    $parentDir" -ForegroundColor Cyan
    Write-Host ""
    $createStubs = Read-Host "  Create launcher stubs at $parentDir? (y/n)"
    if ($createStubs -eq 'y') {
        $errors = 0

        # Windows batch stub
        $cmdContent = "@echo off`r`nREM VS Code Workspace Manager — launcher stub`r`nset ""REAL=%~dp0Templates\wsm.cmd""`r`nif not exist ""%REAL%"" (`r`n    echo [ERROR] Launcher not found: %REAL%`r`n    pause`r`n    exit /b 1`r`n)`r`ncall ""%REAL%"" %*`r`n"
        $cmdPath = Join-Path $parentDir "wsm.cmd"
        try {
            $cmdContent | Set-Content -Path $cmdPath -Encoding ASCII -NoNewline
            Write-Host "  ✅  wsm.cmd created" -ForegroundColor Green
        } catch { Write-Host "  ❌  wsm.cmd: $($_.Exception.Message)" -ForegroundColor Red; $errors++ }

        # PowerShell stub
        $psContent = "<#`r`n.SYNOPSIS`r`n    Launch VS Code Workspace Manager from parent directory.`r`n.DESCRIPTION`r`n    Thin stub that delegates to Templates\wsm.ps1.`r`n#>  `$real = Join-Path `$PSScriptRoot ""Templates"" ""wsm.ps1"";`r`nif (Test-Path `$real) { & pwsh -NoProfile -ExecutionPolicy Bypass -File `$real @args; exit `$LASTEXITCODE }`r`nWrite-Host ""[ERROR] Launcher not found: `$real"" -ForegroundColor Red; exit 1`r`n"
        $psPath = Join-Path $parentDir "wsm.ps1"
        try {
            $psContent | Set-Content -Path $psPath -Encoding UTF8 -NoNewline
            Write-Host "  ✅  wsm.ps1 created" -ForegroundColor Green
        } catch { Write-Host "  ❌  wsm.ps1: $($_.Exception.Message)" -ForegroundColor Red; $errors++ }

        # Bash stub (Linux/macOS/WSL)
        $shContent = "#!/usr/bin/env bash`n# VS Code Workspace Manager — launcher stub`nREAL=""`$(dirname ""`$0"")/Templates/wsm.ps1""`nif [ ! -f ""`$REAL"" ]; then`n    echo ""[ERROR] Launcher not found: `$REAL"" >&2`n    exit 1`nfi`npwsh -NoProfile -ExecutionPolicy Bypass -File ""`$REAL"" ""`$@""`nexit `$?`n"
        $shPath = Join-Path $parentDir "wsm.sh"
        try {
            $shContent | Set-Content -Path $shPath -Encoding ASCII -NoNewline
            Write-Host "  ✅  wsm.sh created" -ForegroundColor Green
        } catch { Write-Host "  ❌  wsm.sh: $($_.Exception.Message)" -ForegroundColor Red; $errors++ }

        if ($errors -eq 0) {
            Write-Host "  🎯  Stubs created. Add $parentDir to PATH for 'wsm' from anywhere." -ForegroundColor Green
        }
    } else {
        Write-Host "  ℹ️  Skip. Stubs can be created later from the installer." -ForegroundColor DarkGray
    }
    Write-Host ""
}

# ── Launch menu ────────────────────────────────
if (-not $NoMenu) {
    $menuScript = Join-Path $InstallPath "scripts\WorkspaceManager.ps1"
    if (Test-Path $menuScript) {
        & pwsh -NoProfile -ExecutionPolicy Bypass -File $menuScript
    }
}

Pop-Location
exit 0
