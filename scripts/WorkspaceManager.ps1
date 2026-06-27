# Cross-platform root detection
$ErrorActionPreference = "Stop"

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

# Dot-source helper functions first
. "$PSScriptRoot\Helper-Functions.ps1"

# Dot-source module functions
. "$PSScriptRoot\Invoke-ValidateChecks.ps1"
. "$PSScriptRoot\Invoke-OpenDocs.ps1"
. "$PSScriptRoot\Invoke-About.ps1"
. "$PSScriptRoot\Invoke-ScheduleTasks.ps1"
. "$PSScriptRoot\Invoke-TemplateOperations.ps1"
. "$PSScriptRoot\Invoke-ProfileOperations.ps1"
. "$PSScriptRoot\Invoke-TrustOperations.ps1"
. "$PSScriptRoot\Invoke-WorkspaceOperations.ps1"

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

    $indicators = @(
        @{ File = "package.json";        Stack = "Node.js / Web";    Profile = "web-dev" }
        @{ File = "tsconfig.json";        Stack = "TypeScript";        Profile = "web-dev" }
        @{ File = "requirements.txt";     Stack = "Python";           Profile = "python-dev" }
        @{ File = "pyproject.toml";       Stack = "Python";           Profile = "python-dev" }
        @{ File = "Pipfile";              Stack = "Python";           Profile = "python-dev" }
        @{ File = "Gemfile";              Stack = "Ruby / Rails";     Profile = "ruby-dev" }
        @{ File = "build.sbt";            Stack = "Scala";            Profile = "scala-dev" }
        @{ File = "pom.xml";              Stack = "Java / Maven";     Profile = "java-dev" }
        @{ File = "build.gradle";         Stack = "Java / Gradle";    Profile = "java-dev" }
        @{ File = "build.gradle.kts";     Stack = "Kotlin";           Profile = "kotlin-dev" }
        @{ File = "composer.json";        Stack = "PHP";              Profile = "php-dev" }
        @{ File = "Cargo.toml";           Stack = "Rust";             Profile = "rust-dev" }
        @{ File = "go.mod";               Stack = "Go";               Profile = "go-dev" }
        @{ File = "Dockerfile";           Stack = "Docker";           Profile = "docker-dev" }
        @{ File = "Makefile";             Stack = "C/C++ / General";  Profile = "cpp-dev" }
        @{ File = "CMakeLists.txt";       Stack = "C/C++ / CMake";    Profile = "cpp-dev" }
        @{ File = "*.sln";                Stack = ".NET";             Profile = "dotnet-dev" }
        @{ File = "*.csproj";             Stack = ".NET";             Profile = "dotnet-dev" }
    )

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

# ==========================================
# Main Menu (Modern)
# ==========================================
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
            } catch {
            Write-Verbose "Auto-update check skipped: $($_.Exception.Message)"
        }
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
    Write-Host "  🏠  Workspaces" -ForegroundColor Cyan -NoNewline
    Write-Host "   │   " -NoNewline -ForegroundColor DarkGray
    Write-Host "🔧 Operations" -ForegroundColor Green -NoNewline
    Write-Host "   │   " -NoNewline -ForegroundColor DarkGray
    Write-Host "🛡️  Security" -ForegroundColor Magenta
    Write-Host ""

    # ── Menu grid (sequential, grouped) ────────
    Write-Host "  [1] 🆕 New template         [5] ✅ Validate checks"
    Write-Host "  [2] 💾 Save template         [6] 🔬 Scan project"
    Write-Host "  [3] 🚀 Open workspace        [7] 🏗️  Init new repo"
    Write-Host "  [4] 👤 Profiles & export      [8] 📖 Open docs"
    Write-Host "  [9] 🔑 DeepSeek BYOK         [10] 🛡️  Workspace trust"
    Write-Host "  [13] 🔬 Scan project          [14] 🔄 Updates"
    Write-Host "  [15] ⏰ Schedule"
    Write-Host ""

    # ── Footer ─────────────────────────────────
    Write-Host "  $(('─' * $w))" -ForegroundColor DarkGray
    $last = if ($script:lastAction) { "  ← $($script:lastAction)" } else { "" }
    Write-Host "  [0] Exit   ·   R: Repair   ·   T: Test   ·   ?: Help & About   ·   U: Updates" -ForegroundColor DarkGray
    Write-Host ""

    $choice = Read-Host "▶"

    switch ($choice) {
        "1"  { $script:lastAction = "Created template"; New-WorkspaceTemplate }
        "2"  { $script:lastAction = "Saved template"; Save-WorkspaceTemplate }
        "3"  { $script:lastAction = "Opened workspace"; Open-Workspace }
        "4"  {
            $script:lastAction = "Profiles"
            do {
                Clear-Host
                Write-Host "=== Profiles ===" -ForegroundColor Cyan
                Write-Host ""
                Get-ProfileList
                Write-Host ""
                Write-Host "  1) List profiles"
                Write-Host "  2) Import profile"
                Write-Host "  3) Export single profile"
                Write-Host "  4) Export all profiles"
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
        "5"  { $script:lastAction = "Validation"; Invoke-ValidateChecks }
        "6"  { $script:lastAction = "Scanned project"; Invoke-ScanProject }
        "7"  { $script:lastAction = "Init repo"; Init-TemplatesRepo }
        "8"  { $script:lastAction = "Opened docs"; Invoke-OpenDocs }
        "9"  { $script:lastAction = "Set BYOK"; Set-DeepSeekBYOK }
        "10" { $script:lastAction = "Set trust"; Set-EmptyWorkspaceTrust }
        "R"  { $script:lastAction = "Checked settings"; Check-VSCodeSettings }
        "r"  { $script:lastAction = "Checked settings"; Check-VSCodeSettings }
        "T"  { $script:lastAction = "Tests"; & pwsh -NoProfile -File (Join-Path $TemplatesRoot "scripts\Run-All.ps1") -Quick; Pause }
        "t"  { $script:lastAction = "Tests"; & pwsh -NoProfile -File (Join-Path $TemplatesRoot "scripts\Run-All.ps1") -Quick; Pause }
        "?"  { $script:lastAction = "Help"; Invoke-About; Invoke-OpenDocs }
        "h"  { $script:lastAction = "Help"; Invoke-About; Invoke-OpenDocs }
        "H"  { $script:lastAction = "Help"; Invoke-About; Invoke-OpenDocs }
        "U"  { $script:lastAction = "Checked updates"; Invoke-UpdateCheck }
        "u"  { $script:lastAction = "Checked updates"; Invoke-UpdateCheck }
        "S"  { $script:lastAction = "Scheduled tasks"; Invoke-ScheduleTasks }
        "s"  { $script:lastAction = "Scheduled tasks"; Invoke-ScheduleTasks }
        "0"  { Write-Host "Goodbye." -ForegroundColor Green }
        default { Write-Host "Invalid option — try 1-10 or R/T/?/U/S" -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
} while ($choice -ne "0")
