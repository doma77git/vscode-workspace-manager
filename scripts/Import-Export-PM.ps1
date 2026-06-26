### VSCodeTool: id="pm-import", name="Project-Manager Import", desc="Import/export/scan/sync with alefragnani/vscode-project-manager", category="Interop"
<#
.SYNOPSIS
    Full interop with alefragnani/vscode-project-manager (2.5k stars).
    Import/export/scan/sync between projects.json and .code-workspace templates.

.DESCRIPTION
    Import:   Reads projects.json → creates .code-workspace templates + tag metadata.
    Export:   Reads .code-workspace templates → generates projects.json.
    Scan:     Auto-discover Git repos in a directory → create templates or projects.json.
    Sync:     Watch projects.json for changes → auto-reimport on save.

    Projects.json fields (PM format):
      name     - display name
      rootPath - project root (supports ~ and $home)
      paths    - additional workspace folders (multifolder)
      tags     - string array
      enabled  - bool
      profile  - VS Code profile name

    Tag metadata is stored in .pm-meta.json (alongside templates/) for round-trip fidelity.

.PARAMETER Import
    Import from PM format.

.PARAMETER Export
    Export to PM format.

.PARAMETER Scan
    Auto-discover Git repos recursively under a directory.

.PARAMETER Sync
    Watch projects.json and reimport on changes.

.PARAMETER ProjectsJson
    Path to projects.json (for Import/Sync). Default: searches common locations.

.PARAMETER ScanPath
    Directory to scan for Git repos (for Scan). Default: current directory.

.PARAMETER OutputPath
    Output path for projects.json (for Export/Scan). Default: pm-projects.json in repo root.

.PARAMETER DryRun
    Show what would be done without making changes.

.PARAMETER Merge
    On import: merge into existing templates instead of overwriting.

.EXAMPLE
    vscode pm-import -Import
    vscode pm-import -Import -ProjectsJson "C:\Users\me\AppData\Roaming\Code\User\projects.json"
    vscode pm-import -Export -OutputPath "C:\Users\me\AppData\Roaming\Code\User\projects.json"
    vscode pm-import -Scan -ScanPath C:\Projects
    vscode pm-import -Scan -ScanPath C:\Projects -OutputPath pm-discovered.json
    vscode pm-import -Sync -ProjectsJson "C:\Users\me\AppData\Roaming\Code\User\projects.json"
#>

[CmdletBinding(DefaultParameterSetName = 'Import')]
param(
    [Parameter(ParameterSetName = 'Import', Mandatory = $true)]
    [switch]$Import,

    [Parameter(ParameterSetName = 'Export', Mandatory = $true)]
    [switch]$Export,

    [Parameter(ParameterSetName = 'Scan', Mandatory = $true)]
    [switch]$Scan,

    [Parameter(ParameterSetName = 'Sync', Mandatory = $true)]
    [switch]$Sync,

    [Parameter(ParameterSetName = 'Import')]
    [Parameter(ParameterSetName = 'Sync')]
    [string]$ProjectsJson,

    [Parameter(ParameterSetName = 'Scan')]
    [string]$ScanPath = (Get-Location).Path,

    [Parameter(ParameterSetName = 'Export')]
    [Parameter(ParameterSetName = 'Scan')]
    [string]$OutputPath,

    [Parameter(ParameterSetName = 'Import')]
    [switch]$Merge,

    [switch]$DryRun
)

$TemplatesRoot = Split-Path -Parent $PSScriptRoot
$TemplatesDir  = Join-Path $TemplatesRoot 'templates'
$ProfilesDir   = Join-Path $TemplatesRoot 'profiles'
$MetaFile      = Join-Path $TemplatesDir '.pm-meta.json'

# ── Default OutputPath ──
if (-not $OutputPath -and ($Export -or $Scan)) {
    $OutputPath = Join-Path $TemplatesRoot 'pm-projects.json'
}

# ── Tag metadata helpers ──
function Get-PMMeta {
    if (Test-Path $MetaFile) {
        try { return Get-Content $MetaFile -Raw | ConvertFrom-Json }
        catch { return @{} }
    }
    return @{}
}

function Save-PMMeta {
    param($Meta)
    if ($DryRun) {
        Write-Host "  [DRY] Would save .pm-meta.json with tags" -ForegroundColor Yellow
    } else {
        $Meta | ConvertTo-Json -Depth 3 | Set-Content -Path $MetaFile -Encoding UTF8
    }
}

function Get-PMTags {
    param($TemplateName)
    $meta = Get-PMMeta
    if ($meta.$TemplateName -and $meta.$TemplateName.tags) {
        return $meta.$TemplateName.tags
    }
    return @()
}

function Set-PMTags {
    param($TemplateName, $Tags)
    $meta = Get-PMMeta
    if (-not $meta) { $meta = @{} }
    $meta.$TemplateName = @{ tags = @($Tags) }
    Save-PMMeta $meta
}

