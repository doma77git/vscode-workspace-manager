# Daily Workflow

## Creating a New Workspace Template

1. Launch the Workspace Manager:
   ```
   pwsh -NoProfile -ExecutionPolicy Bypass -File "C:\VSCode\Templates\scripts\WorkspaceManager.ps1"
   ```

2. Select option **2) New workspace template**

3. Follow the prompts:
   - Enter project name (replaces `${PROJECT_NAME}`)
   - Enter Git remote URL (replaces `${GIT_REMOTE}`)
   - Optionally assign a VS Code profile
   - Choose template type (single-root or multi-root)

4. The template is saved to `templates\` and metadata to `meta\`.

## Saving an Existing Workspace

1. Open your project in VS Code with a `.code-workspace` file

2. In Workspace Manager, select **3) Save workspace template**

3. A timestamped copy is saved to `templates\`.

## Managing Profiles

### Listing profiles
Select **7) Profiles management** → **List** to see all saved profiles.

### Importing a profile
1. Export a profile from VS Code: `Ctrl+Shift+P` → `Profiles: Export Profile`
2. Save the JSON file to `C:\VSCode\Templates\profiles\`
3. In Workspace Manager, select **7) Profiles management** → **Import**

### Exporting a profile
In Workspace Manager, select **7) Profiles management** → **Export** to export the current VS Code profile to `profiles\`.

## Opening a Workspace

1. Select **6) Open workspace**
2. Choose a template from the list
3. Optionally select a profile to apply
4. VS Code opens with: `code --profile <name> <workspace>`

## Managing Trust

### Empty Workspace Trust
Select **5) Set Empty Workspace Trust** to toggle workspace trust in `meta\trust.json`.

### DeepSeek BYOK
Select **4) Set DeepSeek BYOK** to store BYOK metadata. See `docs/BYOK-GUIDE.md` for replacing the placeholder with real KMS calls.

## Template Variables

When creating a template, the following variables are replaced:

| Variable | Description | Example |
|----------|-------------|---------|
| `${PROJECT_NAME}` | Your project name | `my-app` |
| `${GIT_REMOTE}` | Git remote URL | `https://github.com/user/my-app.git` |
