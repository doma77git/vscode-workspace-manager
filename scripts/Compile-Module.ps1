<#
.SYNOPSIS
    Compile all scripts into a deployable PowerShell module.
.DESCRIPTION
    Validates all .ps1 files, generates/updates the .psm1 and .psd1,
    and optionally creates a zip archive ready for distribution.
    Exits 0 on success, 1 on failure.
.PARAMETER OutputPath
    Where to save the compiled output. Default: exports/compiled/
.PARAMETER Version
    Version string for the module. Default: read from CHANGELOG.md.
.PARAMETER Zip
    Also create a deployable zip archive.
.EXAMPLE
    pwsh -NoProfile -File scripts\Compile-Module.ps1
    # Validates, generates .psm1, updates .psd1

.EXAMPLE
    pwsh -NoProfile -File scripts\Compile-Module.ps1 -Zip
    # Also creates exports/compiled/vscode-workspace-manager-v1.1.0.zip
#>

param(
    [string]$OutputPath = "",
    [string]$Version = "",
    [switch]$Zip
)

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\Helper-Functions.ps1"
$root = Get-TemplatesRoot
$exitCode = 0

if (-not $OutputPath) { $OutputPath = Join-Path $root "exports\compiled" }
if (-not $Version) { $Version = Get-CurrentVersion }

Write-Banner "VS Code Workspace Manager — Self-Compile" "🔨"

# ── 1. Validate all scripts ──────────────────────
Write-Section "Syntax Validation"
$psFiles = Get-ChildItem (Join-Path $root "scripts") -Filter "*.ps1" -ErrorAction SilentlyContinue
$allValid = $true
foreach ($f in $psFiles) {
    if (Test-PowerShellFile $f.FullName) {
        Write-Host "  ✅  $($f.Name)" -ForegroundColor DarkGray
    } else {
        Write-Fail $f.Name "syntax error"
        $allValid = $false
        $exitCode = 1
    }
}
if (-not $allValid) {
    Write-Host ""
    Write-Fail "Compilation aborted" "fix syntax errors first"
    exit $exitCode
}
Write-Pass "All scripts" "$($psFiles.Count) valid"

# ── 2. Generate .psm1 root module ────────────────
Write-Section "Generate Root Module"
$psm1 = @'
# VSCodeWorkspaceManager — Auto-Generated Root Module
# Generated: {0}
# Version: {1}

$moduleDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$scriptsDir = Join-Path $moduleDir "scripts"

# Shared library (must be loaded first)
. (Join-Path $scriptsDir "Helper-Functions.ps1")

# Menu modules
. (Join-Path $scriptsDir "Invoke-ValidateChecks.ps1")
. (Join-Path $scriptsDir "Invoke-OpenDocs.ps1")
. (Join-Path $scriptsDir "Invoke-About.ps1")
. (Join-Path $scriptsDir "Invoke-ScheduleTasks.ps1")
. (Join-Path $scriptsDir "Invoke-TemplateOperations.ps1")
. (Join-Path $scriptsDir "Invoke-ProfileOperations.ps1")
. (Join-Path $scriptsDir "Invoke-TrustOperations.ps1")
. (Join-Path $scriptsDir "Invoke-WorkspaceOperations.ps1")

# Aliases
New-Alias -Name wsm -Value (Join-Path $scriptsDir "WorkspaceManager.ps1") -Force
New-Alias -Name wsm-test -Value (Join-Path $scriptsDir "Run-Tests.ps1") -Force
New-Alias -Name wsm-validate -Value (Join-Path $scriptsDir "Run-Validate.ps1") -Force
New-Alias -Name wsm-repair -Value (Join-Path $scriptsDir "Repair-Project.ps1") -Force
'@ -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Version

$psm1Path = Join-Path $root "VSCodeWorkspaceManager.psm1"
Set-Content -Path $psm1Path -Value $psm1 -Encoding UTF8 -NoNewline
Write-Pass "Generated" "VSCodeWorkspaceManager.psm1"

# ── 3. Update .psd1 manifest ────────────────────
Write-Section "Update Manifest"
$psd1Path = Join-Path $root "VSCodeWorkspaceManager.psd1"
if (Test-Path $psd1Path) {
    $psd1 = Get-Content $psd1Path -Raw
    $psd1 = $psd1 -replace "ModuleVersion\s*=\s*'[^']*'", "ModuleVersion = '$Version'"
    $psd1 = $psd1 -replace "'vscode-workspace-manager-v[^']*'", "'vscode-workspace-manager-v$Version'"
    Set-Content -Path $psd1Path -Value $psd1 -Encoding UTF8 -NoNewline
    Write-Pass "Updated" "VSCodeWorkspaceManager.psd1 → v$Version"
} else {
    Write-Warn "Missing" "VSCodeWorkspaceManager.psd1 — skipping"
}

# ── 4. Validate JSON configs ─────────────────────
Write-Section "Config Validation"
$configs = Get-ChildItem $root -Recurse -Include @("*.json", "*.code-workspace") -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '\\.git\\' }
$allValid = $true
foreach ($c in $configs) {
    if (Test-JsonFile $c.FullName) {
        Write-Host "  ✅  $($c.Name)" -ForegroundColor DarkGray
    } else {
        Write-Fail $c.Name "invalid JSON"
        $allValid = $false
        $exitCode = 1
    }
}
if ($allValid) { Write-Pass "All configs" "$($configs.Count) valid" }

# ── 5. Create output directory ───────────────────
Write-Section "Output"
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}
Write-Pass "Output" $OutputPath

# ── 6. Optional zip ──────────────────────────────
if ($Zip) {
    $zipName = "vscode-workspace-manager-v$Version.zip"
    $zipPath = Join-Path $OutputPath $zipName

    $tempDir = Join-Path $env:TEMP "compile-$((Get-Date).Ticks)"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

    # Copy essential files
    $include = @("scripts", "templates", "profiles", "meta", "docs", "prompts", "skills",
                 ".github", ".vscode", "*.md", "*.txt", "*.toml", "*.json", "*.psd1", "*.psm1",
                 "Makefile", "LICENSE", ".gitignore", ".gitattributes", ".editorconfig",
                 ".markdownlint.json", ".cspell.json")
    foreach ($pattern in $include) {
        Get-ChildItem $root -Name -Include $pattern -ErrorAction SilentlyContinue | ForEach-Object {
            $src = Join-Path $root $_
            $dst = Join-Path $tempDir $_
            if (Test-Path $src -PathType Container) {
                Copy-Item $src $dst -Recurse -Force -ErrorAction SilentlyContinue
            } else {
                Copy-Item $src $dst -Force -ErrorAction SilentlyContinue
            }
        }
    }

    Compress-Archive -Path "$tempDir\*" -DestinationPath $zipPath -Force
    Remove-Item -Recurse -Force $tempDir
    $size = [math]::Round((Get-Item $zipPath).Length / 1KB, 1)
    Write-Pass "Archive" "$zipName ($size KB)"
}

Write-Result ($exitCode -eq 0) "Self-compile complete"

if ($Json) {
    @{ passed = ($exitCode -eq 0); version = $Version; scripts = $psFiles.Count; configs = $configs.Count } | ConvertTo-Json -Compress | Write-Host
}

exit $exitCode
