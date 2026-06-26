<#
.SYNOPSIS
    Back up templates, profiles, meta, and trust data to a timestamped archive.
.DESCRIPTION
    Creates a compressed archive of all user data (templates, profiles, meta)
    in the exports/ directory with a timestamp. Can also output to a custom path.
    Excludes .git, scripts, docs, and CI files.
.PARAMETER OutputPath
    Directory to store the backup. Defaults to exports/.
.PARAMETER KeepLast
    Number of recent backups to retain. Older ones are deleted. Default: 5.
.EXAMPLE
    pwsh -NoProfile -File scripts\Auto-Backup.ps1
    # Creates exports/backup-20260623-120000.zip

.EXAMPLE
    pwsh -NoProfile -File scripts\Auto-Backup.ps1 -OutputPath D:\backups -KeepLast 10
    # Backs up to D:\backups, keeps last 10 backups
#>

[CmdletBinding()]

param(
    [string]$OutputPath = "",
    [int]$KeepLast = 5
)

$ErrorActionPreference = "Stop"
$TemplatesRoot = Split-Path -Parent $PSScriptRoot

# Default output path
if (-not $OutputPath) {
    $OutputPath = Join-Path $TemplatesRoot "exports"
}

if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$archiveName = "backup-$timestamp.zip"
$archivePath = Join-Path $OutputPath $archiveName

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host "  💾  VS Code Workspace Manager — Auto-Backup" -ForegroundColor White -NoNewline
Write-Host "      ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Push-Location $TemplatesRoot
try {
    # Collect files to back up
    $items = @()
    $items += Get-ChildItem -Path "templates" -Recurse -File -ErrorAction SilentlyContinue
    $items += Get-ChildItem -Path "profiles" -Recurse -File -ErrorAction SilentlyContinue
    $items += Get-ChildItem -Path "meta" -Recurse -File -ErrorAction SilentlyContinue
    $items += Get-ChildItem -Path "prompts" -Recurse -File -ErrorAction SilentlyContinue

    if ($items.Count -eq 0) {
        Write-Host "  ⚠️  Nothing to back up." -ForegroundColor Yellow
        exit 0
    }

    Write-Host "  Backing up $($items.Count) file(s)..." -ForegroundColor DarkGray
    Write-Host ""

    # Create archive using Compress-Archive
    $tempDir = Join-Path $env:TEMP "vscode-templates-backup-$timestamp"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

    foreach ($item in $items) {
        $relativePath = $item.FullName.Replace($TemplatesRoot, "").TrimStart("\", "/")
        $destPath = Join-Path $tempDir $relativePath
        $destDir = Split-Path $destPath -Parent
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        Copy-Item $item.FullName $destPath -Force
        Write-Host "    📄 $relativePath" -ForegroundColor DarkGray
    }

    Compress-Archive -Path "$tempDir\*" -DestinationPath $archivePath -Force
    Remove-Item -Recurse -Force $tempDir

    Write-Host ""
    Write-Host "  ✅  Backup created: $archivePath" -ForegroundColor Green

    # Show size
    $size = (Get-Item $archivePath).Length
    Write-Host "      Size: $([math]::Round($size / 1KB, 1)) KB" -ForegroundColor DarkGray

    # Clean old backups
    $existing = Get-ChildItem -Path $OutputPath -Filter "backup-*.zip" -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending

    if ($existing.Count -gt $KeepLast) {
        $toDelete = $existing[$KeepLast..($existing.Count - 1)]
        foreach ($old in $toDelete) {
            Remove-Item $old.FullName -Force
            Write-Host "  🗑️  Removed old: $($old.Name)" -ForegroundColor DarkGray
        }
    }

} finally {
    Pop-Location
}

Write-Host ""
Write-Host "  ── Result ────────────────────────────────────" -ForegroundColor DarkGray
Write-Host "  ✅  Backup complete" -ForegroundColor Green
Write-Host ""

exit 0
