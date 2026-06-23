# Recommendations — VS Code Workspace Manager

Best practices for workspace management, security, DeepSeek, and team workflows.

---

## Workspace Trust Recommendations

| # | Recommendation | Why |
|---|---------------|-----|
| 1 | **Trust parent folders, not individual repos** | Clone under `C:\TrustedRepos\` and trust once. All subfolders inherit. |
| 2 | **Keep untrusted repos separate** | Use `C:\ForEvaluation\` for unfamiliar code. Each gets a trust prompt. |
| 3 | **Never trust before reviewing** | Open in Restricted Mode first. Review code. Then trust. |
| 4 | **Empty windows: false for shared machines** | `security.workspace.trust.emptyWindow: false` on CI/build servers. |
| 5 | **Override extension trust sparingly** | Only for well-known publishers. Check changelogs first. |
| 6 | **Record trust decisions in meta/trust.json** | Team visibility. Audit trail. Rationale for each decision. |

### Trust Decision Flowchart

```
Open folder in VS Code
        │
        ▼
  Is parent folder trusted?
     │ Yes          │ No
     ▼              ▼
  ✅ Trusted    Is folder in meta/trust.json?
  (no prompt)      │ Yes (trusted)   │ Yes (untrusted)   │ No
                   ▼                 ▼                   ▼
               ✅ Trusted        🔴 Restricted        Show trust
               (no prompt)         Mode              prompt dialog
                                                          │
                                              ┌───────────┴───────────┐
                                              ▼                       ▼
                                        "Yes, I trust"           "No, don't trust"
                                              │                       │
                                              ▼                       ▼
                                        ✅ Trusted              🔴 Restricted
                                        Record in                Mode
                                        meta/trust.json
