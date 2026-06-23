# Module: Invoke-About
# Dot-sourced by WorkspaceManager.ps1

function Invoke-About {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host "  ℹ️  VS Code Workspace Manager v1.1.0" -ForegroundColor White -NoNewline
    Write-Host "               ║" -ForegroundColor Cyan
    Write-Host "╠══════════════════════════════════════════════════╣" -ForegroundColor Cyan
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host "  License: MIT  │  PowerShell 7+  │  Windows/Linux/macOS" -ForegroundColor DarkGray -NoNewline
    Write-Host " ║" -ForegroundColor Cyan
    Write-Host "╠══════════════════════════════════════════════════╣" -ForegroundColor Cyan

    $templateCount = (Get-ChildItem -Path $TemplatesDir -Filter "*.code-workspace" -ErrorAction SilentlyContinue).Count
    $profileCount = (Get-ChildItem -Path $ProfilesDir -Filter "*.json" -ErrorAction SilentlyContinue).Count
    $docCount = (Get-ChildItem -Path (Join-Path $TemplatesRoot "docs") -Filter "*.md" -ErrorAction SilentlyContinue).Count
    $scriptCount = (Get-ChildItem -Path (Join-Path $TemplatesRoot "scripts") -Filter "*.ps1" -ErrorAction SilentlyContinue).Count

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("  📁 {0} templates  │  📋 {1} profiles  │  📖 {2} docs  │  ⚡ {3} scripts" -f $templateCount, $profileCount, $docCount, $scriptCount) -ForegroundColor White -NoNewline
    Write-Host " ║" -ForegroundColor Cyan
    Write-Host "╠══════════════════════════════════════════════════╣" -ForegroundColor Cyan

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host "  Menu options    : 15 (workspace, profile, security, tools)" -ForegroundColor DarkGray -NoNewline
    Write-Host "    ║" -ForegroundColor Cyan
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host "  Terminal        : 6 profiles, 7 tasks, shell integration" -ForegroundColor DarkGray -NoNewline
    Write-Host " ║" -ForegroundColor Cyan
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host "  Convenience     : Makefile, npm scripts, standalone runners" -ForegroundColor DarkGray -NoNewline
    Write-Host " ║" -ForegroundColor Cyan
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host "  Security        : BYOK, pre-commit, CI scan, dependabot" -ForegroundColor DarkGray -NoNewline
    Write-Host "  ║" -ForegroundColor Cyan
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host "  Skills          : deepseek-byok, deepseek-reasonix, workspace-manager" -ForegroundColor DarkGray -NoNewline
    Write-Host "  ║" -ForegroundColor Cyan

    Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Quick commands:" -ForegroundColor White
    Write-Host "    pwsh -File scripts\\Run-Tests.ps1" -ForegroundColor DarkGray
    Write-Host "    make test   │   npm run test" -ForegroundColor DarkGray
    Write-Host "    make update │   npm run update" -ForegroundColor DarkGray
    Write-Host ""
    Pause
}
