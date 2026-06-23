---
name: deepseek-byok
description: Manage DeepSeek BYOK metadata — store KMS instructions and key references without committing real secrets. Includes security verification and CI integration.
type: project
runAs: inline
allowedTools: [read_file, write_file, bash, ask]
---

# DeepSeek BYOK Manager

Manage Bring-Your-Own-Key metadata for DeepSeek authentication. This skill stores **only metadata and KMS instructions** — never real keys.

## When to use
- User says "set up DeepSeek", "configure BYOK", "deepseek keys", "KMS for DeepSeek"
- User needs to switch KMS providers (Azure Key Vault ↔ AWS KMS ↔ HashiCorp Vault)
- User needs to check BYOK status or verify security

## Steps

### 1. Locate the BYOK metadata file
Read `meta/deepseek-byok.json`. If missing, create the placeholder:
```json
{
  "version": "1.0",
  "provider": "placeholder",
  "status": "placeholder",
  "createdAt": "",
  "keyReference": "",
  "kmsInstructions": {
    "description": "Replace with real KMS integration. See docs/BYOK-GUIDE.md",
    "azureKeyVault": { "command": "az keyvault secret show --vault-name <vault> --name deepseek-key --query value -o tsv" },
    "awsKms": { "command": "aws kms decrypt --key-id alias/deepseek --ciphertext-blob fileb://encrypted-key.bin --output text --query Plaintext" },
    "hashicorpVault": { "command": "vault kv get -field=key secret/deepseek" }
  }
}
```

### 2. Determine the user's KMS provider
Ask if not specified:
- **azure-keyvault** — Azure Key Vault (recommended for Azure workloads)
- **aws-kms** — AWS KMS (recommended for AWS workloads)
- **hashicorp-vault** — HashiCorp Vault (recommended for multi-cloud / on-prem)
- **placeholder** — Keep as metadata-only (no real KMS yet)

### 3. Collect key reference (NOT the key itself)
Prompt for:
- Key reference URL, ARN, or path (e.g., `https://myvault.vault.azure.net/secrets/deepseek-key`)
- Do NOT accept or store the actual key/secret value

### 4. Write the metadata
Update `meta/deepseek-byok.json` with:
- `provider` set to the chosen KMS
- `status` set to `"configured"` (or `"placeholder"` if no provider chosen)
- `keyReference` set to the user's reference
- `createdAt` set to current timestamp

### 5. Verify security posture
Run after configuring BYOK:
```powershell
make checks          # Verify no secrets in the repo
make test            # Verify nothing is broken
```

Check that `.gitignore` still excludes `deepseek-byok.json` and `deepseek-keys.json`.

### 6. Confirm
Tell the user:
- Where the metadata was saved
- That `.gitignore` excludes this file from git
- How to retrieve the key at runtime (link to `docs/BYOK-GUIDE.md`)
- That scheduled checks will catch any secret leaks weekly

## Security rules
- **NEVER** store real keys, tokens, or secrets in `meta/deepseek-byok.json`
- **NEVER** accept a raw API key from the user — only key references
- The file is in `.gitignore` — verify before committing anything
- If a user pastes a real key, stop and warn them. Do not write it to disk.
- Run `make checks` after any BYOK changes
- Review `SECURITY.md` for the full security policy
