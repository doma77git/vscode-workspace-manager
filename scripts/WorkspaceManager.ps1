$TemplatesRoot = "C:\VSCode\Templates"
$TemplatesDir  = Join-Path $TemplatesRoot "templates"
$ProfilesDir   = Join-Path $TemplatesRoot "profiles"
$MetaDir       = Join-Path $TemplatesRoot "meta"

function Validate-JsonFile {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        Write-Host "[ERROR] File not found: $Path" -ForegroundColor Red
        return $false
    }
    try {
        $null = Get-Content $Path -Raw -Encoding UTF8 | ConvertFrom-Json
        Write-Host "[OK] Valid JSON: $Path" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "[ERROR] Invalid JSON in $Path : $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Check-VSCodeSettings {
    Write-Host "`n=== Check VS Code Settings ===" -ForegroundColor Cyan

    # Check VS Code CLI availability
    Write-Host "`n--- VS Code CLI ---" -ForegroundColor DarkGray
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
    Write-Host "`n=== Save Workspace Template ===" -ForegroundColor Cyan
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
        $replaceVars = Read-Host "Replace variables ${PROJECT_NAME} and ${GIT_REMOTE}? (y/n)"
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

function Set-DeepSeekBYOK {
    Write-Host "`n=== Set DeepSeek BYOK ===" -ForegroundColor Cyan
    $byokPath = Join-Path $MetaDir "deepseek-byok.json"

    Write-Host "BYOK stores only metadata and instructions — no real keys are saved."
    Write-Host "See docs\BYOK-GUIDE.md for replacing the placeholder with real KMS calls."
    Write-Host ""

    if (Test-Path $byokPath) {
        $current = Get-Content $byokPath -Raw -Encoding UTF8 | ConvertFrom-Json
        Write-Host "Current status: $($current.status)"
        Write-Host "Current provider: $($current.provider)"

        $update = Read-Host "Update BYOK metadata? (y/n)"
        if ($update -ne 'y') { return }
    }

    $provider = Read-Host "Enter KMS provider (azure-keyvault / aws-kms / hashicorp-vault / placeholder)"
    if ([string]::IsNullOrWhiteSpace($provider)) { $provider = "placeholder" }

    $keyRef = Read-Host "Enter key reference URL/ARN/path (NOT the key itself)"

    $byok = @{
        version = "1.0"
        provider = $provider
        status = if ($provider -eq "placeholder") { "placeholder" } else { "configured" }
        createdAt = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        keyReference = $keyRef
        notes = "Replace this placeholder with real KMS integration. See docs/BYOK-GUIDE.md"
        kmsInstructions = @{
            description = "This file contains metadata only. Do NOT store real keys here."
            azureKeyVault = @{ command = "az keyvault secret show --vault-name <your-vault> --name deepseek-key --query value -o tsv" }
            awsKms = @{ command = "aws kms decrypt --key-id alias/deepseek --ciphertext-blob fileb://encrypted-key.bin --output text --query Plaintext" }
            hashicorpVault = @{ command = "vault kv get -field=key secret/deepseek" }
        }
    }

    $byok | ConvertTo-Json -Depth 4 | Set-Content -Path $byokPath -Encoding UTF8 -NoNewline
    Write-Host "[OK] BYOK metadata saved to: $byokPath" -ForegroundColor Green
    Write-Host "[WARNING] This file is in .gitignore — do NOT commit real keys." -ForegroundColor Yellow
    Pause
}

function Set-EmptyWorkspaceTrust {
    Write-Host "`n=== Set Empty Workspace Trust ===" -ForegroundColor Cyan
    $trustPath = Join-Path $MetaDir "trust.json"

    $current = @{ emptyWorkspaceTrust = $false }
    if (Test-Path $trustPath) {
        $current = Get-Content $trustPath -Raw -Encoding UTF8 | ConvertFrom-Json
    }

    Write-Host "Current setting: emptyWorkspaceTrust = $($current.emptyWorkspaceTrust)"
    $toggle = Read-Host "Toggle? (y/n)"
    if ($toggle -eq 'y') {
        $current.emptyWorkspaceTrust = -not $current.emptyWorkspaceTrust
        $current.version = "1.0"
        $current | ConvertTo-Json -Depth 2 | Set-Content -Path $trustPath -Encoding UTF8 -NoNewline
        Write-Host "[OK] emptyWorkspaceTrust set to: $($current.emptyWorkspaceTrust)" -ForegroundColor Green
    }
    Pause
}

function Open-Workspace {
    Write-Host "`n=== Open Workspace ===" -ForegroundColor Cyan

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

function Get-ProfileList {
    Write-Host "`n=== Profiles ===" -ForegroundColor Cyan
    $profiles = Get-ChildItem -Path $ProfilesDir -Filter "*.json" -ErrorAction SilentlyContinue
    if ($profiles.Count -eq 0) {
        Write-Host "No profiles found in $ProfilesDir" -ForegroundColor Yellow
    } else {
        foreach ($p in $profiles) {
            try {
                $content = Get-Content $p.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
                Write-Host "  $($p.Name) — $($content.name)" -ForegroundColor Green
            } catch {
                Write-Host "  $($p.Name) — [INVALID JSON]" -ForegroundColor Red
            }
        }
    }
}

function Import-Profile {
    Write-Host "`n=== Import Profile ===" -ForegroundColor Cyan
    $sourcePath = Read-Host "Enter path to profile JSON file to import"
    if (-not (Test-Path $sourcePath)) {
        Write-Host "[ERROR] File not found: $sourcePath" -ForegroundColor Red
        return
    }
    if (-not (Validate-JsonFile $sourcePath)) { return }

    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($sourcePath)
    $destPath = Join-Path $ProfilesDir "$baseName.json"

    Copy-Item $sourcePath $destPath
    Write-Host "[OK] Profile imported: $destPath" -ForegroundColor Green
    Pause
}

function Search-Templates {
    Write-Host "`n=== Search Templates ===" -ForegroundColor Cyan
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
    $contentMatches = Get-ChildItem -Path $TemplatesDir -Filter "*.code-workspace" -ErrorAction SilentlyContinue `
        | Where-Object { -not ($_.BaseName -match $query) } `
        | ForEach-Object {
            $content = Get-Content $_.FullName -Raw -Encoding UTF8
            if ($content -match $query) {
                Write-Host "[CONTENT] $($_.Name)" -ForegroundColor Green
                $script:found++
            }
        }

    # Search metadata files
    $metaMatches = Get-ChildItem -Path $MetaDir -Filter "*.meta.json" -ErrorAction SilentlyContinue `
        | ForEach-Object {
            $content = Get-Content $_.FullName -Raw -Encoding UTF8
            if ($content -match $query) {
                $metaData = $content | ConvertFrom-Json
                Write-Host "[META]   $($metaData.template) — project: $($metaData.projectName)" -ForegroundColor Green
                $script:found++
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

function Export-AllProfiles {
    Write-Host "`n=== Export All Profiles ===" -ForegroundColor Cyan

    $profiles = Get-ChildItem -Path $ProfilesDir -Filter "*.json" -ErrorAction SilentlyContinue
    if ($profiles.Count -eq 0) {
        Write-Host "No profiles to export." -ForegroundColor Yellow
        Pause
        return
    }

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $exportDir = Join-Path $TemplatesRoot "exports"
    $archiveDir = Join-Path $exportDir "profiles-$timestamp"

    if (-not (Test-Path $archiveDir)) {
        New-Item -ItemType Directory -Path $archiveDir -Force | Out-Null
    }

    foreach ($p in $profiles) {
        Copy-Item $p.FullName (Join-Path $archiveDir $p.Name) -Force
    }

    # Also export trust and BYOK metadata for reference
    $trustPath = Join-Path $MetaDir "trust.json"
    if (Test-Path $trustPath) {
        Copy-Item $trustPath (Join-Path $archiveDir "trust.json") -Force
    }

    # Create a manifest
    $manifest = @{
        exportDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        source = $TemplatesRoot
        profileCount = $profiles.Count
        profiles = @($profiles | ForEach-Object { $_.Name })
    }
    $manifest | ConvertTo-Json -Depth 3 | Set-Content -Path (Join-Path $archiveDir "manifest.json") -Encoding UTF8 -NoNewline

    Write-Host "[OK] $($profiles.Count) profile(s) exported to:" -ForegroundColor Green
    Write-Host "     $archiveDir" -ForegroundColor Green
    Write-Host "[NOTE] Exports are NOT tracked by git." -ForegroundColor DarkGray
    Pause
}
function Export-Profile {
    Write-Host "`n=== Export Profile (Single) ===" -ForegroundColor Cyan
    Write-Host "To export a VS Code profile:"
    Write-Host "  1. Open VS Code"
    Write-Host "  2. Ctrl+Shift+P -> Profiles: Export Profile"
    Write-Host "  3. Save the JSON file to: $ProfilesDir"
    Write-Host ""
    Write-Host "After exporting, use 'Import' option to register the profile."
    Write-Host "Or manually copy the exported JSON file to: $ProfilesDir"
    Pause
}

function Init-TemplatesRepo {
    Write-Host "`n=== Init Repo ===" -ForegroundColor Cyan
    $initScript = Join-Path $TemplatesRoot "scripts\Init-TemplatesRepo.ps1"
    if (Test-Path $initScript) {
        & pwsh -NoProfile -ExecutionPolicy Bypass -File $initScript
    } else {
        Write-Host "[ERROR] Init script not found: $initScript" -ForegroundColor Red
    }
    Pause
}

# ========================
# Main Menu
# ========================
do {
    Clear-Host
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  VS Code Workspace Manager" -ForegroundColor White
    Write-Host "  $TemplatesRoot" -ForegroundColor DarkGray
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  1) Check VS Code settings.json"
    Write-Host "  2) New workspace template"
    Write-Host "  3) Save workspace template"
    Write-Host "  4) Set DeepSeek BYOK"
    Write-Host "  5) Set Empty Workspace Trust"
    Write-Host "  6) Open workspace"
    Write-Host "  7) Profiles management"
    Write-Host "  8) Init repo"
    Write-Host "  9) Search templates"
    Write-Host "  0) Exit"
    Write-Host ""

    $choice = Read-Host "Select an option"

    switch ($choice) {
        "1" { Check-VSCodeSettings }
        "2" { New-WorkspaceTemplate }
        "3" { Save-WorkspaceTemplate }
        "4" { Set-DeepSeekBYOK }
        "5" { Set-EmptyWorkspaceTrust }
        "6" { Open-Workspace }
        "7" {
            do {
                Clear-Host
                Write-Host "=== Profiles Management ===" -ForegroundColor Cyan
                Write-Host ""
                Get-ProfileList
                Write-Host ""
                Write-Host "  1) List profiles"
                Write-Host "  2) Import profile"
                Write-Host "  3) Export single profile (instructions)"
                Write-Host "  4) Export all profiles (bulk archive)"
                Write-Host "  0) Back"
                $pChoice = Read-Host "Select"
                switch ($pChoice) {
                    "1" { Get-ProfileList; Pause }
                    "2" { Import-Profile }
                    "3" { Export-Profile }
                    "4" { Export-AllProfiles }
                }
            } while ($pChoice -ne "0")
        }
        "8" { Init-TemplatesRepo }
        "9" { Search-Templates }
        "0" { Write-Host "Goodbye." -ForegroundColor Green }
        default { Write-Host "Invalid option." -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
} while ($choice -ne "0")
