@echo off
set "ROOT=%~dp0"
where pwsh >nul 2>&1
if %errorlevel% neq 0 (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%vscode.ps1" %*
    exit /b %errorlevel%
)
pwsh -NoProfile -ExecutionPolicy Bypass -File "%ROOT%vscode.ps1" %*
exit /b %errorlevel%
