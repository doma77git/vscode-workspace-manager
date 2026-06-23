# Setup Guide

## Prerequisites

Before starting, verify these tools are installed and in your PATH:

```powershell
pwsh --version      # PowerShell 7+ required
git --version
code --version      # VS Code CLI
```

If `code` is not in PATH:
1. Open VS Code
2. Press `Ctrl+Shift+P` → type `Shell Command: Install 'code' command in PATH`
3. Restart your terminal

## Step-by-Step Setup

### 1. Create the directory structure

Run the init script from any location:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File "C:\VSCode\Templates\scripts\Init-TemplatesRepo.ps1"
```

This will:
- Create `.gitignore`, `README.md`
- Create a sample `.code-workspace` template
- Create a sample VS Code profile
- Initialize the git repository
- Make the first commit: "Initial commit: templates repo"
- Install the pre-commit hook

### 2. Launch the Workspace Manager

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File "C:\VSCode\Templates\scripts\WorkspaceManager.ps1"
```

You will see an interactive menu:

```
=== VS Code Workspace Manager ===
1) Check VS Code settings.json
2) New workspace template
3) Save workspace template
4) Set DeepSeek BYOK
5) Set Empty Workspace Trust
6) Open workspace
7) Profiles management
8) Init repo
0) Exit
```

### 3. Verify the Pre-commit Hook

Create a test file with a fake secret:

```powershell
echo "password = test123" | Out-File -FilePath "C:\VSCode\Templates\test-secret.txt" -Encoding UTF8
cd C:\VSCode\Templates
git add test-secret.txt
git commit -m "test"
```

The commit should be blocked. Remove the test file afterwards:

```powershell
Remove-Item "C:\VSCode\Templates\test-secret.txt" -Force
```

### 4. Verify CI Workflow (optional)

Install [act](https://github.com/nektos/act) to run GitHub Actions locally:

```powershell
act -W .github/workflows/validate.yml
```
