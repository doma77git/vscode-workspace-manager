# Module: Invoke-ValidateChecks
# Dot-sourced by WorkspaceManager.ps1

function Invoke-ValidateChecks {
    Write-Host ""
    Write-Host "  ── Running Validation Checks ─────────────────" -ForegroundColor DarkGray
    $validateScript = Join-Path $TemplatesRoot "scripts\Run-Validate.ps1"
    if (Test-Path $validateScript) {
        & pwsh -NoProfile -File $validateScript
    } else {
        Write-Host "  ⚠️  Run-Validate.ps1 not found — running inline..." -ForegroundColor Yellow
        $allOk = $true

        Get-ChildItem -Path $TemplatesDir -Filter "*.code-workspace" -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                $null = Get-Content $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
                Write-Host ("  ✅  {0} valid" -f $_.Name) -ForegroundColor Green
            } catch {
                Write-Host ("  ❌  {0}: {1}" -f $_.Name, $_.Exception.Message) -ForegroundColor Red
                $allOk = $false
            }
        }

        Get-ChildItem -Path $MetaDir -Filter "*.json" -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                $null = Get-Content $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
                Write-Host ("  ✅  {0} valid" -f $_.Name) -ForegroundColor Green
            } catch {
                Write-Host ("  ❌  {0}: {1}" -f $_.Name, $_.Exception.Message) -ForegroundColor Red
                $allOk = $false
            }
        }

        Get-ChildItem -Path $ProfilesDir -Filter "*.json" -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                $null = Get-Content $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
                Write-Host ("  ✅  {0} valid" -f $_.Name) -ForegroundColor Green
            } catch {
                Write-Host ("  ❌  {0}: {1}" -f $_.Name, $_.Exception.Message) -ForegroundColor Red
                $allOk = $false
            }
        }

        Write-Host ""
        if ($allOk) { Write-Host "  ✅  All files validated" -ForegroundColor Green }
        else { Write-Host "  ❌  Some files failed" -ForegroundColor Red }
    }
    Pause
}