# ── Path expansion ──
function Expand-PathPM {
    param([string]$Path)
    if (-not $Path) { return $Path }
    $p = $Path -replace '^\$home\b', $env:USERPROFILE
    $p = $p -replace '^~', $env:USERPROFILE
    return $p
}

# ═══════════════════════════════════════════════════════════════
#  IMPORT: projects.json → .code-workspace templates
# ═══════════════════════════════════════════════════════════════
if ($Import) {
    $jsonPath = Find-ProjectsJson
    if (-not $jsonPath) { return }

    Write-Host "Importing from: $jsonPath" -ForegroundColor Cyan
    $data = Get-Content $jsonPath -Raw | ConvertFrom-Json

    if (-not $Merge) {
        # Show existing templates that would be overwritten
        $existing = Get-ChildItem -Path $TemplatesDir -Filter '*.code-workspace' | ForEach-Object { $_.BaseName }
        $incoming = $data | ForEach-Object { $_.name }
        $overlap = $incoming | Where-Object { $_ -in $existing }
        if ($overlap) {
            Write-Host "  Existing templates that will be updated:" -ForegroundColor Yellow
            $overlap | ForEach-Object { Write-Host "    - $_" -ForegroundColor DarkGray }
            Write-Host "  Use -Merge to keep both (appends ' (PM)' suffix to new ones)" -ForegroundColor DarkGray
        }
    }

    $count = 0; $skipped = 0

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

        # Merge mode: if name already exists, suffix with " (PM)"
        if ($Merge -and (Test-Path $wsPath)) {
            $wsName = "$name (PM).code-workspace"
            $wsPath = Join-Path $TemplatesDir $wsName
        }

        # Build folders array
        $folders = @( @{ path = $rootPath } )
        if ($proj.paths) {
            foreach ($p in $proj.paths) {
                $expanded = Expand-PathPM $p
                if (Test-Path $expanded) {
                    $folders += @{ path = $expanded }
                }
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
            Write-Host "  [DRY] Would create: $wsPath  profile: $($proj.profile)  tags: $($proj.tags -join ', ')" -ForegroundColor Yellow
        } else {
            $workspace | ConvertTo-Json -Depth 3 | Set-Content -Path $wsPath -Encoding UTF8
            Write-Host "  Created: $wsPath" -ForegroundColor Green
        }

        # Save tag metadata for round-trip
        if ($proj.tags -and $proj.tags.Count -gt 0) {
            Set-PMTags -TemplateName $name -Tags @($proj.tags)
        }
        $count++
    }

    Write-Host ""
    Write-Host "Imported: $count projects, Skipped: $skipped (not found)" -ForegroundColor $(if ($count -gt 0) { 'Green' } else { 'Yellow' })
    if ($DryRun) { Write-Host "Dry-run: no changes made." -ForegroundColor Yellow }
}

# ═══════════════════════════════════════════════════════════════
#  EXPORT: .code-workspace templates → projects.json
# ═══════════════════════════════════════════════════════════════
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
            tags     = @(Get-PMTags -TemplateName $name)
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
        Write-Host "  Copy this to VS Code: Ctrl+Shift+P → Project Manager: Edit Projects" -ForegroundColor DarkGray
    }

    if ($DryRun) { Write-Host "Dry-run: no changes made." -ForegroundColor Yellow }
}

