@{
    RootModule        = 'VSCodeWorkspaceManager.psm1'
    ModuleVersion = '1.1.0'
    GUID              = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
    Author            = 'VS Code Workspace Manager Contributors'
    CompanyName       = ''
    Copyright         = '(c) 2026. MIT License.'
    Description       = 'Manage VS Code workspace templates, profiles, terminal settings, tasks, validation, and automation from a single repository.'
    PowerShellVersion = '7.0'
    RequiredModules   = @()
    FunctionsToExport = @(
        'Invoke-ValidateChecks',
        'Invoke-OpenDocs',
        'Invoke-About',
        'Invoke-ScanProject',
        'Invoke-UpdateCheck',
        'Invoke-ScheduleTasks',
        'Write-Banner',
        'Write-Section',
        'Write-Pass',
        'Write-Fail',
        'Write-Warn',
        'Write-Result',
        'Test-JsonFile',
        'Test-PowerShellFile',
        'Get-CurrentVersion',
        'Get-TemplateCount',
        'Get-ProfileCount',
        'Get-DocCount',
        'Get-ScriptCount',
        'Get-GitRemote',
        'Get-TemplatesRoot',
        'Get-TestCount',
        'Validate-JsonFile',
        'New-WorkspaceTemplate',
        'Save-WorkspaceTemplate',
        'Search-Templates',
        'Get-ProfileList',
        'Import-Profile',
        'Export-Profile',
        'Export-AllProfiles',
        'Set-DeepSeekBYOK',
        'Set-EmptyWorkspaceTrust',
        'Check-VSCodeSettings',
        'Open-Workspace'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @('wsm', 'wsm-test', 'wsm-validate')
    PrivateData       = @{
        PSData = @{
            Tags         = @('vscode', 'workspace', 'profiles', 'terminal', 'templates', 'powershell', 'automation')
            LicenseUri   = 'https://github.com/your-org/vscode-workspace-manager/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/your-org/vscode-workspace-manager'
            ReleaseNotes = 'See CHANGELOG.md'
        }
    }
    FileList          = @(
        'VSCodeWorkspaceManager.psm1',
        'VSCodeWorkspaceManager.psd1',
        'scripts/WorkspaceManager.ps1',
        'scripts/Helper-Functions.ps1',
        'scripts/Invoke-ValidateChecks.ps1',
        'scripts/Invoke-OpenDocs.ps1',
        'scripts/Invoke-About.ps1',
        'scripts/Invoke-ScheduleTasks.ps1',
        'scripts/Invoke-TemplateOperations.ps1',
        'scripts/Invoke-ProfileOperations.ps1',
        'scripts/Invoke-TrustOperations.ps1',
        'scripts/Invoke-WorkspaceOperations.ps1',
        'scripts/Run-Validate.ps1',
        'scripts/Run-Checks.ps1',
        'scripts/Run-Tests.ps1',
        'scripts/Run-All.ps1',
        'scripts/Check-Environment.ps1',
        'scripts/Open-WithProfile.ps1',
        'scripts/Update-Self.ps1',
        'scripts/Auto-Backup.ps1',
        'scripts/Schedule-Tasks.ps1',
        'scripts/Recommend-Extensions.ps1',
        'scripts/Navigate-Project.ps1',
        'scripts/Init-TemplatesRepo.ps1'
    )
}
