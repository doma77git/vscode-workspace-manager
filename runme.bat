@echo off
REM VS Code Workspace Manager — Quick Launcher (runme.bat)
REM Double-click or run from cmd.exe to launch the menu.

setlocal
set "ROOT=%~dp0"

echo.
echo  VS Code Workspace Manager
echo  ========================
echo  Tip: Add this folder to PATH and run "wsm" from anywhere.

REM Check for PowerShell 7
where pwsh >nul 2>&1
if %errorlevel% neq 0 (
    echo  [WARN] PowerShell 7 (pwsh) not found — trying powershell.exe
    where powershell >nul 2>&1
    if %errorlevel% neq 0 (
        echo  [FAIL] No PowerShell found. Install PowerShell 7+:
        echo  https://github.com/PowerShell/PowerShell
        pause
        exit /b 1
    )
    powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%scripts\Runner.ps1"
) else (
    pwsh -NoProfile -ExecutionPolicy Bypass -File "%ROOT%scripts\Runner.ps1"
)

endlocal
