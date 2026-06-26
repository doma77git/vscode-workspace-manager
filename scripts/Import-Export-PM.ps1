### VSCodeTool: id="pm-import", name="Project-Manager Import", desc="Import alefragnani/vscode-project-manager projects.json into templates", category="Interop"
<#
.SYNOPSIS
    Import/export compatibility with alefragnani/vscode-project-manager.
    Converts between projects.json (PM format) and .code-workspace templates.

.DESCRIPTION
    Import:   Reads projects.json → creates .code-workspace templates + profile mappings.
    Export:   Reads .code-workspace templates → generates projects.json.
    
    Projects.json fields (PM format):
      name     - display name
      rootPath - project root (folder or .code-workspace path; supports ~ and $home)
      paths    - additional workspace folders (multifolder)
      tags     - string array
      enabled  - bool (default true if omitted)
      profile  - VS Code profile name

.PARAMETER ProjectsJson
    Path to projects.json file (for -Import). Default: searches common locations.

.PARAMETER OutputPath
    Output path for projects.json (for -Export). Default: pm-projects.json in current dir.

.PARAMETER DryRun
    Show what would be done without making changes.

.EXAMPLE
    # Import from PM into our templates/
    vscode pm-import -Import

.EXAMPLE
    # Import from a specific location
    vscode pm-import -Import -ProjectsJson "C:\Users\me\AppData\Roaming\Code\User\projects.json"

.EXAMPLE
    # Export our templates to PM format
    vscode pm-import -Export -OutputPath "C:\Users\me\AppData\Roaming\Code\User\projects.json"
#>

[CmdletBinding(DefaultParameterSetName = 'Import')]
param(
    [Parameter(ParameterSetName = 'Import', Mandatory = $true)]
    [switch]$Import,

    [Parameter(ParameterSetName = 'Export', Mandatory = $true)]
    [switch]$Export,

    [Parameter(ParameterSetName = 'Import')]
    [string]$ProjectsJson,

    [Parameter(ParameterSetName = 'Export')]
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\pm-projects.json'),

    [switch]$DryRun
)

$TemplatesRoot = Split-Path -Parent $PSScriptRoot
$TemplatesDir  = Join-Path $TemplatesRoot 'templates'
$ProfilesDir   = Join-Path $TemplatesRoot 'profiles'

# ── Import: projects.json → .code-workspace templates ──
if ($Import) {
    # Find projects.json if not specified
    if (-not $ProjectsJson) {
        $candidates = @(
            [Environment]::GetFolderPath('ApplicationData') | Join-Path -ChildPath 'Code\User\projects.json'
            [Environment]::GetFolderPath('ApplicationData') | Join-Path -ChildPath 'Code - Insiders\User\projects.json'
            "$env:USERPROFILE\.config\Code\User\projects.json"
            "$env:USERPROFILE\.config\Code - Insiders\User\projects.json"
        )
        foreach ($c in $candidates) {
            if (Test-Path $c) { $ProjectsJson = $c; break }
        }
        if (-not $ProjectsJson) {
            Write-Warning "Could not find projects.json. Use -ProjectsJson to specify path."
            Write-Host "  Common locations:" -ForegroundColor DarkGray
            $candidates | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
            Write-Host "  Or export from VS Code: Ctrl+Shift+P → Project Manager: Edit Projects" -ForegroundColor Yellow
            return
        }
    }

    Write-Host "Importing from: $ProjectsJson" -ForegroundColor Cyan
    $data = Get-Content $ProjectsJson -Raw | ConvertFrom-Json

    $count = 0
    $skipped = 0
    $newProfiles = @{}

    foreach ($proj in $data) {
        $name = $proj.name
        $rootPath = Expand-PathPM $proj.rootPath

        if (-not (Test-Path $rootPath)) {
            Write-Warning "  Skipping '$name': path not found ($rootPath)"
            $skipped++
            continue
        }

        $wsName = "$name.code-workspace"
        $wsPath = Join-Path $TemplatesDir $wsName

        # Build folders array
        $folders = @( @{ path = $rootPath } )
        if ($proj.paths) {
            foreach ($p in $proj.paths) {
                $folders += @{ path = Expand-PathPM $p }
            }
        }

        $workspace = [ordered]@{
            folders  = $folders
            settings = @{}
        }
        if ($proj.profile) {
            $workspace.profileName = $proj.profile
        }

        if ($DryRun) {
            Write-Host "  [DRY] Would create: $wsPath (profile: $($proj.profile))" -ForegroundColor Yellow
        } else {
            $workspace | ConvertTo-Json -Depth 3 | Set-Content -Path $wsPath -Encoding UTF8
            Write-Host "  Created: $wsPath" -ForegroundColor Green
        }
        $count++
    }

    Write-Host ""
    Write-Host "Imported: $count projects, Skipped: $skipped (not found)" -ForegroundColor $(if ($count -gt 0) { 'Green' } else { 'Yellow' })
    if ($DryRun) { Write-Host "Dry-run: no changes made." -ForegroundColor Yellow }
    return
}

# ── Export: .code-workspace templates → projects.json ──
if ($Export) {
    Write-Host "Exporting from: $TemplatesDir" -ForegroundColor Cyan

    $projects = @()
    $count = 0

    Get-ChildItem -Path $TemplatesDir -Filter '*.code-workspace' | ForEach-Object {
        $ws = Get-Content $_.FullName -Raw | ConvertFrom-Json
        $name = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)

        $entry = [ordered]@{
            name     = $name
            rootPath = if ($ws.folders -and $ws.folders[0].path) { $ws.folders[0].path } else { '.' }
            tags     = @()
            enabled  = $true
            profile  = ''
        }

        # Extract additional folders into paths
        $paths = @()
        if ($ws.folders.Count -gt 1) {
            for ($i = 1; $i -lt $ws.folders.Count; $i++) {
                $paths += $ws.folders[$i].path
            }
        }
        $entry.paths = $paths

        # Map profile
        if ($ws.profileName) {
            $entry.profile = $ws.profileName
        }

        # Inherit tags from a matching meta entry (future: template metadata)
        $projects += $entry
        $count++
    }

    $output = $projects | ConvertTo-Json -Depth 3

    if ($DryRun) {
        Write-Host "  [DRY] Would create: $OutputPath ($count projects)" -ForegroundColor Yellow
        Write-Host $output -ForegroundColor DarkGray
    } else {
        $output | Set-Content -Path $OutputPath -Encoding UTF8
        Write-Host "  Exported $count projects to: $OutputPath" -ForegroundColor Green
    }

    if ($DryRun) { Write-Host "Dry-run: no changes made." -ForegroundColor Yellow }
    return
}

# ── Helper: expand ~ and $home in paths ──
function Expand-PathPM {
    param([string]$Path)
    if (-not $Path) { return $Path }
    $p = $Path -replace '^\$home\b', $env:USERPROFILE
    $p = $p -replace '^~', $env:USERPROFILE
    return $p
}
