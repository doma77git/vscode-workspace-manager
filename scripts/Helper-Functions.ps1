<#
.SYNOPSIS
    Shared helper functions sourced by all workspace manager scripts.
.DESCRIPTION
    Dot-source this file in other scripts to reuse common functions:
        . "$PSScriptRoot\Helper-Functions.ps1"
#>

# ── Path Helpers ──────────────────────────────────

function Get-TemplatesRoot {
    <# Returns the project root path. Respects TEMPLATES_ROOT env var. #>
    if (Test-Path env:TEMPLATES_ROOT) {
        return $env:TEMPLATES_ROOT
    }
    if ($IsWindows -or (-not (Test-Path variable:IsWindows))) {
        return "C:\VSCode\Templates"
    } elseif ($IsLinux) {
        return "$env:HOME/vscode/Templates"
    } elseif ($IsMacOS) {
        return "$env:HOME/vscode/Templates"
    }
    return Split-Path -Parent $PSScriptRoot
}

# ── Display Helpers ───────────────────────────────

function Write-Banner($title, $emoji) {
    <# Print a box-drawn banner with title and emoji. #>
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    $text = "  $emoji  $title"
    Write-Host $text -ForegroundColor White -NoNewline
    $padding = 46 - $text.Length
    if ($padding -gt 0) { Write-Host (" " * $padding) -NoNewline }
    Write-Host "║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Section($text) {
    <# Print a section divider. #>
    Write-Host ""
    Write-Host "  ── $text " -NoNewline -ForegroundColor DarkGray
    Write-Host ("─" * (50 - $text.Length)) -ForegroundColor DarkGray
}

function Write-Pass($label, $detail = "") {
    <# Print a green pass line with aligned label. #>
    Write-Host ("  ✅  {0,-35} {1}" -f $label, $detail) -ForegroundColor Green
}

function Write-Fail($label, $detail = "") {
    <# Print a red fail line with aligned label. #>
    Write-Host ("  ❌  {0,-35} {1}" -f $label, $detail) -ForegroundColor Red
}

function Write-Warn($label, $detail = "") {
    <# Print a yellow warning line. #>
    Write-Host ("  ⚠️   {0,-35} {1}" -f $label, $detail) -ForegroundColor Yellow
}

function Write-Result($pass, $text) {
    <# Print a green/red result bar. #>
    Write-Host ""
    Write-Host "  ── Result ────────────────────────────────────" -ForegroundColor DarkGray
    if ($pass) {
        Write-Host "  ✅  $text" -ForegroundColor Green
    } else {
        Write-Host "  ❌  $text" -ForegroundColor Red
    }
    Write-Host ""
}

# ── Validation Helpers ────────────────────────────

function Test-JsonFile($path) {
    <# Returns $true if the file is valid JSON, $false otherwise. #>
    try {
        $null = Get-Content $path -Raw -Encoding UTF8 | ConvertFrom-Json
        return $true
    } catch {
        return $false
    }
}

function Test-PowerShellFile($path) {
    <# Returns $true if the .ps1 file parses without errors. #>
    $content = Get-Content $path -Raw -ErrorAction SilentlyContinue
    $errors = $null
    $null = [System.Management.Automation.Language.Parser]::ParseInput($content, [ref]$null, [ref]$errors)
    return ($errors.Count -eq 0)
}

# ── Git Helpers ───────────────────────────────────

function Get-GitRemote {
    <# Returns the origin remote URL, or $null. #>
    return & git remote get-url origin 2>$null
}

function Get-CurrentVersion {
    <# Extracts version from CHANGELOG.md. #>
    $root = Get-TemplatesRoot
    $changelogPath = Join-Path $root "CHANGELOG.md"
    if (Test-Path $changelogPath) {
        $cl = Get-Content $changelogPath -Raw
        if ($cl -match '## \[(\d+\.\d+\.\d+)\]') {
            return $matches[1]
        }
    }
    return "unknown"
}

# ── Count Helpers ─────────────────────────────────

function Get-TemplateCount {
    $root = Get-TemplatesRoot
    return (Get-ChildItem -Path (Join-Path $root "templates") -Filter "*.code-workspace" -ErrorAction SilentlyContinue).Count
}

function Get-ProfileCount {
    $root = Get-TemplatesRoot
    return (Get-ChildItem -Path (Join-Path $root "profiles") -Filter "*.json" -ErrorAction SilentlyContinue).Count
}

function Get-DocCount {
    $root = Get-TemplatesRoot
    return (Get-ChildItem -Path (Join-Path $root "docs") -Filter "*.md" -ErrorAction SilentlyContinue).Count
}

function Get-ScriptCount {
    $root = Get-TemplatesRoot
    return (Get-ChildItem -Path (Join-Path $root "scripts") -Filter "*.ps1" -ErrorAction SilentlyContinue).Count
}

# ── Export ────────────────────────────────────────

Write-Verbose "Helper-Functions.ps1 loaded" -Verbose:$false
