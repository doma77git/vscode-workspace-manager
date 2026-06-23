# Cross-platform root detection
if (-not (Test-Path env:TEMPLATES_ROOT)) {
    if ($IsWindows -or (-not (Test-Path variable:IsWindows))) {
        $TemplatesRoot = "C:\VSCode\Templates"
    } elseif ($IsLinux) {
        $TemplatesRoot = "$env:HOME/vscode/Templates"
    } elseif ($IsMacOS) {
        $TemplatesRoot = "$env:HOME/vscode/Templates"
    }
} else {
    $TemplatesRoot = $env:TEMPLATES_ROOT
}
$TemplatesDir  = Join-Path $TemplatesRoot "templates"
$ProfilesDir   = Join-Path $TemplatesRoot "profiles"
$MetaDir       = Join-Path $TemplatesRoot "meta"

# Dot-source module functions
. "$PSScriptRoot\Invoke-ValidateChecks.ps1"
. "$PSScriptRoot\Invoke-OpenDocs.ps1"
. "$PSScriptRoot\Invoke-About.ps1"
. "$PSScriptRoot\Invoke-ScheduleTasks.ps1"

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

function Invoke-ScanProject {
    Write-Host "`n=== Scan Project for Recommendations ===" -ForegroundColor Cyan
    $scanPath = Read-Host "Enter project path to scan (or blank for current directory .)"
    if ([string]::IsNullOrWhiteSpace($scanPath)) { $scanPath = "." }

    if (-not (Test-Path $scanPath)) {
        Write-Host "[ERROR] Path not found: $scanPath" -ForegroundColor Red
        Pause
        return
    }

    $scanPath = Resolve-Path $scanPath
    Write-Host "`nScanning: $scanPath" -ForegroundColor White
    Write-Host ("-" * 50)

    $indicators = @()
    $indicators += @{ File = "package.json";        Stack = "Node.js / Web";    Profile = "web-dev" }
    $indicators += @{ File = "tsconfig.json";        Stack = "TypeScript";        Profile = "web-dev" }
    $indicators += @{ File = "requirements.txt";     Stack = "Python";           Profile = "python-dev" }
    $indicators += @{ File = "pyproject.toml";       Stack = "Python";           Profile = "python-dev" }
    $indicators += @{ File = "Pipfile";              Stack = "Python";           Profile = "python-dev" }
    $indicators += @{ File = "Gemfile";              Stack = "Ruby / Rails";     Profile = "ruby-dev" }
    $indicators += @{ File = "build.sbt";            Stack = "Scala";            Profile = "scala-dev" }
    $indicators += @{ File = "pom.xml";              Stack = "Java / Maven";     Profile = "java-dev" }
    $indicators += @{ File = "build.gradle";         Stack = "Java / Gradle";    Profile = "java-dev" }
    $indicators += @{ File = "Cargo.toml";           Stack = "Rust";             Profile = "rust-dev" }
    $indicators += @{ File = "go.mod";               Stack = "Go";               Profile = "go-dev" }
    $indicators += @{ File = "Dockerfile";           Stack = "Docker";           Profile = "docker-dev" }
    $indicators += @{ File = "Makefile";             Stack = "C/C++ / General";  Profile = "cpp-dev" }
    $indicators += @{ File = "CMakeLists.txt";       Stack = "C/C++ / CMake";    Profile = "cpp-dev" }
    $indicators += @{ File = "*.sln";                Stack = ".NET";             Profile = "dotnet-dev" }
    $indicators += @{ File = "*.csproj";             Stack = ".NET";             Profile = "dotnet-dev" }
    $indicators += @{ File = "Cargo.toml";           Stack = "Rust";             Profile = "rust-dev" }

    $found = @()
    foreach ($ind in $indicators) {
        $pattern = if ($ind.File.Contains('*')) { $ind.File } else { $ind.File }
        $matches = Get-ChildItem -Path $scanPath -Recurse -Name -Filter $pattern -ErrorAction SilentlyContinue
        if ($matches) {
            $found += $ind
        }
    }

    $found = $found | Sort-Object Stack -Unique

    if ($found.Count -eq 0) {
        Write-Host "No common project indicators found." -ForegroundColor Yellow
        Write-Host "This might be a new project — create a workspace template manually." -ForegroundColor DarkGray
    } else {
        Write-Host "Detected stacks:" -ForegroundColor Green
        foreach ($f in $found) {
            Write-Host "  $($f.File) → $($f.Stack) (suggested profile: $($f.Profile))" -ForegroundColor Cyan
        }
        Write-Host ""
        Write-Host "Suggested profiles:"
        $profiles = Get-ChildItem -Path $ProfilesDir -Filter "*.json" -ErrorAction SilentlyContinue
        $suggested = @()
        foreach ($f in $found) {
            if ($f.Profile -notin $suggested) {
                $suggested += $f.Profile
            }
        }
        foreach ($sp in $suggested) {
            Write-Host "  - $sp" -ForegroundColor Green
        }
        if ($profiles.Count -gt 0) {
            Write-Host ""
            Write-Host "Available profiles in $ProfilesDir :" -ForegroundColor White
            foreach ($p in $profiles) {
                Write-Host "  - $($p.BaseName)" -ForegroundColor DarkGray
            }
        }
        Write-Host ""
        $assign = Read-Host "Assign a profile to this project? (y/n)"
        if ($assign -eq 'y' -and $profiles.Count -gt 0) {
            for ($i = 0; $i -lt $profiles.Count; $i++) {
                Write-Host "  $($i+1)) $($profiles[$i].BaseName)"
            }
            $pChoice = Read-Host "Select profile number (or 0 to skip)"
            if ($pChoice -match '^\d+$' -and [int]$pChoice -gt 0 -and [int]$pChoice -le $profiles.Count) {
                $selected = $profiles[[int]$pChoice - 1]
                $projectName = Split-Path -Leaf $scanPath
                $metaPath = Join-Path $MetaDir "$projectName.meta.json"
                $meta = @{
                    template = ""
                    profile = $selected.Name
                    projectName = $projectName
                    projectPath = $scanPath.ToString()
                    created = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                }
                $meta | ConvertTo-Json -Depth 3 | Set-Content -Path $metaPath -Encoding UTF8 -NoNewline
                Write-Host "[OK] Profile assigned: $($selected.Name) → $metaPath" -ForegroundColor Green
            }
        }
    }
    Pause
}

