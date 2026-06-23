<#
.SYNOPSIS
    Validate all PowerShell scripts for syntax errors.
.DESCRIPTION
    Parses every .ps1 file (excluding .git) using PowerShell's AST parser.
    Reports parse errors per file with aligned columns. Exits 0 on pass, 1 on fail.
.EXAMPLE
    pwsh -NoProfile -File scripts\Run-Tests.ps1
.EXAMPLE
    pwsh -NoProfile -File scripts\Run-Tests.ps1 -Json
.EXAMPLE
    pwsh -NoProfile -File scripts\Run-Tests.ps1 -Quiet
#>

param(
    [switch]$Json,
    [switch]$Quiet
)

$ErrorActionPreference = "Stop"
$TemplatesRoot = Split-Path -Parent $PSScriptRoot
$exitCode = 0
$psOk = 0; $psFail = 0; $jsonOk = 0; $jsonFail = 0; $yamlOk = 0; $yamlFail = 0

if (-not $Quiet -and -not $Json) {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host "  🧪  VS Code Workspace Manager — Test Suite" -ForegroundColor White -NoNewline
    Write-Host "          ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

# PowerShell syntax check
Write-Host "  ── PowerShell AST Parse ──────────────────────" -ForegroundColor DarkGray
$psFiles = Get-ChildItem -Path $TemplatesRoot -Recurse -Filter "*.ps1" -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '\\.git\\' }

foreach ($f in $psFiles) {
    $content = Get-Content $f.FullName -Raw -ErrorAction SilentlyContinue
    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseInput($content, [ref]$null, [ref]$errors)
    if ($errors.Count -eq 0) {
        Write-Host ("    {0}  {1,-30} PASS" -f "✅", $f.Name) -ForegroundColor Green
        $psOk++
    } else {
        Write-Host ("    {0}  {1,-30} FAIL" -f "❌", $f.Name) -ForegroundColor Red
        foreach ($err in $errors) {
            Write-Host "         Line $($err.Extent.StartLineNumber): $($err.Message)" -ForegroundColor Red
        }
        $psFail++
        $script:exitCode = 1
    }
}

# JSON syntax check
Write-Host ""
Write-Host "  ── JSON Syntax Check ─────────────────────────" -ForegroundColor DarkGray
$jsonFiles = Get-ChildItem -Path $TemplatesRoot -Recurse -Include @("*.json", "*.code-workspace") -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '\\.git\\' }

foreach ($f in $jsonFiles) {
    try {
        $null = Get-Content $f.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
        Write-Host ("    {0}  {1,-30} PASS" -f "✅", $f.Name) -ForegroundColor Green
        $jsonOk++
    } catch {
        Write-Host ("    {0}  {1,-30} FAIL  {2}" -f "❌", $f.Name, $_.Exception.Message) -ForegroundColor Red
        $jsonFail++
        $script:exitCode = 1
    }
}

# YAML syntax check
Write-Host ""
Write-Host "  ── YAML Syntax Check ─────────────────────────" -ForegroundColor DarkGray
$yamlFiles = Get-ChildItem -Path $TemplatesRoot -Recurse -Include @("*.yml", "*.yaml") -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '\\.git\\' }

foreach ($f in $yamlFiles) {
    $content = Get-Content $f.FullName -Raw -ErrorAction SilentlyContinue
    # Basic YAML validation: check for common syntax errors
    $valid = $true
    $errorMsg = ""
    try {
        # Check tab characters (YAML forbids tabs for indentation)
        $lines = $content -split "`n"
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -match "^\t") {
                $valid = $false
                $errorMsg = "Line $($i+1): tabs not allowed in YAML indentation"
                break
            }
        }
        # Check for duplicate keys (simple heuristic)
        if ($valid) {
            $keys = @{}
            foreach ($line in $lines) {
                if ($line -match '^\s*([a-zA-Z_-]+)\s*:') {
                    $key = $matches[1]
                    if ($keys.ContainsKey($key) -and $key -notin @('on', 'run', 'steps', 'env', 'with', 'jobs', 'name', 'uses', 'branches', 'url', 'if', 'needs', 'runs-on', 'schedule', 'cron', 'tags', 'pull_request', 'push', 'workflow_dispatch', 'id', 'script', 'about', 'title', 'labels', 'assignees', 'contact_links', 'blank_issues_enabled')) {
                        $valid = $false
                        $errorMsg = "Duplicate key '$key'"
                        break
                    }
                    $keys[$key] = $true
                }
            }
        }
    } catch {
        $valid = $false
        $errorMsg = $_.Exception.Message
    }

    if ($valid) {
        Write-Host ("    {0}  {1,-30} PASS" -f "✅", $f.Name) -ForegroundColor Green
        $yamlOk++
    } else {
        Write-Host ("    {0}  {1,-30} FAIL  {2}" -f "❌", $f.Name, $errorMsg) -ForegroundColor Red
        $yamlFail++
        $script:exitCode = 1
    }
}

# Summary
if ($Json) {
    $result = @{
        passed = ($exitCode -eq 0)
        summary = @{
            PowerShell = @{ passed = $psOk; failed = $psFail }
            JSON       = @{ passed = $jsonOk; failed = $jsonFail }
            YAML       = @{ passed = $yamlOk; failed = $yamlFail }
            total      = ($psOk + $psFail + $jsonOk + $jsonFail + $yamlOk + $yamlFail)
        }
    }
    $result | ConvertTo-Json -Depth 3 -Compress | Write-Host
} elseif (-not $Quiet) {
    Write-Host ""
    Write-Host "  ── Summary ───────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ("    PowerShell : {0} passed, {1} failed" -f $psOk, $psFail) -ForegroundColor $(if ($psFail -eq 0) { "Green" } else { "Red" })
    Write-Host ("    JSON       : {0} passed, {1} failed" -f $jsonOk, $jsonFail) -ForegroundColor $(if ($jsonFail -eq 0) { "Green" } else { "Red" })
    Write-Host ("    YAML       : {0} passed, {1} failed" -f $yamlOk, $yamlFail) -ForegroundColor $(if ($yamlFail -eq 0) { "Green" } else { "Red" })
    Write-Host ("    Total      : {0} checks" -f ($psOk + $psFail + $jsonOk + $jsonFail + $yamlOk + $yamlFail)) -ForegroundColor White

    Write-Host ""
    if ($exitCode -eq 0) {
        Write-Host "  ✅  ALL TESTS PASSED" -ForegroundColor Green
    } else {
        Write-Host "  ❌  SOME TESTS FAILED" -ForegroundColor Red
    }
    Write-Host ""
}

exit $exitCode
