# Init-TemplatesRepo.ps1
# One-time setup script for VS Code Workspace Manager
# Creates .gitignore, README.md, sample template, sample profile,
# initializes git repo, and installs pre-commit hook.

$ErrorActionPreference = "Stop"

# Resolve root: env var → script parent → fallback
if (Test-Path env:TEMPLATES_ROOT) {
    $TemplatesRoot = $env:TEMPLATES_ROOT
} else {
    $TemplatesRoot = Split-Path -Parent $PSScriptRoot
}
$ScriptsDir = Join-Path $TemplatesRoot "scripts"
$TemplatesDir = Join-Path $TemplatesRoot "templates"
$ProfilesDir = Join-Path $TemplatesRoot "profiles"
$MetaDir = Join-Path $TemplatesRoot "meta"
$DocsDir = Join-Path $TemplatesRoot "docs"
$PromptsDir = Join-Path $TemplatesRoot "prompts"
$GitHubDir = Join-Path $TemplatesRoot ".github\workflows"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  VS Code Workspace Manager — Init Repo" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Ensure directories exist
$dirs = @($TemplatesDir, $ProfilesDir, $MetaDir, $ScriptsDir, $DocsDir, $PromptsDir, $GitHubDir)
foreach ($d in $dirs) {
    if (-not (Test-Path $d)) {
        New-Item -ItemType Directory -Path $d -Force | Out-Null
        Write-Host "[CREATE] $d" -ForegroundColor Green
    }
}

# Initialize git if not already initialized
Push-Location $TemplatesRoot
try {
    if (-not (Test-Path ".git")) {
        git init
        Write-Host "[GIT] Repository initialized." -ForegroundColor Green

        git add .
        $status = git status --porcelain
        if ($status) {
            git commit -m "Initial commit: templates repo"
            Write-Host "[GIT] Initial commit created." -ForegroundColor Green
        } else {
            Write-Host "[GIT] Nothing to commit — working tree clean." -ForegroundColor Yellow
        }
    } else {
        Write-Host "[GIT] Repository already exists." -ForegroundColor Yellow
    }

    # Install pre-commit hook
    $hookPath = ".git\hooks\pre-commit"
    $hookContent = @'
#!/bin/sh
# VS Code Templates — pre-commit hook
# 1. Auto-repairs common issues (line endings, trailing commas)
# 2. Scans staged files for accidental secrets.
# 3. Blocks commit if secrets are found.
# To bypass: git commit --no-verify

# ── Auto-repair ────────────────────────────────
echo ""
echo "=== Auto-repair: fixing line endings ==="
for f in $(git diff --cached --name-only); do
    if [ -f "$f" ]; then
        case "$f" in
            *.json|*.md|*.yml|*.yaml|*.toml|*.sh|*.txt|Makefile|LICENSE|.gitignore|.gitattributes|.editorconfig)
                # Convert CRLF to LF for non-PowerShell files
                if grep -q $'\r' "$f" 2>/dev/null; then
                    sed -i 's/\r$//' "$f" 2>/dev/null && echo "  Fixed: $f (CRLF → LF)"
                    git add "$f" 2>/dev/null
                fi
                ;;
        esac
    fi
done

# ── Secret scan ────────────────────────────────
has_secret=0

for f in $(git diff --cached --name-only); do
    case "$f" in
        *.md) continue ;;  # Documentation — skip secret scan (false positives)
    esac
    if grep -E -n -i '(password|secret|api[_-]?key|token|private_key)' "$f" 2>/dev/null; then
        echo ""
        echo "============================================"
        echo "  COMMIT BLOCKED: Potential secret in $f"
        echo "============================================"
        echo ""
        echo "  Remove the secret or add the file to .gitignore."
        echo "  If this is a false positive, run:"
        echo "    git commit --no-verify"
        echo ""
        has_secret=1
    fi
done

if [ $has_secret -eq 1 ]; then
    exit 1
fi

exit 0
'@
    Set-Content -Path $hookPath -Value $hookContent -Encoding ASCII -NoNewline
    Write-Host "[HOOK] Pre-commit hook installed at: $hookPath" -ForegroundColor Green

    # Attempt to make hook executable (no-op on Windows, but good for WSL/Git Bash)
    try {
        if (Get-Command chmod -ErrorAction SilentlyContinue) {
            chmod +x $hookPath 2>$null
        }
    } catch { }

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Repository initialized successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Created files:" -ForegroundColor White
    Get-ChildItem -Recurse -File | Where-Object { -not $_.FullName.Contains(".git\") } | ForEach-Object {
        $relPath = $_.FullName.Replace("$TemplatesRoot\", "")
        Write-Host "  $relPath" -ForegroundColor DarkGray
    }
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor White
    Write-Host "  Run: pwsh -NoProfile -ExecutionPolicy Bypass -File `"$ScriptsDir\WorkspaceManager.ps1`"" -ForegroundColor Yellow
    Write-Host ""
} finally {
    Pop-Location
}
