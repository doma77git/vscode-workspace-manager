# CI/CD Guide

## GitHub Actions Workflow

The file `.github/workflows/validate.yml` runs automatically on every push and pull request.

## Jobs

### 1. JSON Lint
Validates all `.json` and `.code-workspace` files in the repository:
- Checks for valid JSON syntax
- Uses `jq` for parsing
- Fails if any file contains invalid JSON

### 2. Secrets Scan
Scans all files for patterns that might indicate accidental secret commits:
- `password`
- `secret`
- `api_key` / `api-key`
- `token`
- `private_key`

If any match is found, the workflow fails and lists the offending files.

## Running Locally with act

Install [act](https://github.com/nektos/act) and run:

```powershell
act -W .github/workflows/validate.yml
```

This runs the same validation locally before you push.

## Runner

The workflow uses `ubuntu-latest` runner by default — no Windows-specific dependencies needed for JSON linting and regex scanning.
