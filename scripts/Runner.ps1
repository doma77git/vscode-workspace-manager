<#
.SYNOPSIS
    Universal runner — auto-detect and run any project operation.
.DESCRIPTION
    Single entry point that auto-detects what to run based on flags
    or interactive selection. Replaces remembering individual script names.
.PARAMETER Task
    Named task to run: test, validate, checks, all, doctor, backup,
    repair, compile, export, update, manager, navigate, recommend, ext-check.
.PARAMETER Path
    Path for operations that need it (export, open, recommend).
.PARAMETER Json
    Output as machine-readable JSON.
.EXAMPLE
    pwsh -File scripts/Runner.ps1 test
    pwsh -File scripts/Runner.ps1 all -Json
    pwsh -File scripts/Runner.ps1                # Interactive
#>

[CmdletBinding()]

param(
    [ValidateSet("test","validate","checks","all","doctor","backup","repair","compile","export","update","manager","navigate","recommend","ext-check","docs-gen")]
    [string]$Task = "",
    [string]$Path = ".",
    [switch]$Json
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$env:TEMPLATES_ROOT = $root

# Task → script mapping
$map = @{
    test       = "Run-Tests.ps1"
    validate   = "Run-Validate.ps1"
    checks     = "Run-Checks.ps1"
    all        = "Run-All.ps1"
    doctor     = "Check-Environment.ps1"
    backup     = "Auto-Backup.ps1"
    repair     = "Repair-Project.ps1"
    compile    = "Compile-Module.ps1"
    export     = "Export-Workspace.ps1"
    update     = "Update-Self.ps1"
    manager    = "WorkspaceManager.ps1"
    navigate   = "Navigate-Project.ps1"
    recommend  = "Recommend-Extensions.ps1"
    "ext-check" = "Check-Extensions.ps1"
    "docs-gen"  = "Generate-Docs.ps1"
}

# If task specified, run it directly
if ($Task) {
    $script = $map[$Task]
    $scriptPath = Join-Path $PSScriptRoot $script
    if (-not (Test-Path $scriptPath)) {
        Write-Host "  ❌  Script not found: $script" -ForegroundColor Red
        exit 1
    }
    $args = @()
    if ($Task -eq "recommend") { $args = @("-Path", $Path) }
    if ($Task -eq "export") { $args = @("-OutputDir", $Path) }
    if ($Json) { $args += "-Json" }

    & pwsh -NoProfile -File $scriptPath @args
    exit $LASTEXITCODE
}

# Interactive mode
do {
    Clear-Host
    Write-Host "╭──────────────────────────────────────╮" -ForegroundColor Cyan
    Write-Host "│  🏃  Runner — What to run?           │" -ForegroundColor Cyan
    Write-Host "╰──────────────────────────────────────╯" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [1] 🧪 Test        [2] ✅ Validate" -ForegroundColor White
    Write-Host "  [3] 🔍 Checks       [4] 🚀 All" -ForegroundColor White
    Write-Host "  [5] 🩺 Doctor       [6] 💾 Backup" -ForegroundColor White
    Write-Host "  [7] 🔧 Repair       [8] 🔨 Compile" -ForegroundColor White
    Write-Host "  [9] 📤 Export       [10] 🔄 Update" -ForegroundColor White
    Write-Host "  [11] ⚙️  Manager    [12] 🧭 Navigate" -ForegroundColor White
    Write-Host "  [13] 💡 Recommend   [14] 🔌 Ext-Check" -ForegroundColor White
    Write-Host "  [15] 📝 Docs-Gen" -ForegroundColor White
    Write-Host ""
    Write-Host "  [0] Exit" -ForegroundColor DarkGray
    Write-Host ""

    $choice = Read-Host "▶"
    $taskMap = @{
        "1" = "test"; "2" = "validate"; "3" = "checks"; "4" = "all"
        "5" = "doctor"; "6" = "backup"; "7" = "repair"; "8" = "compile"
        "9" = "export"; "10" = "update"; "11" = "manager"; "12" = "navigate"
        "13" = "recommend"; "14" = "ext-check"; "15" = "docs-gen"
    }

    if ($choice -eq "0") { break }
    if ($taskMap.ContainsKey($choice)) {
        $t = $taskMap[$choice]
        $s = $map[$t]
        $sp = Join-Path $PSScriptRoot $s
        if (Test-Path $sp) {
            & pwsh -NoProfile -File $sp
        }
        if ($choice -ne "11") { Pause }
    }
} while ($true)
