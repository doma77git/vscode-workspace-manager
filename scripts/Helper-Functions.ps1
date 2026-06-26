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
    # Platform-aware fallback
    if (Test-Path variable:IsWindows) {
        if ($IsWindows)  { return "C:\VSCode\Templates" }
        if ($IsLinux)    { return "$env:HOME/vscode/Templates" }
        if ($IsMacOS)    { return "$env:HOME/vscode/Templates" }
    }
    # PowerShell 5 on Windows (no $IsWindows variable)
    if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
        return "C:\VSCode\Templates"
    }
    # Last resort: derive from script location
    return Split-Path -Parent $PSScriptRoot
}

# ── Display Helpers ───────────────────────────────

function Write-Banner($title, $emoji) {
    <# Print a box-drawn banner with title and emoji. Adjusts box width to fit the title. #>
    $innerWidth = 50
    $text = "  $emoji  $title"
    if ($text.Length -gt $innerWidth - 4) { $innerWidth = $text.Length + 6 }
    $top    = "╔" + ("═" * ($innerWidth - 2)) + "╗"
    $bottom = "╚" + ("═" * ($innerWidth - 2)) + "╝"
    Write-Host ""
    Write-Host $top -ForegroundColor Cyan
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host $text -ForegroundColor White -NoNewline
    $padding = $innerWidth - $text.Length - 2
    if ($padding -gt 0) { Write-Host (" " * $padding) -NoNewline }
    Write-Host "║" -ForegroundColor Cyan
    Write-Host $bottom -ForegroundColor Cyan
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

function Validate-JsonFile {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        Write-Host "[ERROR] File not found: $Path" -ForegroundColor Red
        return $false
    }
    try {
        $null = Get-Content $Path -Raw -Encoding UTF8 | ConvertFrom-Json
        Write-Host "[OK] Valid JSON: $Path" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "[ERROR] Invalid JSON in $Path : $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
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

function Get-TestCount {
    $root = Get-TemplatesRoot
    $ps1 = (Get-ChildItem -Path (Join-Path $root "scripts") -Recurse -Filter "*.ps1" -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\.git\\' }).Count
    $json = (Get-ChildItem $root -Recurse -Include @("*.json", "*.code-workspace") -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\.git\\' }).Count
    $yaml = (Get-ChildItem $root -Recurse -Include @("*.yml", "*.yaml") -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\.git\\' }).Count
    return $ps1 + $json + $yaml + 2
}

# ── Export ────────────────────────────────────────

Write-Verbose "Helper-Functions.ps1 loaded" -Verbose:$false
