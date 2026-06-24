# Invoke-ProfileOperations.ps1
# VS Code profile management functions for WorkspaceManager.ps1
# Dot-sourced from WorkspaceManager.ps1 — uses its $ProfilesDir, $MetaDir, $TemplatesRoot

function Get-ProfileList {
    Write-Host "`n=== Profiles ===`n" -ForegroundColor Cyan
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
    Write-Host "`n=== Import Profile ===`n" -ForegroundColor Cyan
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

function Export-Profile {
    Write-Host "`n=== Export Profile (Single) ===`n" -ForegroundColor Cyan
    Write-Host "To export a VS Code profile:"
    Write-Host "  1. Open VS Code"
    Write-Host "  2. Ctrl+Shift+P -> Profiles: Export Profile"
    Write-Host "  3. Save the JSON file to: $ProfilesDir"
    Write-Host ""
    Write-Host "After exporting, use 'Import' option to register the profile."
    Write-Host "Or manually copy the exported JSON file to: $ProfilesDir"
    Pause
}

function Export-AllProfiles {
    Write-Host "`n=== Export All Profiles ===`n" -ForegroundColor Cyan

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
