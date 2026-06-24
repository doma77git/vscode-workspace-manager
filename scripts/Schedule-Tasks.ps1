<#
.SYNOPSIS
    Register or remove scheduled tasks for the workspace manager.
.DESCRIPTION
    Cross-platform scheduler: on Windows, uses Task Scheduler (schtasks).
    On Linux/macOS, prints cron job lines to add to crontab.
    Supports: daily validation, weekly backup, monthly auto-update check.
.PARAMETER Action
    "install" to register tasks, "uninstall" to remove them, "list" to show current.
.PARAMETER Tasks
    Comma-separated list of tasks to manage: "validate,backup,update".
    Default: all three.
.EXAMPLE
    pwsh -NoProfile -File scripts\Schedule-Tasks.ps1 -Action install
    # Registers all scheduled tasks

.EXAMPLE
    pwsh -NoProfile -File scripts\Schedule-Tasks.ps1 -Action list
    # Lists current scheduled tasks

.EXAMPLE
    pwsh -NoProfile -File scripts\Schedule-Tasks.ps1 -Action uninstall
    # Removes all scheduled tasks
#>

param(
    [ValidateSet("install", "uninstall", "list")]
    [string]$Action = "list",
    [string]$Tasks = "validate,backup,update"
)

$ErrorActionPreference = "Stop"
$TemplatesRoot = Split-Path -Parent $PSScriptRoot
$taskNames = $Tasks -split "," | ForEach-Object { $_.Trim() }

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host "  ⏰  VS Code Workspace Manager — Scheduler" -ForegroundColor White -NoNewline
Write-Host "       ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Task definitions
$taskDefs = @{
    validate = @{
        Name        = "VSCodeWS-Validate"
        Description = "Daily validation of all JSON and workspace files"
        Script      = "scripts\Run-Validate.ps1"
        Schedule    = "daily"
        Time        = "09:00"
    }
    backup = @{
        Name        = "VSCodeWS-Backup"
        Description = "Weekly backup of templates, profiles, and meta"
        Script      = "scripts\Auto-Backup.ps1"
        Schedule    = "weekly"
        Time        = "12:00"
    }
    update = @{
        Name        = "VSCodeWS-UpdateCheck"
        Description = "Monthly check for workspace manager updates"
        Script      = "scripts\Update-Self.ps1"
        Args        = "-DryRun"
        Schedule    = "monthly"
        Time        = "08:00"
    }
}

function Get-CronLine($task) {
    $scriptPath = Join-Path $TemplatesRoot $task.Script
    $args = if ($task.Args) { " $($task.Args)" } else { "" }

    $time = $task.Time -split ":"
    $hour = [int]$time[0]
    $minute = [int]$time[1]

    $cronSchedule = switch ($task.Schedule) {
        "daily"   { "$minute $hour * * *" }
        "weekly"  { "$minute $hour * * 1" }
        "monthly" { "$minute $hour 1 * *" }
    }

    return "$cronSchedule pwsh -NoProfile -File '$scriptPath'$args"
}

if ($Action -eq "list") {
    Write-Host "  Current platform: $($PSVersionTable.OS)" -ForegroundColor DarkGray
    Write-Host ""

    if ($IsWindows -or (-not (Test-Path variable:IsWindows))) {
        Write-Host "  ── Windows Task Scheduler ────────────────────" -ForegroundColor DarkGray
        foreach ($name in $taskNames) {
            if ($taskDefs.ContainsKey($name)) {
                $t = $taskDefs[$name]
                $result = & schtasks /query /tn $t.Name 2>$null
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "  ✅  $($t.Name) — registered ($($t.Schedule) at $($t.Time))" -ForegroundColor Green
                } else {
                    Write-Host "  ❌  $($t.Name) — not registered" -ForegroundColor Red
                }
            }
        }
    } else {
        Write-Host "  ── Cron Jobs ─────────────────────────────────" -ForegroundColor DarkGray
        foreach ($name in $taskNames) {
            if ($taskDefs.ContainsKey($name)) {
                $t = $taskDefs[$name]
                $cronLine = Get-CronLine $t
                Write-Host "  📋  $($t.Name) — $($t.Description)" -ForegroundColor White
                Write-Host "      $cronLine" -ForegroundColor DarkGray
            }
        }
        Write-Host ""
        Write-Host "  Run 'crontab -l' to see current jobs." -ForegroundColor Yellow
        Write-Host "  Run 'crontab -e' to edit and add the lines above." -ForegroundColor Yellow
    }
}

if ($Action -eq "install") {
    if ($IsWindows -or (-not (Test-Path variable:IsWindows))) {
        Write-Host "  Platform: Windows — using Task Scheduler" -ForegroundColor DarkGray
        Write-Host ""

        foreach ($name in $taskNames) {
            if ($taskDefs.ContainsKey($name)) {
                $t = $taskDefs[$name]
                $scriptPath = Join-Path $TemplatesRoot $t.Script
                $args = if ($t.Args) { " $($t.Args)" } else { "" }

                $scheduleMap = @{ daily = "DAILY"; weekly = "WEEKLY"; monthly = "MONTHLY" }
                $schedule = $scheduleMap[$t.Schedule]

                Write-Host "  ⚡ Registering: $($t.Name) ($($t.Schedule) at $($t.Time))" -ForegroundColor Cyan
                & schtasks /create /tn $t.Name /tr "pwsh -NoProfile -File '$scriptPath'$args" /sc $schedule /st $t.Time /f 2>$null
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "  ✅  Task registered: $($t.Name)" -ForegroundColor Green
                } else {
                    Write-Host "  ⚠️  May need admin rights. Try running as Administrator." -ForegroundColor Yellow
                }
            }
        }
    } else {
        Write-Host "  Platform: Linux/macOS — using cron" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  Add these lines to your crontab (crontab -e):" -ForegroundColor Yellow
        Write-Host ""

        foreach ($name in $taskNames) {
            if ($taskDefs.ContainsKey($name)) {
                $t = $taskDefs[$name]
                $scriptPath = Join-Path $TemplatesRoot $t.Script
                $args = if ($t.Args) { " $($t.Args)" } else { "" }
                $cronLine = Get-CronLine $t
                Write-Host "  # $($t.Description)" -ForegroundColor DarkGray
                Write-Host "  $cronLine" -ForegroundColor White
                Write-Host ""
            }
        }
    }
    Write-Host ""
    Write-Host "  ✅  Scheduling complete." -ForegroundColor Green
}

if ($Action -eq "uninstall") {
    if ($IsWindows -or (-not (Test-Path variable:IsWindows))) {
        foreach ($name in $taskNames) {
            if ($taskDefs.ContainsKey($name)) {
                $t = $taskDefs[$name]
                & schtasks /delete /tn $t.Name /f 2>$null
                Write-Host "  🗑️  Removed: $($t.Name)" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "  Remove the corresponding lines from crontab -e." -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "  ✅  Tasks removed." -ForegroundColor Green
}

Write-Host ""
