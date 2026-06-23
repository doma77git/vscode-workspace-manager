# DeepSeek BYOK Guide

## Overview

The DeepSeek BYOK (Bring Your Own Key) system stores **metadata only** — no real encryption keys, tokens, or secrets are kept in the repository. The file `meta\deepseek-byok.json` is a placeholder that describes what key material is needed and how to obtain it from your KMS provider.

## Placeholder Structure

The placeholder in `meta\deepseek-byok.json` contains:
- **version**: Schema version
- **provider**: KMS provider name (or "placeholder")
- **status**: Always "placeholder" until you replace it
- **kmsInstructions**: Human-readable steps for obtaining the real key

## Replacing with Real KMS

Choose your provider and follow the corresponding instructions.

### Azure Key Vault

```powershell
# Login to Azure
az login

# Retrieve the key from Key Vault
az keyvault secret show --vault-name <your-vault> --name deepseek-key --query value -o tsv

# Store it securely (do NOT commit to repo)
```

### AWS KMS

```powershell
# Retrieve the key
aws kms decrypt --key-id alias/deepseek --ciphertext-blob fileb://encrypted-key.bin --output text --query Plaintext

# Store it securely (do NOT commit to repo)
```

### HashiCorp Vault

```powershell
# Retrieve the key
vault kv get -field=key secret/deepseek

# Store it securely (do NOT commit to repo)
```

## Using the BYOK Script

Once you have configured your KMS provider:

1. Run the Workspace Manager
2. Select **4) Set DeepSeek BYOK**
3. Follow the interactive prompts
4. The script stores the **metadata** (not the key) in `meta\deepseek-byok.json`

## Security Rules

- **Never commit** `meta\deepseek-byok.json` or `meta\deepseek-keys.json` — both are in `.gitignore`
- Real keys should only exist in your KMS provider and in-memory at runtime
- The pre-commit hook blocks files containing `password`, `secret`, `api_key`, `token`, or `private_key`
- CI workflow fails if any of these patterns are detected
