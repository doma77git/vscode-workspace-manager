<#
.SYNOPSIS
    Check that all recommended VS Code extensions are installable.
.DESCRIPTION
    Reads extensions from profiles and workspace templates, then
    checks each extension ID against the VS Code Marketplace to
    verify it exists. Reports any stale or deprecated IDs.
    Exits 0 if all found, 1 if any are missing.
.PARAMETER Json
    Output result as JSON.
.EXAMPLE
    pwsh -NoProfile -File scripts\Check-Extensions.ps1
    # Checks all extensions in templates/ and profiles/
#>

param([switch]$Json)

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\Helper-Functions.ps1"
$root = Get-TemplatesRoot
$allExtensions = @{}
$missing = @()
$found = 0; $total = 0

# ── Collect extension IDs ───────────────────────
# From workspace templates
Get-ChildItem (Join-Path $root "templates") -Filter "*.code-workspace" -ErrorAction SilentlyContinue | ForEach-Object {
    $ws = Get-Content $_.FullName -Raw | ConvertFrom-Json
    if ($ws.extensions -and $ws.extensions.recommendations) {
        foreach ($ext in $ws.extensions.recommendations) {
            $allExtensions[$ext] = $_.Name
        }
    }
}

# From profiles
Get-ChildItem (Join-Path $root "profiles") -Filter "*.json" -ErrorAction SilentlyContinue | ForEach-Object {
    $profile = Get-Content $_.FullName -Raw | ConvertFrom-Json
    if ($profile.extensions) {
        $extList = $profile.extensions | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($extList) {
            foreach ($ext in $extList) {
                $id = if ($ext.identifier) { $ext.identifier.id } else { $ext }
                $allExtensions[$id] = $_.Name
            }
        }
    }
}

if (-not $Json) {
    Write-Banner "VS Code Workspace Manager — Extension Check" "🔌"
    Write-Host "  Checking $($allExtensions.Count) extension(s)..." -ForegroundColor DarkGray
    Write-Host ""
}

# ── Check each extension ────────────────────────
foreach ($extId in $allExtensions.Keys) {
    $total++
    $source = $allExtensions[$extId]

    # Query VS Code Marketplace API
    try {
        $response = Invoke-WebRequest -Uri "https://marketplace.visualstudio.com/items?itemName=$extId" `
            -Method Head -TimeoutSec 5 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            $found++
            if (-not $Json) { Write-Host "  ✅  $extId  (from $source)" -ForegroundColor DarkGray }
        } else {
            $missing += $extId
            if (-not $Json) { Write-Warn $extId "HTTP $($response.StatusCode) (from $source)" }
        }
    } catch [Microsoft.PowerShell.Commands.HttpResponseException] {
        $statusCode = [int]$_.Exception.Response.StatusCode
        if ($statusCode -eq 404) {
            $reason = "not found in marketplace"
        } elseif ($statusCode -eq 429) {
            $reason = "rate limited"
        } elseif ($statusCode -ge 500) {
            $reason = "marketplace server error"
        } else {
            $reason = "HTTP $statusCode"
        }
        $missing += $extId
        if (-not $Json) { Write-Warn $extId "$reason (from $source)" }
    } catch {
        $missing += $extId
        if (-not $Json) { Write-Warn $extId "unexpected error: $($_.Exception.Message) (from $source)" }
    }
}

# ── Report ──────────────────────────────────────
if ($Json) {
    @{
        passed = ($missing.Count -eq 0)
        total  = $total
        found  = $found
        missing = $missing
    } | ConvertTo-Json -Compress | Write-Host
} else {
    Write-Host ""
    Write-Host "  ── Summary ────────────────────────────────────" -ForegroundColor DarkGray
    Write-Pass "Found" "$found/$total"
    if ($missing.Count -gt 0) {
        Write-Fail "Missing" ($missing -join ", ")
    }
    Write-Result ($missing.Count -eq 0) "Extension check complete"
}

exit $(if ($missing.Count -eq 0) { 0 } else { 1 })
