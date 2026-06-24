# Invoke-TemplateOperations.ps1
# Template creation, saving, and search functions for WorkspaceManager.ps1
# Dot-sourced from WorkspaceManager.ps1 — uses its $TemplatesDir, $MetaDir, $ProfilesDir, $TemplatesRoot

function New-WorkspaceTemplate {
    Write-Host "`n=== New Workspace Template ===" -ForegroundColor Cyan

    $name = Read-Host "Enter template name (without extension)"
    if ([string]::IsNullOrWhiteSpace($name)) {
        Write-Host "[ERROR] Name cannot be empty." -ForegroundColor Red
        return
    }

    $projectName = Read-Host "Enter project name (replaces `${PROJECT_NAME})"
    $gitRemote = Read-Host "Enter Git remote URL (replaces `${GIT_REMOTE}, leave blank for none)"

    $multiRoot = Read-Host "Multi-root workspace? (y/n, default: n)"
    $isMultiRoot = $multiRoot -eq 'y'

    $templatePath = Join-Path $TemplatesDir "$name.code-workspace"

    if ($isMultiRoot) {
        $folders = @()
        do {
            $folderPath = Read-Host "Enter folder path relative to .code-workspace (or blank to finish)"
            if (-not [string]::IsNullOrWhiteSpace($folderPath)) {
                $folderName = Read-Host "Enter folder display name"
                $folders += @{ path = $folderPath; name = $folderName }
            }
        } while (-not [string]::IsNullOrWhiteSpace($folderPath))
    }

    # Build workspace JSON
    $ws = @{
        folders = @()
        settings = @{
            "editor.formatOnSave" = $true
            "editor.tabSize" = 4
        }
        extensions = @{ recommendations = @() }
    }

    if ($isMultiRoot -and $folders.Count -gt 0) {
        foreach ($f in $folders) {
            $ws.folders += @{ path = $f.path; name = $f.name }
        }
    } else {
        $ws.folders += @{ path = ".."; name = $projectName }
    }

    if ($gitRemote) {
        $ws | Add-Member -MemberType NoteProperty -Name "git.remote" -Value $gitRemote -Force
    }

    $json = $ws | ConvertTo-Json -Depth 4

    # Replace variables
    if ($projectName) {
        $json = $json -replace '\$\{PROJECT_NAME\}', $projectName
    }
    if ($gitRemote) {
        $json = $json -replace '\$\{GIT_REMOTE\}', $gitRemote
    }

    Set-Content -Path $templatePath -Value $json -Encoding UTF8 -NoNewline
    Write-Host "[OK] Template created: $templatePath" -ForegroundColor Green

    # Profile assignment
    $assignProfile = Read-Host "Assign a profile? (y/n)"
    if ($assignProfile -eq 'y') {
        $profiles = Get-ChildItem -Path $ProfilesDir -Filter "*.json" -ErrorAction SilentlyContinue
        if ($profiles.Count -gt 0) {
            Write-Host "Available profiles:"
            for ($i = 0; $i -lt $profiles.Count; $i++) {
                Write-Host "  $($i+1)) $($profiles[$i].BaseName)"
            }
            $choice = Read-Host "Select profile number (or 0 to skip)"
            if ($choice -match '^\d+$' -and [int]$choice -gt 0 -and [int]$choice -le $profiles.Count) {
                $selectedProfile = $profiles[[int]$choice - 1]
                $metaPath = Join-Path $MetaDir "$name.meta.json"
                $meta = @{
                    template = "$name.code-workspace"
                    profile = $selectedProfile.Name
                    projectName = $projectName
                    gitRemote = $gitRemote
                    created = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                }
                $meta | ConvertTo-Json -Depth 3 | Set-Content -Path $metaPath -Encoding UTF8 -NoNewline
                Write-Host "[OK] Profile assigned and metadata saved to: $metaPath" -ForegroundColor Green
            }
        } else {
            Write-Host "No profiles found in $ProfilesDir. Export one from VS Code first." -ForegroundColor Yellow
        }
    }

    Validate-JsonFile $templatePath | Out-Null
    Pause
}

function Save-WorkspaceTemplate {
    Write-Host "`n=== Save Workspace Template ===`n" -ForegroundColor Cyan
    $sourcePath = Read-Host "Enter path to existing .code-workspace file"
    if (-not (Test-Path $sourcePath)) {
        Write-Host "[ERROR] File not found: $sourcePath" -ForegroundColor Red
        return
    }
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($sourcePath)
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $destPath = Join-Path $TemplatesDir "$baseName-$timestamp.code-workspace"

    Copy-Item $sourcePath $destPath
    Write-Host "[OK] Template saved: $destPath" -ForegroundColor Green

    if (Validate-JsonFile $destPath) {
        $replaceVars = Read-Host "Replace variables `${PROJECT_NAME} and `${GIT_REMOTE}? (y/n)"
        if ($replaceVars -eq 'y') {
            $content = Get-Content $destPath -Raw -Encoding UTF8
            $projectName = Read-Host "Enter project name"
            $gitRemote = Read-Host "Enter Git remote URL (or blank)"
            if ($projectName) {
                $content = $content -replace '\$\{PROJECT_NAME\}', $projectName
            }
            if ($gitRemote) {
                $content = $content -replace '\$\{GIT_REMOTE\}', $gitRemote
            }
            Set-Content -Path $destPath -Value $content -Encoding UTF8 -NoNewline
            Write-Host "[OK] Variables replaced." -ForegroundColor Green
        }
    }
    Pause
}

function Search-Templates {
    Write-Host "`n=== Search Templates ===`n" -ForegroundColor Cyan
    $query = Read-Host "Enter search query (searches template names, metadata, and file contents)"
    if ([string]::IsNullOrWhiteSpace($query)) {
        Write-Host "[ERROR] Query cannot be empty." -ForegroundColor Red
        return
    }

    Write-Host "`nSearching templates/ for: $query" -ForegroundColor Yellow
    Write-Host ("-" * 50)

    $found = 0

    # Search template file names
    $nameMatches = Get-ChildItem -Path $TemplatesDir -Filter "*.code-workspace" -ErrorAction SilentlyContinue `
        | Where-Object { $_.BaseName -match $query }
    foreach ($t in $nameMatches) {
        Write-Host "[NAME]  $($t.Name)" -ForegroundColor Green
        $found++
    }

    # Search inside .code-workspace files
    $null = Get-ChildItem -Path $TemplatesDir -Filter "*.code-workspace" -ErrorAction SilentlyContinue `
        | Where-Object { -not ($_.BaseName -match $query) } `
        | ForEach-Object {
            $content = Get-Content $_.FullName -Raw -Encoding UTF8
            if ($content -match $query) {
                Write-Host "[CONTENT] $($_.Name)" -ForegroundColor Green
                $found++
            }
        }

    # Search metadata files
    $null = Get-ChildItem -Path $MetaDir -Filter "*.meta.json" -ErrorAction SilentlyContinue `
        | ForEach-Object {
            $content = Get-Content $_.FullName -Raw -Encoding UTF8
            if ($content -match $query) {
                $metaData = $content | ConvertFrom-Json
                Write-Host "[META]   $($metaData.template) — project: $($metaData.projectName)" -ForegroundColor Green
                $found++
            }
        }

    if ($found -eq 0) {
        Write-Host "No templates matched '$query'." -ForegroundColor Yellow
    } else {
        Write-Host ("-" * 50)
        Write-Host "$found result(s) found." -ForegroundColor Cyan
    }
    Pause
}
