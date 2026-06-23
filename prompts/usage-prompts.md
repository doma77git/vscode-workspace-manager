# Usage Prompts — Ready-to-Use Snippets

## Create a New Template

```
Create a new VS Code workspace template at C:\VSCode\Templates\templates\my-project.code-workspace.
Use multi-root with folders: ["src", "docs"].
Set name to "my-project" and add Python and GitLens extensions.
Replace ${PROJECT_NAME} with "my-project" and ${GIT_REMOTE} with "https://github.com/user/my-project.git".
```

## Import a Profile

```
Import the VS Code profile from C:\VSCode\Templates\profiles\python-profile.json.
Assign this profile to the template "sample-project.code-workspace".
Save the association to meta\sample-project.meta.json.
```

## Set Up BYOK with Azure Key Vault

```
Set up DeepSeek BYOK in C:\VSCode\Templates\meta\deepseek-byok.json.
Use Azure Key Vault as the provider.
Store the vault name "my-keyvault" and secret name "deepseek-key" in the metadata.
Do NOT store any real keys or secrets.
```

## Open a Workspace with a Profile

```
List all available templates in C:\VSCode\Templates\templates.
Open "sample-project.code-workspace" with the profile assigned in meta\sample-project.meta.json.
Use code --profile to launch.
```

## Check Settings and Validate

```
Run Check-VSCodeSettings to inspect %APPDATA%\Code\User\settings.json.
Validate all .code-workspace files in C:\VSCode\Templates\templates for valid JSON.
Report any issues.
```

## Initialize the Repository

```
Run Init-TemplatesRepo.ps1 to set up the git repository at C:\VSCode\Templates.
Create .gitignore, sample template, sample profile, install pre-commit hook, and make the initial commit.
```
