# Invoke-WorkspaceOperations.ps1
# Workspace settings check and open functions for WorkspaceManager.ps1
# Dot-sourced from WorkspaceManager.ps1 — uses its $TemplatesDir, $ProfilesDir, $MetaDir, $TemplatesRoot

function Check-VSCodeSettings {
    Write-Host "`n=== Check VS Code Settings ===`n" -ForegroundColor Cyan

    # Check VS Code CLI availability
    Write-Host "--- VS Code CLI ---" -ForegroundColor DarkGray
    try {
        $codeVersion = & code --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            $versionLine = ($codeVersion | Select-Object -First 1)
            Write-Host "[OK] code CLI available: $versionLine" -ForegroundColor Green
        } else {
            Write-Host "[WARN] code CLI not found in PATH." -ForegroundColor Yellow
            Write-Host "  Fix: VS Code -> Ctrl+Shift+P -> 'Shell Command: Install code command in PATH'"
        }
    } catch {
        Write-Host "[WARN] code CLI not found in PATH." -ForegroundColor Yellow
        Write-Host "  Fix: VS Code -> Ctrl+Shift+P -> 'Shell Command: Install code command in PATH'"
    }

    # Check VS Code settings.json
    Write-Host "`n--- Settings File ---" -ForegroundColor DarkGray
    $settingsPath = Join-Path $env:APPDATA "Code\User\settings.json"
    if (Test-Path $settingsPath) {
        Write-Host "[OK] Found settings at: $settingsPath" -ForegroundColor Green
        Validate-JsonFile $settingsPath | Out-Null
    } else {
        Write-Host "[WARN] No VS Code settings.json found at: $settingsPath" -ForegroundColor Yellow
    }

    # Check environment
    Write-Host "`n--- Environment ---" -ForegroundColor DarkGray
    Write-Host "  Templates root : $TemplatesRoot"
    Write-Host "  Templates dir  : $TemplatesDir"
    Write-Host "  Profiles dir   : $ProfilesDir"
    Write-Host "  Meta dir       : $MetaDir"
    Write-Host "  PowerShell     : $($PSVersionTable.PSVersion)"

    $templateCount = (Get-ChildItem -Path $TemplatesDir -Filter "*.code-workspace" -ErrorAction SilentlyContinue).Count
    $profileCount = (Get-ChildItem -Path $ProfilesDir -Filter "*.json" -ErrorAction SilentlyContinue).Count
    Write-Host "  Templates      : $templateCount file(s)"
    Write-Host "  Profiles       : $profileCount file(s)"

    # Recommendations
    Write-Host "`n--- Recommendations ---" -ForegroundColor DarkGray
    if ($profileCount -eq 0) {
        Write-Host "  - Export a VS Code profile to $ProfilesDir (Ctrl+Shift+P -> Profiles: Export Profile)"
    }
    if ($templateCount -eq 0) {
        Write-Host "  - Create a workspace template (option 2 in main menu)"
    }
    Write-Host "  - Run 'code --list-extensions' to see installed extensions"
    Pause
}

function Open-Workspace {
    Write-Host "`n=== Open Workspace ===`n" -ForegroundColor Cyan

    $templates = Get-ChildItem -Path $TemplatesDir -Filter "*.code-workspace" -ErrorAction SilentlyContinue
    if ($templates.Count -eq 0) {
        Write-Host "No templates found in $TemplatesDir" -ForegroundColor Yellow
        return
    }

    Write-Host "Available templates:"
    for ($i = 0; $i -lt $templates.Count; $i++) {
        $metaPath = Join-Path $MetaDir "$($templates[$i].BaseName).meta.json"
        $profileInfo = ""
        if (Test-Path $metaPath) {
            $meta = Get-Content $metaPath -Raw -Encoding UTF8 | ConvertFrom-Json
            $profileInfo = " [profile: $($meta.profile)]"
        }
        Write-Host "  $($i+1)) $($templates[$i].Name)$profileInfo"
    }

    $choice = Read-Host "Select template number (or 0 to cancel)"
    if (-not ($choice -match '^\d+$') -or [int]$choice -eq 0 -or [int]$choice -gt $templates.Count) {
        return
    }

    $selected = $templates[[int]$choice - 1]
    $profileName = $null

    # Check for associated profile
    $metaPath = Join-Path $MetaDir "$($selected.BaseName).meta.json"
    if (Test-Path $metaPath) {
        $meta = Get-Content $metaPath -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($meta.profile) {
            $useProfile = Read-Host "Use associated profile '$($meta.profile)'? (y/n, default: y)"
            if ($useProfile -ne 'n') { $profileName = $meta.profile }
        }
    }

    # Option to choose a different profile
    if (-not $profileName) {
        $useProfile = Read-Host "Select a profile? (y/n)"
        if ($useProfile -eq 'y') {
            $profiles = Get-ChildItem -Path $ProfilesDir -Filter "*.json" -ErrorAction SilentlyContinue
            if ($profiles.Count -gt 0) {
                Write-Host "Available profiles:"
                for ($i = 0; $i -lt $profiles.Count; $i++) {
                    Write-Host "  $($i+1)) $($profiles[$i].BaseName)"
                }
                $pChoice = Read-Host "Select profile number (or 0 to skip)"
                if ($pChoice -match '^\d+$' -and [int]$pChoice -gt 0 -and [int]$pChoice -le $profiles.Count) {
                    $profileName = $profiles[[int]$pChoice - 1].BaseName
                }
            }
        }
    }

    Write-Host "Opening: $($selected.FullName)"
    if ($profileName) {
        Write-Host "With profile: $profileName"
        & code --profile $profileName $selected.FullName
    } else {
        & code $selected.FullName
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Host "[WARNING] code command exited with code $LASTEXITCODE. Is 'code' in PATH?" -ForegroundColor Yellow
    }
    Pause
}
