<#
.SYNOPSIS
    Export a workspace template to .vscode/ files for a project.
.DESCRIPTION
    Reads a .code-workspace template and generates:
    - .vscode/settings.json (workspace settings)
    - .vscode/extensions.json (recommended extensions)
    - .vscode/tasks.json (if tasks defined)
    Useful for monorepos or projects that don't use .code-workspace files.
.PARAMETER Template
    Template to export. Default: sample-project.code-workspace
.PARAMETER OutputDir
    Target directory. Default: current directory/.vscode/
.PARAMETER Json
    Output result as JSON.
.EXAMPLE
    pwsh -NoProfile -File scripts\Export-Workspace.ps1
    # Exports sample-project to current dir/.vscode/

.EXAMPLE
    pwsh -NoProfile -File scripts\Export-Workspace.ps1 -Template my-app.code-workspace -OutputDir ..\my-project
#>

param(
    [string]$Template = "sample-project.code-workspace",
    [string]$OutputDir = ".",
    [switch]$Json
)

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\Helper-Functions.ps1"
$root = Get-TemplatesRoot

$templatePath = Join-Path $root "templates" $Template
if (-not (Test-Path $templatePath)) {
    if ($Json) { '{"passed":false,"error":"Template not found"}' | Write-Host; exit 1 }
    Write-Fail "Template" "$Template not found in templates/"
    exit 1
}

$ws = Get-Content $templatePath -Raw -Encoding UTF8 | ConvertFrom-Json
$vscodeDir = Join-Path $OutputDir ".vscode"
if (-not (Test-Path $vscodeDir)) { New-Item -ItemType Directory -Path $vscodeDir -Force | Out-Null }

$results = @{}

# ── 1. Export settings ──────────────────────────
if ($ws.settings) {
    $settingsPath = Join-Path $vscodeDir "settings.json"
    $ws.settings | ConvertTo-Json -Depth 5 | Set-Content -Path $settingsPath -Encoding UTF8 -NoNewline
    $results.settings = $settingsPath
}

# ── 2. Export extensions ────────────────────────
if ($ws.extensions -and $ws.extensions.recommendations) {
    $extPath = Join-Path $vscodeDir "extensions.json"
    @{ recommendations = $ws.extensions.recommendations } | ConvertTo-Json -Depth 2 | Set-Content -Path $extPath -Encoding UTF8 -NoNewline
    $results.extensions = $extPath
}

# ── 3. Export tasks ─────────────────────────────
if ($ws.tasks -and $ws.tasks.tasks -and $ws.tasks.tasks.Count -gt 0) {
    $tasksPath = Join-Path $vscodeDir "tasks.json"
    $ws.tasks | ConvertTo-Json -Depth 5 | Set-Content -Path $tasksPath -Encoding UTF8 -NoNewline
    $results.tasks = $tasksPath
}

# ── 4. Export launch (if any) ───────────────────
if ($ws.launch -and $ws.launch.configurations) {
    $launchPath = Join-Path $vscodeDir "launch.json"
    $ws.launch | ConvertTo-Json -Depth 5 | Set-Content -Path $launchPath -Encoding UTF8 -NoNewline
    $results.launch = $launchPath
}

if ($Json) {
    @{ passed = $true; files = $results } | ConvertTo-Json -Compress | Write-Host
} else {
    Write-Banner "VS Code Workspace Manager — Export" "📤"
    Write-Host "  Template : $Template" -ForegroundColor DarkGray
    Write-Host "  Output   : $vscodeDir" -ForegroundColor DarkGray
    Write-Host ""
    foreach ($key in $results.Keys) {
        Write-Pass "Exported" "$key → $($results[$key])"
    }
    Write-Result $true "Export complete"
}

exit 0
