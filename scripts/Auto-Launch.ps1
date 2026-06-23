<#
.SYNOPSIS
    Auto-launcher — start the workspace manager on system boot or terminal open.
.DESCRIPTION
    Registers the workspace manager to auto-start with Windows or adds
    a shell profile hook for Linux/macOS. Use -Uninstall to remove.
.PARAMETER Action
    install, uninstall, or status.
.EXAMPLE
    pwsh -NoProfile -File scripts\Auto-Launch.ps1 -Action install
    pwsh -NoProfile -File scripts\Auto-Launch.ps1 -Action status
#>

param([ValidateSet("install","uninstall","status")][string]$Action = "status")

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\Helper-Functions.ps1"
$root = Get-TemplatesRoot

Write-Banner "VS Code Workspace Manager — Auto-Launch" "🚀"

if ($Action -eq "status") {
    if ($IsWindows -or (-not (Test-Path variable:IsWindows))) {
        $task = & schtasks /query /tn "VSCodeWS-AutoLaunch" 2>$null
        if ($LASTEXITCODE -eq 0) { Write-Pass "Auto-launch" "registered (Windows Task Scheduler)" }
        else { Write-Warn "Auto-launch" "not registered" }
    } else {
        if (Test-Path "$env:HOME/.bashrc") {
            if (grep -q "workspace-manager" "$env:HOME/.bashrc" 2>/dev/null) {
                Write-Pass "Auto-launch" "in ~/.bashrc"
            } else { Write-Warn "Auto-launch" "not in ~/.bashrc" }
        }
    }
}

if ($Action -eq "install") {
    if ($IsWindows -or (-not (Test-Path variable:IsWindows))) {
        $cmd = "schtasks /create /tn `"VSCodeWS-AutoLaunch`" /tr `"pwsh -NoProfile -NoExit -Command 'cd `"$root`"; Write-Host ''⚙️  Workspace Manager ready'' -F Cyan'`" /sc onlogon /f"
        Invoke-Expression $cmd 2>$null
        if ($LASTEXITCODE -eq 0) { Write-Pass "Installed" "Windows Task Scheduler — runs on login" }
        else { Write-Warn "May need admin rights" }
    } else {
        $line = "# VS Code Workspace Manager auto-launch`npwsh -NoProfile -NoExit -Command 'cd $root; Write-Host ''⚙️  Workspace Manager ready'' -F Cyan'"
        if (-not (grep -q "workspace-manager" "$env:HOME/.bashrc" 2>/dev/null)) {
            Add-Content "$env:HOME/.bashrc" "`n$line"
            Write-Pass "Installed" "added to ~/.bashrc"
        }
    }
}

if ($Action -eq "uninstall") {
    if ($IsWindows -or (-not (Test-Path variable:IsWindows))) {
        & schtasks /delete /tn "VSCodeWS-AutoLaunch" /f 2>$null
        Write-Pass "Removed" "Windows Task Scheduler"
    } else {
        sed -i '/workspace-manager/d' "$env:HOME/.bashrc" 2>/dev/null
        Write-Pass "Removed" "from ~/.bashrc"
    }
}
