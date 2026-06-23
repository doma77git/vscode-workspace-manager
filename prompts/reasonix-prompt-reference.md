# Reasonix Prompt Reference — Quick Snippets

Copy-paste these prompts into Reasonix. Replace `{placeholders}` with your values.

---

## goal

Set an autonomous goal the agent pursues across turns until done.

```
Goal: {one-line goal description}

The agent should:
- {step 1}
- {step 2}
- {step 3}

Stop when: {completion condition}
```

**Example:**
```
Goal: Add dark mode toggle to settings page.
- Add state to React context
- Wire toggle component
- Update CSS variables
Stop when: toggle flips all components and passes lint.
```

---

## memo

Save, search, read, or delete durable project memories.

### Save a memory
```
Remember: {fact title}
Body: {detailed fact, include "Why:" and "How to apply:" lines}
Type: user | feedback | project | reference
```

### Search memories
```
Search memories for: {query}
```

### Read a memory
```
Read memory: {memory-name-slug}
```

### Delete a memory
```
Forget memory: {memory-name-slug}
```

**Example:**
```
Remember: prefers-tabs-over-spaces
Body: Set editor.tabSize=4, editor.insertSpaces=false in all workspace templates.
Why: Team convention.
How to apply: Always use tabs in generated configs. Check .editorconfig.
Type: project
```

---

## project

Switch context or describe the current project.

```
This project is: {one-paragraph description}
Stack: {languages, frameworks}
Entry point: {main file or command}
Build: {build command}
Test: {test command}
Conventions: {naming, formatting, patterns}
```

**Example:**
```
This project is: A VS Code workspace template manager on Windows.
Stack: PowerShell 7, Git, VS Code CLI, GitHub Actions.
Entry point: scripts/WorkspaceManager.ps1
Build: none (scripts only)
Test: pwsh -NoProfile -File scripts/WorkspaceManager.ps1
Conventions: UTF-8 no BOM, PowerShell 7 compatible, no secrets in repo.
```

---

## Plan

Read-only exploration before making changes. The agent surveys the codebase and presents a layered plan for approval.

```
Plan task: {what to build or change}
Constraints: {must-haves, must-nots}
Target files: {directories or files to touch}
Output: {what the plan should cover}
```

**Example:**
```
Plan task: Add a new command "Export all profiles" to WorkspaceManager.ps1.
Constraints: Must use existing functions, no new dependencies, UTF-8 output.
Target files: scripts/WorkspaceManager.ps1, docs/WORKFLOW.md.
Output: Phased plan with sub-steps for code change, doc update, and test.
```

---

## update

Refresh, modernize, or upgrade an existing component.

```
Update: {what to update}
From: {current state or version}
To: {target state or version}
Keep: {things that must not change}
```

**Example:**
```
Update: scripts/WorkspaceManager.ps1 menu numbering
From: 1-8 with 0 to exit
To: 1-9 with Q to quit
Keep: All function names, variable names, profile assignment logic.
```

---

## init

Bootstrap or re-generate the project's AGENTS.md (project context file for Reasonix).

```
Init this project.
Stack: {languages and tools}
Build command: {how to build}
Test command: {how to test}
Conventions: {key rules}
```

**Example:**
```
Init this project.
Stack: TypeScript, React, Vite, Tailwind.
Build command: npm run build
Test command: npm test
Conventions: Prettier default config, no any types, colocate tests.
```

---

## Quick Combinations

### Start a new feature (plan → goal)
```
Plan task: Add export-all-profiles to WorkspaceManager.ps1.
→ approve plan
Goal: Implement the approved plan for export-all-profiles.
```

### Save context for next session (memo + project)
```
Remember: workspace-manager-stack
Body: Stack: PowerShell 7, Git, VS Code CLI. Scripts at C:\VSCode\Templates\scripts. No external dependencies. UTF-8 no BOM. pwsh -NoProfile -ExecutionPolicy Bypass.
Type: project

This project is: VS Code Workspace Manager — templates, profiles, BYOK, trust.
```

### Bootstrap a new repo (init → project → goal)
```
Init this project.
→ then:
This project is: {description from generated AGENTS.md}
→ then:
Goal: {first task based on the project structure}
```
