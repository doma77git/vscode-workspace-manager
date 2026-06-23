<#
.SYNOPSIS
    Run all project operations in sequence — the single entry point.
.DESCRIPTION
    Runs: test → validate → checks → doctor → stats summary.
    Use -Quick for test+validate only. Use -Json for machine output.
    Exits 0 only if all steps pass.
.PARAMETER Quick
    Run only test + validate (faster).
.PARAMETER Json
    Output results as JSON (for CI/automation).
.EXAMPLE
    pwsh -NoProfile -File scripts\Run-All.ps1
    # Full pipeline

.EXAMPLE
    pwsh -NoProfile -File scripts\Run-All.ps1 -Quick
    # Test + validate only

.EXAMPLE
    pwsh -NoProfile -File scripts\Run-All.ps1 -Json
    # Machine-readable output
#>

param(
    [switch]$Quick,
    [switch]$Json
)

$ErrorActionPreference = "Stop"
$TemplatesRoot = Split-Path -Parent $PSScriptRoot
$startTime = Get-Date
$results = @{ test = $null; validate = $null; checks = $null; doctor = $null }
$exitCode = 0

if (-not $Json) {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host "  ⚡  VS Code Workspace Manager — Run All" -ForegroundColor White -NoNewline
    Write-Host "          ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

# Step 1: Tests
if (-not $Json) { Write-Host "  ── 1/4 : Test Suite ───────────────────────────" -ForegroundColor DarkGray }
$testScript = Join-Path $PSScriptRoot "Run-Tests.ps1"
if (Test-Path $testScript) {
    & pwsh -NoProfile -File $testScript
    $results.test = ($LASTEXITCODE -eq 0)
    if ($LASTEXITCODE -ne 0) { $exitCode = 1 }
} else {
    $results.test = $false
    if (-not $Json) { Write-Host "  ⚠️  Run-Tests.ps1 not found" -ForegroundColor Yellow }
}

# Step 2: Validate
if (-not $Json) { Write-Host "  ── 2/4 : JSON Validation ──────────────────────" -ForegroundColor DarkGray }
$validateScript = Join-Path $PSScriptRoot "Run-Validate.ps1"
if (Test-Path $validateScript) {
    & pwsh -NoProfile -File $validateScript
    $results.validate = ($LASTEXITCODE -eq 0)
    if ($LASTEXITCODE -ne 0) { $exitCode = 1 }
} else {
    $results.validate = $false
}

if ($Quick) {
    # Skip checks and doctor
    $results.checks = $true
    $results.doctor = $true
} else {
    # Step 3: Checks
    if (-not $Json) { Write-Host "  ── 3/4 : Full Checks ──────────────────────────" -ForegroundColor DarkGray }
    $checksScript = Join-Path $PSScriptRoot "Run-Checks.ps1"
    if (Test-Path $checksScript) {
        & pwsh -NoProfile -File $checksScript
        $results.checks = ($LASTEXITCODE -eq 0)
        if ($LASTEXITCODE -ne 0) { $exitCode = 1 }
    } else {
        $results.checks = $false
    }

    # Step 4: Doctor
    if (-not $Json) { Write-Host "  ── 4/4 : Environment ──────────────────────────" -ForegroundColor DarkGray }
    $doctorScript = Join-Path $PSScriptRoot "Check-Environment.ps1"
    if (Test-Path $doctorScript) {
        & pwsh -NoProfile -File $doctorScript
        $results.doctor = ($LASTEXITCODE -eq 0)
        if ($LASTEXITCODE -ne 0) { $exitCode = 1 }
    } else {
        $results.doctor = $false
    }
}

# Output
$elapsed = (Get-Date) - $startTime

if ($Json) {
    $output = @{
        passed   = ($exitCode -eq 0)
        steps    = $results
        elapsed  = "$($elapsed.TotalSeconds.ToString('0.0'))s"
        version  = "1.1.0"
    }
    $output | ConvertTo-Json -Depth 2 | Write-Host
} else {
    Write-Host ""
    Write-Host "  ── Summary ────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ("  {0}  Test Suite       {1}" -f $(if ($results.test) { "✅" } else { "❌" }), $(if ($results.test) { "PASS" } else { "FAIL" })) -ForegroundColor $(if ($results.test) { "Green" } else { "Red" })
    Write-Host ("  {0}  JSON Validation  {1}" -f $(if ($results.validate) { "✅" } else { "❌" }), $(if ($results.validate) { "PASS" } else { "FAIL" })) -ForegroundColor $(if ($results.validate) { "Green" } else { "Red" })
    Write-Host ("  {0}  Full Checks      {1}" -f $(if ($results.checks) { "✅" } else { "❌" }), $(if ($results.checks) { "PASS" } else { "FAIL" })) -ForegroundColor $(if ($results.checks) { "Green" } else { "Red" })
    Write-Host ("  {0}  Environment      {1}" -f $(if ($results.doctor) { "✅" } else { "❌" }), $(if ($results.doctor) { "PASS" } else { "FAIL" })) -ForegroundColor $(if ($results.doctor) { "Green" } else { "Red" })
    Write-Host ("  ⏱️   Elapsed          $($elapsed.TotalSeconds.ToString('0.0'))s" ) -ForegroundColor DarkGray

    Write-Host ""
    if ($exitCode -eq 0) {
        Write-Host "  ✅  ALL OPERATIONS PASSED" -ForegroundColor Green
    } else {
        Write-Host "  ❌  SOME OPERATIONS FAILED" -ForegroundColor Red
    }
    Write-Host ""
}

exit $exitCode
