<#
.SYNOPSIS
    Launch the workspace manager with Reasonix context pre-loaded.
.DESCRIPTION
    Sets up environment variables, loads agent memories, opens the project
    in Reasonix-ready state. Run before starting an AI session.
.EXAMPLE
    pwsh -NoProfile -File scripts\Launch-Reasonix.ps1
#>

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\Helper-Functions.ps1"
$root = Get-TemplatesRoot

Write-Banner "VS Code Workspace Manager — Reasonix Launch" "🤖"

# Load context
Write-Section "Context Loaded"
Write-Pass "AGENTS.md" "project conventions"
Write-Pass "prompts/agent-flows.md" "8 decision trees"
Write-Pass "prompts/agent-memories.md" "key facts"
Write-Pass "prompts/agent-research.md" "8 investigation paths"
Write-Pass ".github/copilot-instructions.md" "auto-loaded"

# Set environment
$env:TEMPLATES_ROOT = $root
Write-Pass "TEMPLATES_ROOT" $root

# Show quick commands
Write-Section "Quick Commands"
Write-Host "  make test      → live checks" -ForegroundColor DarkGray
Write-Host "  make manager   → 15-option modern menu" -ForegroundColor DarkGray
Write-Host "  make all       → Full pipeline" -ForegroundColor DarkGray
Write-Host "  make update    → Self-update" -ForegroundColor DarkGray

# Stats
Write-Section "Project Snapshot"
Write-Host ("  Scripts: {0}  ·  Docs: {1}  ·  Templates: {2}  ·  Profiles: {3}" -f (Get-ScriptCount), (Get-DocCount), (Get-TemplateCount), (Get-ProfileCount)) -ForegroundColor Cyan

Write-Host ("  Tests: {0}  ·  Version: v{1}" -f (Get-TestCount), (Get-CurrentVersion)) -ForegroundColor Cyan

Write-Result $true "Ready for Reasonix session"
