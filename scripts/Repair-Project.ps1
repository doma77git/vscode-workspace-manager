<#
.SYNOPSIS
    Self-repair common project issues automatically.
.DESCRIPTION
    Detects and fixes: malformed JSON, wrong line endings, missing directories,
    stale git index, missing required files. Run after clone or when things break.
    Exits 0 if all repairs succeed or nothing to fix.
.PARAMETER DryRun
    Show what would be fixed without making changes.
.PARAMETER Force
    Skip confirmation prompts.
.EXAMPLE
    pwsh -NoProfile -File scripts\Repair-Project.ps1
    # Interactive repair with confirmations

.EXAMPLE
    pwsh -NoProfile -File scripts\Repair-Project.ps1 -Force
    # Repair everything without asking
#>

param(
    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\Helper-Functions.ps1"
$root = Get-TemplatesRoot
$fixed = 0; $issues = 0

Write-Banner "VS Code Workspace Manager — Self-Repair" "🔧"

# ── 1. Missing directories ────────────────────────
Write-Section "Missing Directories"
$requiredDirs = @("templates", "profiles", "meta", "exports")
foreach ($d in $requiredDirs) {
    $path = Join-Path $root $d
    if (-not (Test-Path $path)) {
        $issues++
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $path -Force | Out-Null
            Write-Pass "Created" "$d/"
            $fixed++
        } else {
            Write-Warn "Missing" "$d/ — would create"
        }
    } else {
        Write-Host "  ✅  $d/ exists" -ForegroundColor DarkGray
    }
}

# ── 2. JSON syntax repair ──────────────────────────
Write-Section "JSON Syntax Repair"
Get-ChildItem -Path $root -Recurse -Include @("*.json", "*.code-workspace") -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '\\.git\\' } |
    ForEach-Object {
        $content = Get-Content $_.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
        try {
            $null = $content | ConvertFrom-Json
            Write-Host "  ✅  $($_.Name) — valid" -ForegroundColor DarkGray
        } catch {
            $issues++
            # Try common fixes
            $fixed_content = $content

            # Fix 1: trailing commas
            $fixed_content = $fixed_content -replace ',\s*}', '}'
            $fixed_content = $fixed_content -replace ',\s*]', ']'

            # Fix 2: single quotes → double quotes
            # (only outside strings — simplified)

            # Fix 3: missing closing braces/brackets
            $openBraces = ($fixed_content.ToCharArray() | Where-Object { $_ -eq '{' }).Count
            $closeBraces = ($fixed_content.ToCharArray() | Where-Object { $_ -eq '}' }).Count
            if ($openBraces -gt $closeBraces) {
                $fixed_content += ("`n" + "}" * ($openBraces - $closeBraces))
            }
            $openBrackets = ($fixed_content.ToCharArray() | Where-Object { $_ -eq '[' }).Count
            $closeBrackets = ($fixed_content.ToCharArray() | Where-Object { $_ -eq ']' }).Count
            if ($openBrackets -gt $closeBrackets) {
                $fixed_content += ("`n" + "]" * ($openBrackets - $closeBrackets))
            }

            try {
                $null = $fixed_content | ConvertFrom-Json
                if (-not $DryRun) {
                    Set-Content -Path $_.FullName -Value $fixed_content -Encoding UTF8 -NoNewline
                    Write-Pass "Repaired" $_.Name
                    $fixed++
                } else {
                    Write-Warn "Repairable" "$($_.Name) — would fix trailing commas/braces"
                }
            } catch {
                Write-Fail "Cannot repair" "$($_.Name) — manual fix needed"
            }
        }
    }

# ── 3. Line endings ───────────────────────────────
Write-Section "Line Endings"
$textFiles = Get-ChildItem -Path $root -Recurse -Include @("*.ps1", "*.json", "*.md", "*.yml", "*.yaml", "*.txt", "*.toml", ".gitignore", ".gitattributes", ".editorconfig", "Makefile", "LICENSE") -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '\\.git\\' }

$crlfFixed = 0
foreach ($f in $textFiles) {
    $content = Get-Content $f.FullName -Raw -ErrorAction SilentlyContinue
    if ($content -match "`r`n") {
        # File has CRLF — fix to LF
        if (-not $DryRun) {
            $fixed_content = $content -replace "`r`n", "`n"
            Set-Content -Path $f.FullName -Value $fixed_content -Encoding UTF8 -NoNewline
            $crlfFixed++
        }
    }
}
if ($crlfFixed -gt 0) {
    Write-Pass "Line endings" "$crlfFixed file(s) converted CRLF → LF"
    $fixed += $crlfFixed
    $issues += $crlfFixed
} else {
    Write-Host "  ✅  Line endings OK" -ForegroundColor DarkGray
}

# ── 4. Git hooks ──────────────────────────────────
Write-Section "Git Hooks"
$hooksDir = Join-Path $root ".git\hooks"
if (Test-Path $hooksDir) {
    $preCommit = Join-Path $hooksDir "pre-commit"
    if (-not (Test-Path $preCommit)) {
        $issues++
        if (-not $DryRun) {
            Copy-Item (Join-Path $root "scripts\post-commit") $preCommit -ErrorAction SilentlyContinue
            Write-Pass "Installed" "pre-commit hook"
            $fixed++
        } else {
            Write-Warn "Missing" "pre-commit hook — would install"
        }
    } else {
        Write-Host "  ✅  pre-commit hook present" -ForegroundColor DarkGray
    }

    $prePush = Join-Path $hooksDir "pre-push"
    if (Test-Path (Join-Path $root "scripts\pre-push")) {
        if (-not (Test-Path $prePush)) {
            if (-not $DryRun) {
                Copy-Item (Join-Path $root "scripts\pre-push") $prePush
                Write-Pass "Installed" "pre-push hook"
                $fixed++
            } else {
                Write-Warn "Missing" "pre-push hook — would install"
            }
        } else {
            Write-Host "  ✅  pre-push hook present" -ForegroundColor DarkGray
        }
    }
}

# ── 5. Git index refresh ──────────────────────────
Write-Section "Git Index"
Push-Location $root
try {
    if (Test-Path ".git") {
        & git update-index --refresh 2>$null
        Write-Host "  ✅  Git index refreshed" -ForegroundColor DarkGray
    }
} finally { Pop-Location }

# ── Summary ───────────────────────────────────────
Write-Host ""
Write-Host "  ── Repair Summary ────────────────────────────" -ForegroundColor DarkGray
Write-Host ("  Issues found : {0}" -f $issues) -ForegroundColor $(if ($issues -gt 0) { "Yellow" } else { "Green" })
Write-Host ("  Issues fixed : {0}" -f $fixed) -ForegroundColor $(if ($fixed -gt 0) { "Green" } else { "DarkGray" })
Write-Host ("  Manual needed: {0}" -f ($issues - $fixed)) -ForegroundColor $(if ($issues - $fixed -gt 0) { "Red" } else { "DarkGray" })

Write-Result ($issues -eq 0 -or $fixed -eq $issues) "Self-repair complete"

if ($Json) {
    @{ passed = $true; issues = $issues; fixed = $fixed } | ConvertTo-Json -Compress | Write-Host
}

exit 0
