<#
.SYNOPSIS
    Comprehensive environment health check for the workspace manager.
.DESCRIPTION
    Checks all prerequisites, file structure, git status, and optional tools.
    Outputs a pass/fail report with recommendations. Exits 0 on all pass.
.EXAMPLE
    pwsh -NoProfile -File scripts\Check-Environment.ps1
#>

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\Helper-Functions.ps1"

$root = Get-TemplatesRoot
$allOk = $true

Write-Banner "VS Code Workspace Manager — Environment Check" "🔬"

# ── Prerequisites ─────────────────────────────────
Write-Section "Prerequisites"

# PowerShell version
$psv = $PSVersionTable.PSVersion
if ($psv.Major -ge 7) {
    Write-Pass "PowerShell $psv" ">= 7.0"
} else {
    Write-Fail "PowerShell $psv" "need 7.0+ — install from https://github.com/PowerShell/PowerShell"
    $allOk = $false
}

# VS Code CLI
try {
    $codeVer = & code --version 2>&1 | Select-Object -First 1
    if ($LASTEXITCODE -eq 0) {
        Write-Pass "VS Code CLI" "$codeVer"
    } else { throw }
} catch {
    Write-Warn "VS Code CLI" "not in PATH — optional for local dev"
}

# Git
try {
    $gitVer = & git --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Pass "Git" ($gitVer -replace 'git version ', '')
    } else { throw }
} catch {
    Write-Warn "Git" "not found — optional for local dev"
}

# ── Optional Tools ────────────────────────────────
Write-Section "Optional Tools"

# act (CI runner)
try {
    $actVer = & act --version 2>&1
    if ($LASTEXITCODE -eq 0) { Write-Pass "act (CI runner)" "$actVer" }
    else { throw }
} catch { Write-Warn "act" "not installed — optional for CI simulation" }

# jq (JSON processor)
try {
    $jqVer = & jq --version 2>&1
    if ($LASTEXITCODE -eq 0) { Write-Pass "jq" "$jqVer" }
    else { throw }
} catch { Write-Warn "jq" "not installed — optional for JSON validation" }

# make
try {
    $makeVer = & make --version 2>&1 | Select-Object -First 1
    if ($LASTEXITCODE -eq 0) { Write-Pass "make" "$makeVer" }
    else { throw }
} catch { Write-Warn "make" "not installed — optional for convenience" }

# npm / node
try {
    $nodeVer = & node --version 2>&1
    if ($LASTEXITCODE -eq 0) { Write-Pass "Node.js" "$nodeVer" }
    else { throw }
} catch { Write-Warn "Node.js" "not installed — optional for npm scripts" }

# ── Project Structure ─────────────────────────────
Write-Section "Project Structure"

$requiredDirs = @("templates", "profiles", "meta", "scripts", "docs", "prompts", "skills", ".github/workflows")
foreach ($d in $requiredDirs) {
    $path = Join-Path $root $d
    if (Test-Path $path) { Write-Pass "$d/" "present" }
    else { Write-Fail "$d/" "missing — run make install"; $allOk = $false }
}

$requiredFiles = @(".gitignore", "README.md", "LICENSE", "SECURITY.md", "CONTRIBUTING.md", ".editorconfig", "Makefile", "package.json")
foreach ($f in $requiredFiles) {
    $path = Join-Path $root $f
    if (Test-Path $path) { Write-Pass $f "present" }
    else { Write-Fail $f "missing"; $allOk = $false }
}

# ── Git Status ────────────────────────────────────
Write-Section "Git Status"

Push-Location $root
try {
    if (Test-Path ".git") {
        Write-Pass "Git repo" "initialized"

        $remote = Get-GitRemote
        if ($remote) { Write-Pass "Remote" $remote }
        else { Write-Warn "Remote" "no origin configured" }

        $status = & git status --porcelain 2>$null
        if ($status) {
            $changes = ($status -split "`n").Count
            Write-Warn "Changes" "$changes file(s) modified or untracked"
        } else {
            Write-Pass "Working tree" "clean"
        }

        $branch = & git rev-parse --abbrev-ref HEAD 2>$null
        Write-Pass "Branch" $branch

    } else {
        Write-Warn "Git" "not a git repo — run make install"
    }
} finally {
    Pop-Location
}

# ── Validation ────────────────────────────────────
Write-Section "Quick Validation"

Push-Location $root
try {
    $jsonFiles = Get-ChildItem -Recurse -Include @("*.json", "*.code-workspace") -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '\\.git\\' }

    $bad = 0
    foreach ($f in $jsonFiles) {
        if (-not (Test-JsonFile $f.FullName)) { $bad++ }
    }
    if ($bad -eq 0) { Write-Pass "JSON files" "$($jsonFiles.Count) valid" }
    else { Write-Fail "JSON files" "$bad invalid"; $allOk = $false }
} finally {
    Pop-Location
}

# ── Stats ─────────────────────────────────────────
Write-Section "Stats"

Write-Pass "Version" "v$(Get-CurrentVersion)"
Write-Pass "Templates" "$(Get-TemplateCount) .code-workspace file(s)"
Write-Pass "Profiles" "$(Get-ProfileCount) profile(s)"
Write-Pass "Docs" "$(Get-DocCount) doc(s)"
Write-Pass "Scripts" "$(Get-ScriptCount) PowerShell script(s)"

# ── Recommendations ───────────────────────────────
Write-Section "Recommendations"

$recs = 0

if ((Get-TemplateCount) -eq 0) {
    Write-Warn "No templates" "create one with menu Option 2"
    $recs++
}

if ((Get-ProfileCount) -eq 0) {
    Write-Warn "No profiles" "export from VS Code: Ctrl+Shift+P → Profiles: Export Profile"
    $recs++
}

$gitRem = Get-GitRemote
if (-not $gitRem) {
    Write-Warn "No git remote" "set with: git remote add origin <url>"
    $recs++
}

$version = Get-CurrentVersion
if ($version -eq "unknown") {
    Write-Warn "Version unknown" "make sure CHANGELOG.md has a version header"
    $recs++
}

if ($recs -eq 0) {
    Write-Pass "All good" "no recommendations"
}

Write-Result $allOk "Environment check complete"

exit $(if ($allOk) { 0 } else { 1 })