function Invoke-UpdateCheck {
    Write-Host "`n=== Check for Updates ===" -ForegroundColor Cyan
    $changelogPath = Join-Path $TemplatesRoot "CHANGELOG.md"
    if (-not (Test-Path $changelogPath)) {
        Write-Host "[WARN] CHANGELOG.md not found." -ForegroundColor Yellow
        Pause
        return
    }

    $changelog = Get-Content $changelogPath -Raw
    if ($changelog -match '## \[(\d+\.\d+\.\d+)\]') {
        $currentVersion = $matches[1]
        Write-Host "Current version: v$currentVersion" -ForegroundColor Green
    } else {
        Write-Host "Current version: unknown" -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "To check for updates, run:" -ForegroundColor White
    Write-Host "  git fetch origin" -ForegroundColor DarkGray
    Write-Host "  git log --oneline HEAD..origin/master" -ForegroundColor DarkGray

    $remoteUrl = & git remote get-url origin 2>$null
    if ($remoteUrl) {
        Write-Host ""
        Write-Host "Remote: $remoteUrl" -ForegroundColor DarkGray
        Write-Host "Visit the repo for the latest release." -ForegroundColor DarkGray
    }

    # Offer self-update
    Write-Host ""
    $doUpdate = Read-Host "Run self-update now? (y/n)"
    if ($doUpdate -eq 'y') {
        $updateScript = Join-Path $TemplatesRoot "scripts\Update-Self.ps1"
        if (Test-Path $updateScript) {
            & pwsh -NoProfile -File $updateScript
        } else {
            Write-Host "[ERROR] Update-Self.ps1 not found." -ForegroundColor Red
        }
    }
    Pause
}

# Main Menu (Modern)
# ========================
$script:lastAction = ""
do {
    Clear-Host

    # Terminal width detection
    $termWidth = if ($host.UI.RawUI.WindowSize.Width -gt 0) { $host.UI.RawUI.WindowSize.Width } else { 80 }
    $w = [Math]::Min($termWidth - 2, 72)

    # Auto-update check (once per session)
    if (-not $script:updateChecked) {
        $trustPath = Join-Path $MetaDir "trust.json"
        if (Test-Path $trustPath) {
            try {
                $trust = Get-Content $trustPath -Raw -Encoding UTF8 | ConvertFrom-Json
                if ($trust.autoUpdateCheck) {
                    $remote = & git -C $TemplatesRoot remote get-url origin 2>$null
                    if ($remote) {
                        & git -C $TemplatesRoot fetch origin 2>$null
                        $behind = & git -C $TemplatesRoot rev-list --count HEAD..@{u} 2>$null
                        if ($behind -and [int]$behind -gt 0) {
                            Write-Host "  ⚡ $behind update(s) available" -ForegroundColor Yellow
                        }
                    }
                }
            } catch { }
        }
        $script:updateChecked = $true
    }

    # Live stats
    $tCount = (Get-ChildItem -Path $TemplatesDir -Filter "*.code-workspace" -ErrorAction SilentlyContinue).Count
    $pCount = (Get-ChildItem -Path $ProfilesDir -Filter "*.json" -ErrorAction SilentlyContinue).Count
    $sCount = (Get-ChildItem -Path (Join-Path $TemplatesRoot "scripts") -Filter "*.ps1" -ErrorAction SilentlyContinue).Count
    $time = Get-Date -Format "HH:mm"

    # Git status
    $gitDot = "○"
    $gitLabel = ""
    try {
        & git -C $TemplatesRoot diff --quiet 2>$null
        if ($LASTEXITCODE -ne 0) { $gitDot = "●"; $gitLabel = "dirty" }
        $branch = & git -C $TemplatesRoot rev-parse --abbrev-ref HEAD 2>$null
    } catch { $branch = ""; $gitDot = "○" }

    # ── Modern Header ──────────────────────────
    $bar = "─" * $w
    Write-Host "╭$bar╮" -ForegroundColor Cyan
    Write-Host "│" -NoNewline -ForegroundColor Cyan
    Write-Host "  Workspace Manager" -ForegroundColor White -NoNewline
    Write-Host " · v1.1.0" -ForegroundColor DarkGray -NoNewline
    $right = "$time  $gitDot $branch"
    $pad = $w - 33 - $right.Length
    if ($pad -gt 0) { Write-Host (" " * $pad) -NoNewline }
    Write-Host " $right │" -ForegroundColor $(if ($gitDot -eq "●") { "Yellow" } else { "DarkGray" })
    Write-Host "├$bar┤" -ForegroundColor Cyan
    Write-Host "│" -NoNewline -ForegroundColor Cyan
    Write-Host ("  $tCount templates  ·  $pCount profiles  ·  $sCount scripts") -ForegroundColor White -NoNewline
    $pad = $w - 2 - 40
    if ($pad -gt 0) { Write-Host (" " * $pad) -NoNewline }
    Write-Host " │" -ForegroundColor Cyan
    Write-Host "╰$bar╯" -ForegroundColor Cyan
    Write-Host ""

    # ── Tab bar ────────────────────────────────
    Write-Host "  ⚒️  Workspace" -ForegroundColor Blue -NoNewline
    Write-Host "   │   " -NoNewline -ForegroundColor DarkGray
    Write-Host "👤 Profiles" -ForegroundColor Magenta -NoNewline
    Write-Host "   │   " -NoNewline -ForegroundColor DarkGray
    Write-Host "🛡️  Security" -ForegroundColor Red -NoNewline
    Write-Host "   │   " -NoNewline -ForegroundColor DarkGray
    Write-Host "🔧 Tools" -ForegroundColor Green
    Write-Host ""

    # ── Menu grid ──────────────────────────────
    Write-Host "  [1] 📄 Check settings       [2] 🆕 New template"
    Write-Host "  [3] 💾 Save template         [6] 🚀 Open workspace"
    Write-Host "  [9] 🔍 Search templates      [7] 👤 Profiles"
    Write-Host "  [4] 🔑 DeepSeek BYOK         [5] 🛡️  Trust"
    Write-Host "  [8] 🏗️  Init repo             [10] ✅ Validate"
    Write-Host "  [11] 📖 Open docs             [12] ℹ️  About"
    Write-Host "  [13] 🔬 Scan project          [14] 🔄 Updates"
    Write-Host "  [15] ⏰ Schedule"
    Write-Host ""

    # ── Footer ─────────────────────────────────
    Write-Host "  $(('─' * $w))" -ForegroundColor DarkGray
    $last = if ($script:lastAction) { "  ← $($script:lastAction)" } else { "" }
    Write-Host "  [0] Exit   ·   R: Repair   ·   T: Test   ·   ?: Help$last" -ForegroundColor DarkGray
    Write-Host ""

    $choice = Read-Host "▶"

    switch ($choice) {
        "1" { $script:lastAction = "Checked settings"; Check-VSCodeSettings }
        "2" { $script:lastAction = "Created template"; New-WorkspaceTemplate }
        "3" { $script:lastAction = "Saved template"; Save-WorkspaceTemplate }
        "4" { $script:lastAction = "Set BYOK"; Set-DeepSeekBYOK }
        "5" { $script:lastAction = "Set trust"; Set-EmptyWorkspaceTrust }
        "6" { $script:lastAction = "Opened workspace"; Open-Workspace }
        "7" {
            $script:lastAction = "Profiles"
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
        "8" { $script:lastAction = "Init repo"; Init-TemplatesRepo }
        "9" { $script:lastAction = "Searched templates"; Search-Templates }
        "10" { $script:lastAction = "Validation"; Invoke-ValidateChecks }
        "11" { $script:lastAction = "Opened docs"; Invoke-OpenDocs }
        "12" { $script:lastAction = "About"; Invoke-About }
        "13" { $script:lastAction = "Scanned project"; Invoke-ScanProject }
        "14" { $script:lastAction = "Checked updates"; Invoke-UpdateCheck }
        "15" { $script:lastAction = "Scheduled tasks"; Invoke-ScheduleTasks }
        "R" { $script:lastAction = "Repair"; Invoke-ValidateChecks }
        "r" { $script:lastAction = "Repair"; Invoke-ValidateChecks }
        "T" {
            $script:lastAction = "Tests"
            $testScript = Join-Path $TemplatesRoot "scripts\Run-All.ps1"
            if (Test-Path $testScript) { & pwsh -NoProfile -File $testScript -Quick }
            else { Write-Host "Run-All.ps1 not found" -ForegroundColor Red }
            Pause
        }
        "t" {
            $script:lastAction = "Tests"
            $testScript = Join-Path $TemplatesRoot "scripts\Run-All.ps1"
            if (Test-Path $testScript) { & pwsh -NoProfile -File $testScript -Quick }
            else { Write-Host "Run-All.ps1 not found" -ForegroundColor Red }
            Pause
        }
        "?" { $script:lastAction = "Help"; Invoke-OpenDocs }
        "h" { $script:lastAction = "Help"; Invoke-OpenDocs }
        "H" { $script:lastAction = "Help"; Invoke-OpenDocs }
        "0" { Write-Host "Goodbye." -ForegroundColor Green }
        default { Write-Host "Invalid option." -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
} while ($choice -ne "0")
