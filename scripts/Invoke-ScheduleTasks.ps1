# Module: Invoke-ScheduleTasks
# Dot-sourced by WorkspaceManager.ps1

function Invoke-ScheduleTasks {
    Write-Host ""
    $scheduleScript = Join-Path $TemplatesRoot "scripts\Schedule-Tasks.ps1"
    if (-not (Test-Path $scheduleScript)) {
        Write-Host "  ⚠️  Schedule-Tasks.ps1 not found." -ForegroundColor Yellow
        Pause
        return
    }

    Write-Host "  ── Scheduled Tasks ───────────────────────────" -ForegroundColor DarkGray
    Write-Host "  1) 📋  List current tasks"
    Write-Host "  2) ⚡  Install all tasks (validate, backup, update)"
    Write-Host "  3) 🗑️   Uninstall all tasks"
    Write-Host "  0) 🚪  Back"
    Write-Host ""

    $sChoice = Read-Host "Select"
    switch ($sChoice) {
        "1" { & pwsh -NoProfile -File $scheduleScript -Action list }
        "2" { & pwsh -NoProfile -File $scheduleScript -Action install }
        "3" { & pwsh -NoProfile -File $scheduleScript -Action uninstall }
    }
    Pause
}
