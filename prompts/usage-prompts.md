# Usage Prompts — Ready-to-Use Snippets

Copy-paste these into Reasonix. Replace `{placeholders}` with your values.

---

## Create a New Template

```
Create a new VS Code workspace template at C:\VSCode\Templates\templates\my-project.code-workspace.
Use multi-root with folders: ["src", "docs"].
Set name to "my-project" and add Python and GitLens extensions.
Replace ${PROJECT_NAME} with "my-project" and ${GIT_REMOTE} with "https://github.com/user/my-project.git".
```

---

## Import a Profile

```
Import the VS Code profile from C:\VSCode\Templates\profiles\python-profile.json.
Assign this profile to the template "sample-project.code-workspace".
Save the association to meta\sample-project.meta.json.
```

---

## Set Up BYOK with Azure Key Vault

```
Set up DeepSeek BYOK in C:\VSCode\Templates\meta\deepseek-byok.json.
Use Azure Key Vault as the provider.
Store the vault name "my-keyvault" and secret name "deepseek-key" in the metadata.
Do NOT store any real keys or secrets.
```

---

## Open a Workspace with a Profile

```
List all available templates in C:\VSCode\Templates\templates.
Open "sample-project.code-workspace" with the profile assigned in meta\sample-project.meta.json.
Use code --profile to launch.
```

---

## Check Settings and Validate

```
Run Check-VSCodeSettings to inspect %APPDATA%\Code\User\settings.json.
Validate all .code-workspace files in C:\VSCode\Templates\templates for valid JSON.
Report any issues.
```

---

## Initialize the Repository

```
Run Init-TemplatesRepo.ps1 to set up the git repository at C:\VSCode\Templates.
Create .gitignore, sample template, sample profile, install pre-commit hook, and make the initial commit.
```

---

## Scan a Project for Recommended Profile

```
Scan C:\Projects\my-python-app for project indicators.
Detect the stack (Python, Node.js, Go, etc.) from files like pyproject.toml, package.json, go.mod.
Suggest the best-matching profile from profiles/.
Assign the profile if the user confirms.
```

---

## Configure Terminal Profiles

```
Read templates/sample-project.code-workspace.
Add a new terminal profile "PowerShell Debug" with path "pwsh.exe" and args ["-NoExit", "-Command", "Write-Host 'Debug mode'"].
Set terminal.integrated.defaultProfile.windows to "PowerShell Debug".
Validate the workspace JSON after the change.
```

---

## Add VS Code Tasks

```
Add a build task to templates/sample-project.code-workspace:
- Label: "Build Project"
- Command: "pwsh"
- Args: ["-NoProfile", "-Command", "Write-Host 'Building...'"]
- Group: "build"
- Detail: "Compiles the project"

Add a test task:
- Label: "Run Tests"
- Command: "pwsh"
- Args: ["-NoProfile", "-File", "scripts/Run-Tests.ps1"]
- Group: "test"

Add a compound task "Full CI" with dependsOn: ["Build Project", "Run Tests"].
```

---

## Run Validation and Tests

```
Run scripts/Run-Validate.ps1 — report any invalid JSON or workspace files.
Run scripts/Run-Checks.ps1 — report any secrets detected or validation failures.
Run scripts/Run-Tests.ps1 — report PowerShell syntax errors and JSON syntax errors.
If any fail, fix the issues and re-run.
```

---

## Self-Update the Manager

```
Run scripts/Update-Self.ps1 -Force to pull the latest version.
After updating, run scripts/Run-Tests.ps1 to verify nothing broke.
Report the old and new version from CHANGELOG.md.
```

---

## Open a Project with Auto-Detected Profile

```
Run scripts/Open-WithProfile.ps1 for C:\Projects\my-go-service.
It should detect go.mod and suggest the "go-dev" profile.
Open the project in VS Code with that profile.
```

---

## Full Health Check

```
Run the complete health check:
1. scripts/Run-Tests.ps1 (PowerShell + JSON syntax)
2. scripts/Run-Checks.ps1 (validation + secret scan)
3. make doctor (prerequisites: pwsh, code, git, act)
Report a summary: total passed, failed, warnings.
```

---

## Create a Release

```
Review CHANGELOG.md for the latest version.
Bump the version number in WorkspaceManager.ps1 (Invoke-About function).
Run scripts/Run-Tests.ps1 — must be all green.
Run scripts/Run-Checks.ps1 — must be all green.
Commit with message "Release v{VERSION}".
Tag: git tag v{VERSION}.
Push: git push && git push --tags.
```
