<#
.SYNOPSIS
    Launch the VS Code Workspace Manager from any directory.
.DESCRIPTION
    Portable entry point that auto-discovers the repo root from its own location.
    Works from any working directory — just add this folder to your PATH.
.EXAMPLE
    pwsh -File wsm.ps1
    Launches the interactive workspace manager menu.
.EXAMPLE
    pwsh -File wsm.ps1 runner
    Launches the universal runner with an interactive task picker.
.EXAMPLE
    pwsh -File wsm.ps1 runner validate
    Runs the validate task directly (non-interactive).
#>

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$env:TEMPLATES_ROOT = $RepoRoot

$task = $args[0]
$runnerScript = Join-Path $RepoRoot "scripts" "Runner.ps1"

# Valid tasks matching Runner.ps1's ValidateSet
$validTasks = @("test","validate","checks","all","doctor","backup","repair","compile","export","update","manager","navigate","recommend","ext-check","docs-gen")

if ($task -and $task -ne "runner" -and $task -in $validTasks -and (Test-Path $runnerScript)) {
    # Specific task: delegate directly (with remaining args like -Json)
    & pwsh -NoProfile -File $runnerScript -Task $task @($args[1..$args.Count])
    exit $LASTEXITCODE
}

# Interactive mode: launch Runner.ps1 (no -Task) or WorkspaceManager.ps1 as fallback
if (Test-Path $runnerScript) {
    & pwsh -NoProfile -File $runnerScript
    exit $LASTEXITCODE
}

$managerScript = Join-Path $RepoRoot "scripts" "WorkspaceManager.ps1"
if (Test-Path $managerScript) {
    & pwsh -NoProfile -ExecutionPolicy Bypass -File $managerScript
    exit $LASTEXITCODE
}

Write-Host "[ERROR] WorkspaceManager.ps1 not found at: $managerScript" -ForegroundColor Red
exit 1
