<#
.SYNOPSIS
    Open a project in VS Code with an auto-detected or specified profile.
.DESCRIPTION
    Scans the target directory for language/framework indicator files,
    auto-detects the best matching VS Code profile, and opens the project
    with `code --profile <name>`. Falls back to the default profile
    if no match is found.
.PARAMETER Path
    Project directory to open. Defaults to current directory (.).
.PARAMETER Profile
    Explicit profile name to use. Overrides auto-detection.
.PARAMETER ListMappings
    Print the indicator→profile mapping table and exit.
.PARAMETER DryRun
    Show what would be opened without actually launching VS Code.
.EXAMPLE
    pwsh -NoProfile -File scripts\Open-WithProfile.ps1
    # Opens current directory with auto-detected profile.

.EXAMPLE
    pwsh -NoProfile -File scripts\Open-WithProfile.ps1 ..\my-python-app
    # Opens my-python-app with python-dev profile.

.EXAMPLE
    pwsh -NoProfile -File scripts\Open-WithProfile.ps1 -Profile web-dev
    # Opens current directory explicitly with web-dev profile.

.EXAMPLE
    pwsh -NoProfile -File scripts\Open-WithProfile.ps1 -DryRun
    # Prints what would be done without opening anything.
#>

param(
    [string]$Path = ".",
    [string]$Profile = "",
    [switch]$ListMappings,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$TemplatesRoot = Split-Path -Parent $PSScriptRoot

# Indicator → profile mapping table
$IndicatorMap = @{
    "package.json"    = @{ Stack = "Node.js / Web"; Profile = "web-dev" }
    "tsconfig.json"   = @{ Stack = "TypeScript";    Profile = "web-dev" }
    "requirements.txt" = @{ Stack = "Python";       Profile = "python-dev" }
    "pyproject.toml"  = @{ Stack = "Python";        Profile = "python-dev" }
    "Pipfile"         = @{ Stack = "Python";        Profile = "python-dev" }
    "Gemfile"         = @{ Stack = "Ruby / Rails";  Profile = "ruby-dev" }
    "build.sbt"       = @{ Stack = "Scala";         Profile = "scala-dev" }
    "pom.xml"         = @{ Stack = "Java / Maven";  Profile = "java-dev" }
    "build.gradle"    = @{ Stack = "Java / Gradle"; Profile = "java-dev" }
    "Cargo.toml"      = @{ Stack = "Rust";          Profile = "rust-dev" }
    "go.mod"          = @{ Stack = "Go";            Profile = "go-dev" }
    "Dockerfile"      = @{ Stack = "Docker";        Profile = "docker-dev" }
    "Makefile"        = @{ Stack = "C/C++ General"; Profile = "cpp-dev" }
    "CMakeLists.txt"  = @{ Stack = "C/C++ CMake";   Profile = "cpp-dev" }
}

# --list-mappings: show the mapping table
if ($ListMappings) {
    Write-Host ""
    Write-Host "Indicator → Profile Mapping" -ForegroundColor Cyan
    Write-Host ("─" * 50)
    $IndicatorMap.Keys | Sort-Object | ForEach-Object {
        $m = $IndicatorMap[$_]
        Write-Host ("  {0,-20} → {1,-16} ({2})" -f $_, $m.Profile, $m.Stack)
    }
    Write-Host ""
    exit 0
}

# Resolve path
$targetPath = Resolve-Path $Path -ErrorAction SilentlyContinue
if (-not $targetPath) {
    Write-Host "[ERROR] Path not found: $Path" -ForegroundColor Red
    exit 1
}

# Validate VS Code CLI
$codeAvailable = $true
try { $null = & code --version 2>&1; if ($LASTEXITCODE -ne 0) { $codeAvailable = $false } }
catch { $codeAvailable = $false }
if (-not $codeAvailable) {
    Write-Host "[ERROR] VS Code CLI (code) not found in PATH." -ForegroundColor Red
    Write-Host "  Fix: VS Code → Ctrl+Shift+P → 'Shell Command: Install code command in PATH'" -ForegroundColor Yellow
    exit 1
}

Write-Host "Open-WithProfile" -ForegroundColor Cyan
Write-Host ("─" * 50)

# Determine profile
$selectedProfile = $Profile
$detectedStacks = @()

if (-not $selectedProfile) {
    Write-Host "Scanning: $targetPath" -ForegroundColor DarkGray
    foreach ($indicator in $IndicatorMap.Keys) {
        $matches = Get-ChildItem -Path $targetPath -Recurse -Name -Filter $indicator -ErrorAction SilentlyContinue
        if ($matches) {
            $m = $IndicatorMap[$indicator]
            $detectedStacks += $m
            Write-Host "  Found: $indicator → $($m.Stack) ($($m.Profile))" -ForegroundColor Green
        }
    }

    if ($detectedStacks.Count -eq 0) {
        Write-Host "  No indicators found — using default profile." -ForegroundColor Yellow
        $selectedProfile = ""  # empty = default
    } else {
        # Use first match
        $selectedProfile = $detectedStacks[0].Profile
        Write-Host ""
        Write-Host "Selected profile: $selectedProfile" -ForegroundColor Cyan
        if ($detectedStacks.Count -gt 1) {
            $others = ($detectedStacks[1..($detectedStacks.Count-1)] | ForEach-Object { $_.Profile } | Select-Object -Unique) -join ", "
            Write-Host "Also detected: $others" -ForegroundColor DarkGray
        }
    }
} else {
    Write-Host "Explicit profile: $selectedProfile" -ForegroundColor Cyan
}

# Open in VS Code
$profileArg = if ($selectedProfile) { @("--profile", $selectedProfile) } else { @() }
$args = $profileArg + $targetPath

if ($DryRun) {
    Write-Host ""
    Write-Host "[DRY-RUN] Would run: code $args" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Opening: code $args" -ForegroundColor White
& code $args

if ($LASTEXITCODE -ne 0) {
    Write-Host "[WARN] code exited with code $LASTEXITCODE" -ForegroundColor Yellow
    exit 1
}
exit 0

# Register tab-completion for -Profile parameter (dot-source in $PROFILE)
# Add to your PowerShell profile: . /path/to/Open-WithProfile.ps1
Register-ArgumentCompleter -CommandName 'Open-WithProfile.ps1', 'Open-WithProfile' -ParameterName 'Profile' -ScriptBlock {
    $ProfilesDir = Join-Path (Split-Path -Parent $PSScriptRoot) "profiles"
    Get-ChildItem -Path $ProfilesDir -Filter "*.json" -ErrorAction SilentlyContinue |
        ForEach-Object { $_.BaseName } |
        Where-Object { $_ -like "$wordToComplete*" } |
        ForEach-Object { [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_) }
}
