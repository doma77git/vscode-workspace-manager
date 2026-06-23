<#
.SYNOPSIS
    Run all project checks: JSON validation + secret scanning.
.DESCRIPTION
    Runs Run-Validate.ps1 first, then performs a local secret scan
    matching the CI workflow pattern. Exits 0 on pass, 1 on failure.
.EXAMPLE
    pwsh -NoProfile -File scripts\Run-Checks.ps1
#>

$ErrorActionPreference = "Stop"
$TemplatesRoot = Split-Path -Parent $PSScriptRoot
$exitCode = 0

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host "  🔍  VS Code Workspace Manager — Full Checks" -ForegroundColor White -NoNewline
Write-Host "      ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Step 1: Run validation
Write-Host "  ── Step 1/2 : JSON Validation ─────────────────" -ForegroundColor DarkGray
$validateScript = Join-Path $PSScriptRoot "Run-Validate.ps1"
if (Test-Path $validateScript) {
    & pwsh -NoProfile -File $validateScript
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ❌  Validation failed" -ForegroundColor Red
        $exitCode = 1
    }
} else {
    Write-Host "  ⚠️  Run-Validate.ps1 not found — skipping" -ForegroundColor Yellow
}

# Step 2: Secret scan
Write-Host "  ── Step 2/2 : Secret Scan ─────────────────────" -ForegroundColor DarkGray
$found = 0
$secretPattern = '(password|secret|api[_-]?key|token|private_key)'
$knownSafe = @('.gitignore', 'deepseek-byok.json', 'deepseek-keys.json', 'Init-TemplatesRepo.ps1', 'Run-Checks.ps1', 'WorkspaceManager.ps1', 'Makefile')

Get-ChildItem -Path $TemplatesRoot -File -Recurse -ErrorAction SilentlyContinue |
    Where-Object {
        $_.FullName -notmatch '\\.git\\' -and
        $_.FullName -notmatch '\\.github\\' -and
        $_.Extension -notin @('.lock', '.exe', '.dll') -and
        $_.Extension -ne '.md' -and
        $_.Extension -ne '.txt' -and
        $_.Name -ne '.editorconfig' -and
        $_.Name -notin $knownSafe
    } |
    ForEach-Object {
        $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
        if ($content -match $secretPattern) {
            Write-Host "  ⚠️  $($_.Name) — potential secret pattern" -ForegroundColor Red
            $script:found = 1
        }
    }

if ($found -eq 1) {
    Write-Host ""
    Write-Host "  ❌  Potential secrets detected!" -ForegroundColor Red
    Write-Host "      Review the files above and remove any real secrets." -ForegroundColor Yellow
    Write-Host "      Use git commit --no-verify to bypass if false positive." -ForegroundColor Yellow
    $exitCode = 1
} else {
    Write-Host "  ✅  No secrets detected" -ForegroundColor Green
}

Write-Host ""
Write-Host "  ── Result ────────────────────────────────────" -ForegroundColor DarkGray
if ($exitCode -eq 0) {
    Write-Host "  ✅  ALL CHECKS PASSED" -ForegroundColor Green
} else {
    Write-Host "  ❌  SOME CHECKS FAILED" -ForegroundColor Red
}
Write-Host ""

exit $exitCode
