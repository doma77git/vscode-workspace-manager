@echo off
REM VS Code Workspace Manager — portable launcher
REM Place the parent folder in PATH, then type "wsm" from any directory.
REM Uses %~dp0 to find the repo root regardless of current working directory.

setlocal
set "ROOT=%~dp0"

where pwsh >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARN] PowerShell 7 (pwsh) not found — trying powershell.exe
    where powershell >nul 2>&1
    if %errorlevel% neq 0 (
        echo [FAIL] No PowerShell found. Install PowerShell 7+:
        echo https://github.com/PowerShell/PowerShell
        pause
        exit /b 1
    )
    powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%wsm.ps1" %*
    exit /b %errorlevel%
)

pwsh -NoProfile -ExecutionPolicy Bypass -File "%ROOT%wsm.ps1" %*
exit /b %errorlevel%
