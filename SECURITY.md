# Security — VS Code Workspace Manager

This project manages workspace templates, profiles, and BYOK metadata. Security is a first-class concern.

## Scope

This file covers:
- **VS Code Workspace Trust** — Restricted Mode and trust boundaries
- **BYOK (Bring Your Own Key)** — Key metadata management for DeepSeek
- **Secret leakage prevention** — Git hooks and CI scanning
- **Dependency security** — PowerShell scripts, GitHub Actions

---

## Reporting a Vulnerability

If you discover a security issue:

1. **Do NOT** open a public GitHub issue.
2. Contact the repository owner directly via email or internal ticket.
3. Provide a clear description, steps to reproduce, and suggested fix (if known).

We aim to acknowledge within 48 hours and issue a fix within 7 days.

---

## Security Architecture

```
pre-commit hook → blocks secrets locally before commit
        ↓
git push → GitHub CI validates JSON + scans secrets
        ↓
.gitignore → excludes BYOK files, .vscode/, workspaceStorage/
```

## Key Rules

### Secrets
- **Never** store real API keys, tokens, or passwords in this repository.
- `meta/deepseek-byok.json` and `meta/deepseek-keys.json` store **metadata only** — key references, KMS commands, and instructions.
- Both files are listed in `.gitignore` and blocked by the pre-commit hook.
- The pre-commit hook (`scripts/Init-TemplatesRepo.ps1` installs it) blocks any file matching `password|secret|api[_-]?key|token|private_key`.

### BYOK (Bring Your Own Key)
- Only key **references** (URLs, ARNs, paths) are stored — never the keys themselves.
- At runtime, retrieve the real key from your KMS provider:
  - **Azure Key Vault:** `az keyvault secret show --vault-name <vault> --name deepseek-key --query value -o tsv`
  - **AWS KMS:** `aws kms decrypt --key-id alias/deepseek --ciphertext-blob fileb://encrypted-key.bin --output text --query Plaintext`
  - **HashiCorp Vault:** `vault kv get -field=key secret/deepseek`

### VS Code Workspace Trust
- **Restricted Mode** blocks AI agents, terminals, tasks, debugging, and untrusted extensions.
- Never trust a workspace with un-reviewed code before running agents.
- Trust parent folders to inherit trust across subfolders.
- `meta/trust.json` records trust decisions for team visibility (VS Code's actual trust DB is internal).

### CI/CD
- The GitHub Actions workflow (`validate.yml`) runs JSON lint and secrets scan on every push.
- If a secret pattern is detected, the CI job fails and the commit is flagged.

---

## Hardening Recommendations

| Action | Priority | Details |
|--------|----------|---------|
| Rotate any leaked keys immediately | **Critical** | Use KMS to rotate, then update key references. |
| Review `.gitignore` before adding new files | High | Ensure no new file types could leak secrets. |
| Run `act -W .github/workflows/validate.yml` locally | Medium | Catch issues before pushing. |
| Keep `security.workspace.trust.enabled: true` | Medium | Disabling trust removes VS Code's security boundary. |

---

## References

- `docs/WORKSPACE-TRUST.md` — Complete guide to VS Code Workspace Trust
- `docs/BYOK-GUIDE.md` — BYOK setup and KMS provider comparison
- `docs/DEEPSEEK-RECOMMENDATIONS.md` — DeepSeek security best practices
- `.github/workflows/validate.yml` — CI security scanning
