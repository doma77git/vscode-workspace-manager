<#
.SYNOPSIS
    Validate all JSON and .code-workspace files in the project.
.DESCRIPTION
    Recursively scans all JSON and .code-workspace files (excluding .git),
    parses each with ConvertFrom-Json, and reports pass/fail per file
    with aligned columns. Exits 0 on pass, 1 on failure.
.EXAMPLE
    pwsh -NoProfile -File scripts\Run-Validate.ps1
.EXAMPLE
    pwsh -NoProfile -File scripts\Run-Validate.ps1 -Json
#>

param([switch]$Json)

$ErrorActionPreference = "Stop"
$TemplatesRoot = Split-Path -Parent $PSScriptRoot
$exitCode = 0
$ok = 0; $fail = 0

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host "  ✅  VS Code Workspace Manager — Validate" -ForegroundColor White -NoNewline
Write-Host "          ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$files = Get-ChildItem -Path $TemplatesRoot -Recurse -Include @("*.json", "*.code-workspace") -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '\\.git\\' }

foreach ($f in $files) {
    try {
        $null = Get-Content $f.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
        Write-Host ("  {0}  {1,-35} valid" -f "✅", $f.Name) -ForegroundColor Green
        $ok++
    } catch {
        Write-Host ("  {0}  {1,-35} {2}" -f "❌", $f.Name, $_.Exception.Message) -ForegroundColor Red
        $fail++
        $script:exitCode = 1
    }
}

if ($Json) {
    @{ passed = ($exitCode -eq 0); ok = $ok; fail = $fail } | ConvertTo-Json -Compress | Write-Host
} else {
    Write-Host ""
    Write-Host "  ── Result ────────────────────────────────────" -ForegroundColor DarkGray
    if ($exitCode -eq 0) {
        Write-Host "  ✅  All $ok file(s) validated successfully" -ForegroundColor Green
    } else {
        Write-Host "  ❌  $ok passed, $fail failed" -ForegroundColor Red
    }
    Write-Host ""
}

exit $exitCode
