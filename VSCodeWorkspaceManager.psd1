@{
    RootModule        = 'WorkspaceManager.psm1'
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
        'Get-TemplatesRoot'
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
        'WorkspaceManager.ps1',
        'Helper-Functions.ps1',
        'Invoke-ValidateChecks.ps1',
        'Invoke-OpenDocs.ps1',
        'Invoke-About.ps1',
        'Invoke-ScheduleTasks.ps1',
        'Run-Validate.ps1',
        'Run-Checks.ps1',
        'Run-Tests.ps1',
        'Run-All.ps1',
        'Check-Environment.ps1',
        'Open-WithProfile.ps1',
        'Update-Self.ps1',
        'Auto-Backup.ps1',
        'Schedule-Tasks.ps1',
        'Recommend-Extensions.ps1',
        'Navigate-Project.ps1',
        'Init-TemplatesRepo.ps1'
    )
}
