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
