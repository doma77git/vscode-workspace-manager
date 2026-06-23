<#
.SYNOPSIS
    Recommend VS Code extensions based on a project's stack.
.DESCRIPTION
    Scans a project for language/framework indicators and outputs
    a recommended extension list for VS Code. Can output JSON for
    use in profiles.
.PARAMETER Path
    Project directory to scan. Defaults to current directory.
.PARAMETER Format
    Output format: "table" (default), "json", or "install" (code --install-extension commands).
.EXAMPLE
    pwsh -NoProfile -File scripts\Recommend-Extensions.ps1
    # Scans current dir, outputs table

.EXAMPLE
    pwsh -NoProfile -File scripts\Recommend-Extensions.ps1 -Path ..\my-py-app -Format json
    # Scans and outputs JSON for profile construction

.EXAMPLE
    pwsh -NoProfile -File scripts\Recommend-Extensions.ps1 -Format install
    # Outputs install commands to copy-paste
#>

param(
    [string]$Path = ".",
    [ValidateSet("table", "json", "install")]
    [string]$Format = "table"
)

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\Helper-Functions.ps1"

$targetPath = Resolve-Path $Path -ErrorAction SilentlyContinue
if (-not $targetPath) {
    Write-Host "  ❌  Path not found: $Path" -ForegroundColor Red
    exit 1
}

Write-Banner "VS Code Workspace Manager — Extension Recommender" "🧩"

# Indicator → extensions mapping
$ExtensionMap = @{
    "package.json" = @(
        @{ id = "dbaeumer.vscode-eslint";      name = "ESLint";         reason = "JavaScript/TypeScript linting" },
        @{ id = "esbenp.prettier-vscode";       name = "Prettier";       reason = "Code formatting" }
    )
    "tsconfig.json" = @(
        @{ id = "dbaeumer.vscode-eslint";      name = "ESLint";         reason = "TypeScript linting" },
        @{ id = "esbenp.prettier-vscode";       name = "Prettier";       reason = "Code formatting" }
    )
    "requirements.txt" = @(
        @{ id = "ms-python.python";             name = "Python";         reason = "Core Python support" },
        @{ id = "ms-python.black-formatter";    name = "Black";          reason = "Python formatting" }
    )
    "pyproject.toml" = @(
        @{ id = "ms-python.python";             name = "Python";         reason = "Core Python support" },
        @{ id = "ms-python.black-formatter";    name = "Black";          reason = "Python formatting" },
        @{ id = "charliermarsh.ruff";           name = "Ruff";           reason = "Fast Python linter" }
    )
    "Gemfile" = @(
        @{ id = "shopify.ruby-lsp";             name = "Ruby LSP";       reason = "Ruby language support" }
    )
    "pom.xml" = @(
        @{ id = "redhat.java";                  name = "Java";           reason = "Core Java support" },
        @{ id = "vscjava.vscode-maven";         name = "Maven";          reason = "Maven integration" }
    )
    "build.gradle" = @(
        @{ id = "redhat.java";                  name = "Java";           reason = "Core Java support" },
        @{ id = "vscjava.vscode-gradle";        name = "Gradle";         reason = "Gradle integration" }
    )
    "Cargo.toml" = @(
        @{ id = "rust-lang.rust-analyzer";      name = "Rust Analyzer";  reason = "Core Rust support" }
    )
    "go.mod" = @(
        @{ id = "golang.go";                    name = "Go";             reason = "Core Go support" }
    )
    "starship.toml" = @(
        @{ id = "starship.windsurf";            name = "Starship";       reason = "Shell prompt customization" }
    )
    "Dockerfile" = @(
        @{ id = "ms-azuretools.vscode-docker";  name = "Docker";         reason = "Docker support" }
    )
    "CMakeLists.txt" = @(
        @{ id = "ms-vscode.cpptools";           name = "C/C++";          reason = "C/C++ language support" },
        @{ id = "twxs.cmake";                   name = "CMake";          reason = "CMake language support" }
    )
}

Write-Host "  Scanning: $targetPath" -ForegroundColor DarkGray
Write-Host ""

# Find matches
$allExtensions = @{}
foreach ($indicator in $ExtensionMap.Keys) {
    $matches = Get-ChildItem -Path $targetPath -Recurse -Name -Filter $indicator -ErrorAction SilentlyContinue
    if ($matches) {
        Write-Host "  Found: $indicator" -ForegroundColor Green
        foreach ($ext in $ExtensionMap[$indicator]) {
            if (-not $allExtensions.ContainsKey($ext.id)) {
                $allExtensions[$ext.id] = $ext
            }
        }
    }
}

if ($allExtensions.Count -eq 0) {
    Write-Host ""
    Write-Host "  ⚠️  No indicators found. Add these universal extensions:" -ForegroundColor Yellow
    $allExtensions = @{
        "editorconfig.editorconfig"              = @{ id = "editorconfig.editorconfig"; name = "EditorConfig"; reason = "Consistent editor settings" }
        "streetsidesoftware.code-spell-checker"  = @{ id = "streetsidesoftware.code-spell-checker"; name = "Spell Checker"; reason = "Catch typos" }
        "eamodio.gitlens"                        = @{ id = "eamodio.gitlens"; name = "GitLens"; reason = "Git superpowers" }
    }
}

Write-Host ""
Write-Host "  ── Recommended Extensions ────────────────────" -ForegroundColor DarkGray

$exts = $allExtensions.Values | Sort-Object name

switch ($Format) {
    "table" {
        foreach ($e in $exts) {
            Write-Host ("  📦  {0,-36} {1}" -f $e.name, $e.reason) -ForegroundColor Cyan
            Write-Host ("      {0}" -f $e.id) -ForegroundColor DarkGray
        }
        Write-Host ""
        Write-Host "  Total: $($exts.Count) extension(s)" -ForegroundColor White
    }
    "json" {
        $result = @{
            recommendations = @($exts | ForEach-Object { $_.id })
        }
        $result | ConvertTo-Json -Depth 2 | Write-Host
    }
    "install" {
        foreach ($e in $exts) {
            Write-Host "  code --install-extension $($e.id)" -ForegroundColor DarkGray
        }
    }
}

Write-Host ""
Write-Host "  ── Result ────────────────────────────────────" -ForegroundColor DarkGray
Write-Host "  ✅  $($exts.Count) extension(s) recommended" -ForegroundColor Green
Write-Host ""

exit 0
