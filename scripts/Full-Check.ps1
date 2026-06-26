<#
.SYNOPSIS
    Full system check — runs every checker in sequence.
.DESCRIPTION
    Runs: Test → Validate → Checks → Environment → Extensions.
    Single command to verify everything. Exits 0 if all pass.
.EXAMPLE
    pwsh -NoProfile -File scripts\Full-Check.ps1
    pwsh -NoProfile -File scripts\Full-Check.ps1 -Json
#>

[CmdletBinding()]

param([switch]$Json)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$start = Get-Date
$results = @{}
$failed = 0

if (-not $Json) {
    Write-Host ""
    Write-Host "╭──────────────────────────────────────╮" -ForegroundColor Cyan
    Write-Host "│  🔍  Full System Check               │" -ForegroundColor Cyan
    Write-Host "╰──────────────────────────────────────╯" -ForegroundColor Cyan
}

# 1. Tests
if (-not $Json) { Write-Host "  ── 1/4 : Tests ────────────────────────────────" -ForegroundColor DarkGray }
& pwsh -NoProfile -File (Join-Path $PSScriptRoot "Run-Tests.ps1") $(if ($Json) { "-Json" } else { "" })
$results.tests = ($LASTEXITCODE -eq 0)
if ($LASTEXITCODE -ne 0) { $failed++ }

# 2. Validate
if (-not $Json) { Write-Host "  ── 2/4 : Validate ─────────────────────────────" -ForegroundColor DarkGray }
& pwsh -NoProfile -File (Join-Path $PSScriptRoot "Run-Validate.ps1") $(if ($Json) { "-Json" } else { "" })
$results.validate = ($LASTEXITCODE -eq 0)
if ($LASTEXITCODE -ne 0) { $failed++ }

# 3. Checks
if (-not $Json) { Write-Host "  ── 3/4 : Checks ───────────────────────────────" -ForegroundColor DarkGray }
& pwsh -NoProfile -File (Join-Path $PSScriptRoot "Run-Checks.ps1") $(if ($Json) { "-Json" } else { "" })
$results.checks = ($LASTEXITCODE -eq 0)
if ($LASTEXITCODE -ne 0) { $failed++ }

# 4. Environment
if (-not $Json) { Write-Host "  ── 4/4 : Environment ──────────────────────────" -ForegroundColor DarkGray }
& pwsh -NoProfile -File (Join-Path $PSScriptRoot "Check-Environment.ps1") $(if ($Json) { "-Json" } else { "" })
$results.environment = ($LASTEXITCODE -eq 0)
if ($LASTEXITCODE -ne 0) { $failed++ }

if ($Json) {
    @{ passed = ($failed -eq 0); steps = $results; elapsed = "$([math]::Round(((Get-Date)-$start).TotalSeconds,1))s" } | ConvertTo-Json -Compress | Write-Host
} else {
    $elapsed = [math]::Round(((Get-Date)-$start).TotalSeconds,1)
    Write-Host ""
    Write-Host "  ── Result ────────────────────────────────────" -ForegroundColor DarkGray
    if ($failed -eq 0) { Write-Host "  ✅  ALL CHECKS PASSED  (${elapsed}s)" -ForegroundColor Green }
    else { Write-Host "  ❌  $failed CHECK(S) FAILED  (${elapsed}s)" -ForegroundColor Red }
    Write-Host ""
}

exit $failed