```

---

## Security Recommendations

| # | Recommendation | Implemented by |
|---|---------------|---------------|
| 1 | **Pre-commit hook always active** | `.git/hooks/pre-commit` — scans for secrets |
| 2 | **CI validates every push** | `.github/workflows/validate.yml` |
| 3 | **BYOK: metadata only, never keys** | `meta/deepseek-byok.json` in `.gitignore` |
| 4 | **Rotate exposed secrets immediately** | KMS provider rotation + `git reset` |
| 5 | **Review `.gitignore` quarterly** | Check no new secret-file patterns emerged |
| 6 | **Limit `--no-verify` usage** | Only for documented false positives (docs mentioning "password") |
| 7 | **Audit `meta/trust.json` monthly** | Remove stale entries, verify rationales |

### Defense-in-Depth Layers

```
Layer 1: .gitignore     — excludes known secret files
Layer 2: pre-commit     — blocks secrets in staged files
Layer 3: CI workflow    — validates JSON + scans all files
Layer 4: BYOK design    — metadata-only, real keys in KMS
Layer 5: Workspace Trust — Restricted Mode for unknown code
```

---

## DeepSeek Recommendations

| # | Recommendation | Config |
|---|---------------|--------|
| 1 | **Flash for daily, Pro for planning** | `default_model = "deepseek-flash"` |
| 2 | **Temperature 0.0 for code** | `temperature = 0.0` |
| 3 | **English reasoning** | `reasoning_language = "en"` |
| 4 | **Compact at 80%** | `compact_ratio = 0.8` |
| 5 | **Pro for review subagents** | `subagent_models = { review = "deepseek-pro" }` |
| 6 | **Max effort for security reviews** | `subagent_efforts = { security_review = "max" }` |
| 7 | **Use structured prompts** | Goal → steps → constraints → stop condition |

Full guide: [`docs/DEEPSEEK-RECOMMENDATIONS.md`](./docs/DEEPSEEK-RECOMMENDATIONS.md)

---

## Workspace Template Recommendations

| # | Recommendation | Example |
|---|---------------|---------|
| 1 | **One template per project type** | `python-api.code-workspace`, `react-frontend.code-workspace` |
| 2 | **Use variables for portability** | `${PROJECT_NAME}`, `${GIT_REMOTE}` |
| 3 | **Include recommended extensions** | Helps new team members discover tooling |
| 4 | **Keep settings minimal in templates** | Heavy settings → profiles. Light settings → templates. |
| 5 | **Version templates with semver** | Tag releases: `v1.0.0`, `v1.1.0` |
| 6 | **Multi-root for monorepos** | Separate `src/`, `docs/`, `tests/` as roots |

---

## Profile Recommendations

| # | Recommendation | Why |
|---|---------------|-----|
| 1 | **One profile per language stack** | `python-ml`, `node-web`, `rust-systems` |
| 2 | **Export after every significant config change** | Profiles are snapshots — keep them fresh |
| 3 | **Bulk export monthly** | `Export-AllProfiles` → `exports/profiles-{date}/` |
| 4 | **Assign profiles to templates** | Saves `meta/<template>.meta.json` association |
| 5 | **Profile names: lowercase, kebab-case** | `python-ml`, `node-fullstack`, `go-backend` |

---

## Team Workflow Recommendations

| # | Practice | Detail |
|---|----------|--------|
| 1 | **One shared template repo** | Clone from remote. Everyone syncs via `git pull`. |
| 2 | **Review template changes in PRs** | Templates affect everyone — treat them like code. |
| 3 | **Document trust decisions** | `meta/trust.json` with rationale. Team knows what's trusted and why. |
| 4 | **Onboard in 5 minutes** | New team member: clone → `Init-TemplatesRepo.ps1` → `ONBOARDING.md` → productive. |
| 5 | **Profile snapshots for onboarding** | New hire imports `profiles/python-ml.json` → instant IDE setup. |
| 6 | **CI must pass before merge** | JSON lint + secrets scan gate every PR. |

---

## File Organization Recommendations

```
C:\VSCode\Templates\
├── templates/
│   ├── python-api.code-workspace
│   ├── react-frontend.code-workspace
│   └── monorepo-fullstack.code-workspace
├── profiles/
│   ├── python-ml.json
│   ├── node-fullstack.json
│   └── rust-systems.json
├── meta/
│   ├── trust.json
│   ├── python-api.meta.json
│   ├── react-frontend.meta.json
│   └── deepseek-byok.json
```

---

## Quick Decision Matrix

| Situation | Action |
|-----------|--------|
| New project, unsure about trust | Open in Restricted Mode → review → trust → add to `meta/trust.json` |
| Want to share IDE setup with team | Export profile → commit to `profiles/` → assign to template |
| Switching between Python and Node projects | Switch profiles: `code --profile python-ml` or `code --profile node-fullstack` |
| Accidentally committed a secret | Rotate key in KMS → `git reset HEAD~1` → force push |
| Pre-commit blocks a doc edit | `git commit --no-verify` (only if false positive) |
| Template doesn't fit new project | Create a new one with `New-WorkspaceTemplate` → variable substitution handles the rest |

---

## Terminal Configuration Recommendations

### Choosing a Default Profile

| Use Case | Recommended Profile | Rationale |
|----------|-------------------|-----------|
| Daily development | **PowerShell 7 (full)** | Full profile with modules, PSReadLine, custom prompts |
| Quick commands / scripts | **PowerShell 7 (fast)** | `-NoProfile` skips startup, launches instantly |
| POSIX / git workflows | **Git Bash** | Native bash experience, git aliases |
| Legacy / batch files | **Command Prompt** | `cmd.exe` compatibility |
| Linux development | **WSL (Ubuntu)** | Full Linux environment on Windows |

### Automation Profile

Tasks and debug features should use a separate profile to avoid loading heavy shell startup scripts:

```json
"terminal.integrated.automationProfile.windows": {
  "path": "pwsh.exe",
  "args": ["-NoProfile", "-Command"]
}
```

This is already pre-configured in the sample workspace.

### Shell Integration

Always keep shell integration enabled — it powers command decorations, sticky scroll, IntelliSense, and quick fixes:

```json
"terminal.integrated.shellIntegration.enabled": true,
"terminal.integrated.shellIntegration.decorationsEnabled": "both",
"terminal.integrated.shellIntegration.showCommandGuide": true,
"terminal.integrated.stickyScroll.enabled": true
```

### Manual Shell Integration Installation

If automatic injection fails (e.g., sub-shells, SSH, complex setups), add to your PowerShell profile (`code $Profile`):

```powershell
if ($env:TERM_PROGRAM -eq "vscode") {
  . "$(code --locate-shell-integration-path pwsh)"
}
```

---

## Task Automation Recommendations

### Task Structure

Every task should include:

- **`label`** — Unique, descriptive name (e.g., `"Validate All JSON"`)
- **`detail`** — One-line description shown in the task picker (e.g., `"Recursively validates all .json files"`)
- **`type`** — `"shell"` for PowerShell commands, `"process"` for binaries
- **`group`** — `"build"` (Ctrl+Shift+B), `"test"` (Run Test Task), or omit for general tasks

### Compound Tasks with `dependsOn`

Chain related tasks to run them in sequence with a single command:

```json
{
  "label": "Full Validation",
  "dependsOn": ["Validate All JSON", "Validate This Workspace JSON"],
  "group": "test"
}
```

This runs each dependency in order and reports individual pass/fail.

### When to Use Each Task Trigger

| Trigger | Task Group | Best For |
|---------|-----------|----------|
| `Ctrl+Shift+B` | `"build"` | Compilation, bundling, type-checking |
| `Run Test Task` | `"test"` | Validation, linting, audit checks |
| `Terminal → Run Task` | (none) | One-off scripts, manager launch, diagnostics |

### Running Tasks Without the VS Code UI

For headless or CI environments, use the standalone run scripts:

```powershell
# Same as "Validate All JSON" + "Validate All .code-workspace" tasks
pwsh -NoProfile -File "scripts\Run-Validate.ps1"

# Same as full validation + secret scan
pwsh -NoProfile -File "scripts\Run-Checks.ps1"
```
