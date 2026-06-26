# VSCodeWorkspaceManager — Auto-Generated Root Module
# Generated: 2026-06-27 01:49:53
# Version: 1.1.0

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