# ═══════════════════════════════════════════════════════════════
#  SCAN: Auto-discover Git repos → templates or projects.json
# ═══════════════════════════════════════════════════════════════
if ($Scan) {
    if (-not (Test-Path $ScanPath)) {
        Write-Error "Scan path not found: $ScanPath"
        return
    }

    Write-Host "Scanning for Git repos under: $ScanPath" -ForegroundColor Cyan
    Write-Host "  (This may take a moment for large trees...)" -ForegroundColor DarkGray

    $discovered = @()
    $scanCount = 0

    # Recursively find .git directories (but skip .git inside other .git parents)
    Get-ChildItem -Path $ScanPath -Directory -Recurse -ErrorAction SilentlyContinue | 
        Where-Object { $_.Name -eq '.git' } |
        ForEach-Object {
            $repoPath = $_.Parent.FullName
            # Skip if parent already has a discovered repo (nested .git in submodules)
            $isNested = $discovered | Where-Object { $repoPath.StartsWith($_.rootPath + '\') }
            if ($isNested) { return }

            $repoName = Split-Path $repoPath -Leaf
            $repoRemote = ''
            try {
                $remoteUrl = & git -C $repoPath remote get-url origin 2>$null
                if ($remoteUrl) { $repoRemote = $remoteUrl.Trim() }
            } catch {}

            $discovered += [PSCustomObject]@{
                name     = $repoName
                rootPath = $repoPath
                remote   = $repoRemote
                tags     = @('git', 'auto-discovered')
                enabled  = $true
                profile  = ''
                paths    = @()
            }
            $scanCount++
        }

    Write-Host "  Found $scanCount Git repos" -ForegroundColor Green

    if ($scanCount -eq 0) {
        Write-Host "  No Git repos found. Try a different directory." -ForegroundColor Yellow
        return
    }

    # Show summary
    Write-Host ""
    Write-Host "  Discovered repos:" -ForegroundColor White
    $discovered | ForEach-Object {
        $remoteInfo = if ($_.remote) { "  → $($_.remote)" } else { '' }
        Write-Host "    $($_.name)".PadRight(40) -NoNewline
        Write-Host $remoteInfo -ForegroundColor DarkGray
    }

    Write-Host ""
    Write-Host "  Creating templates in: $TemplatesDir" -ForegroundColor Cyan

    $created = 0
    foreach ($repo in $discovered) {
        $wsName = "$($repo.name).code-workspace"
        $wsPath = Join-Path $TemplatesDir $wsName

        $workspace = [ordered]@{
            folders  = @( @{ path = $repo.rootPath } )
            settings = @{}
        }

        if ($DryRun) {
            Write-Host "  [DRY] Would create: $wsPath" -ForegroundColor Yellow
        } else {
            # Don't overwrite existing
            if (Test-Path $wsPath) {
                Write-Host "  Skipped (exists): $wsName" -ForegroundColor DarkGray
                continue
            }
            $workspace | ConvertTo-Json -Depth 3 | Set-Content -Path $wsPath -Encoding UTF8
            Write-Host "  Created: $wsName" -ForegroundColor Green
        }
        Set-PMTags -TemplateName $repo.name -Tags $repo.tags
        $created++
    }

    Write-Host ""
    Write-Host "Created: $created templates in $TemplatesDir" -ForegroundColor Green
    Write-Host "  Open with: wsm → 6 → pick template" -ForegroundColor DarkGray

    # Also export to projects.json for PM compatibility
    if ($OutputPath) {
        Write-Host ""
        Write-Host "Also exporting to PM format: $OutputPath" -ForegroundColor Cyan
        $pmProjects = $discovered | Select-Object name, rootPath, paths, tags, enabled, profile
        if (-not $DryRun) {
            $pmProjects | ConvertTo-Json -Depth 3 | Set-Content -Path $OutputPath -Encoding UTF8
            Write-Host "  Exported $($pmProjects.Count) entries" -ForegroundColor Green
        }
    }

    if ($DryRun) { Write-Host "Dry-run: no changes made." -ForegroundColor Yellow }
}

# ═══════════════════════════════════════════════════════════════
#  SYNC: Watch projects.json for changes
# ═══════════════════════════════════════════════════════════════
if ($Sync) {
    $jsonPath = Find-ProjectsJson
    if (-not $jsonPath) { return }

    Write-Host "Watching: $jsonPath" -ForegroundColor Cyan
    Write-Host "  (Press Ctrl+C to stop)" -ForegroundColor DarkGray
    Write-Host ""

    $watcher = [System.IO.FileSystemWatcher]::new(
        [System.IO.Path]::GetDirectoryName($jsonPath),
        [System.IO.Path]::GetFileName($jsonPath)
    )
    $watcher.NotifyFilter = [System.IO.NotifyFilters]::LastWrite
    $watcher.EnableRaisingEvents = $true

    $lastWrite = (Get-Item $jsonPath).LastWriteTime

    $action = {
        $path = $Event.SourceEventArgs.FullPath
        Start-Sleep -Milliseconds 500  # debounce
        $current = (Get-Item $path).LastWriteTime
        if ($current -ne $Event.MessageData) {
            Write-Host ""
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Change detected — reimporting..." -ForegroundColor Yellow
            & $PSCommandPath -Import -ProjectsJson $path
            $Event.MessageData = $current
        }
    }

    $job = Register-ObjectEvent -InputObject $watcher -EventName Changed -Action $action -MessageData $lastWrite

    try {
        while ($true) { Start-Sleep -Seconds 2 }
    } finally {
        Unregister-Event -SourceIdentifier $job.Name -ErrorAction SilentlyContinue
        $watcher.Dispose()
        Write-Host "Sync stopped." -ForegroundColor Yellow
    }
}

# ═══════════════════════════════════════════════════════════════
#  Helper: Find projects.json
# ═══════════════════════════════════════════════════════════════
function Find-ProjectsJson {
    if ($ProjectsJson) { return $ProjectsJson }

    $candidates = @(
        [Environment]::GetFolderPath('ApplicationData') | Join-Path -ChildPath 'Code\User\projects.json'
        [Environment]::GetFolderPath('ApplicationData') | Join-Path -ChildPath 'Code - Insiders\User\projects.json'
        "$env:USERPROFILE\.config\Code\User\projects.json"
        "$env:USERPROFILE\.config\Code - Insiders\User\projects.json"
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) { return $c }
    }

    Write-Warning "Could not find projects.json. Use -ProjectsJson to specify path."
    Write-Host "  Common locations:" -ForegroundColor DarkGray
    $candidates | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
    Write-Host "  Or export from VS Code: Ctrl+Shift+P → Project Manager: Edit Projects" -ForegroundColor Yellow
    return $null
}
