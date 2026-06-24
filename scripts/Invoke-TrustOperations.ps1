# Invoke-TrustOperations.ps1
# BYOK and workspace trust management functions for WorkspaceManager.ps1
# Dot-sourced from WorkspaceManager.ps1 — uses its $MetaDir

function Set-DeepSeekBYOK {
    Write-Host "`n=== Set DeepSeek BYOK ===`n" -ForegroundColor Cyan
    $byokPath = Join-Path $MetaDir "deepseek-byok.json"

    Write-Host "BYOK stores only metadata and instructions — no real keys are saved."
    Write-Host "See docs\BYOK-GUIDE.md for replacing the placeholder with real KMS calls."
    Write-Host ""

    if (Test-Path $byokPath) {
        $current = Get-Content $byokPath -Raw -Encoding UTF8 | ConvertFrom-Json
        Write-Host "Current status: $($current.status)"
        Write-Host "Current provider: $($current.provider)"

        $update = Read-Host "Update BYOK metadata? (y/n)"
        if ($update -ne 'y') { return }
    }

    $provider = Read-Host "Enter KMS provider (azure-keyvault / aws-kms / hashicorp-vault / placeholder)"
    if ([string]::IsNullOrWhiteSpace($provider)) { $provider = "placeholder" }

    $keyRef = Read-Host "Enter key reference URL/ARN/path (NOT the key itself)"

    $byok = @{
        version = "1.0"
        provider = $provider
        status = if ($provider -eq "placeholder") { "placeholder" } else { "configured" }
        createdAt = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        keyReference = $keyRef
        notes = "Replace this placeholder with real KMS integration. See docs/BYOK-GUIDE.md"
        kmsInstructions = @{
            description = "This file contains metadata only. Do NOT store real keys here."
            azureKeyVault = @{ command = 'az keyvault show --vault-name <your-vault> --name deepseek-key --query value -o tsv' }
            awsKms = @{ command = 'aws kms decrypt --key-id alias/deepseek --ciphertext-blob fileb://encrypted-key.bin --output text --query Plaintext' }
            hashicorpVault = @{ command = 'vault kv get -field=key <path>/deepseek' }
        }
    }

    $byok | ConvertTo-Json -Depth 4 | Set-Content -Path $byokPath -Encoding UTF8 -NoNewline
    Write-Host "[OK] BYOK metadata saved to: $byokPath" -ForegroundColor Green
    Write-Host "[WARNING] This file is in .gitignore — do NOT commit real keys." -ForegroundColor Yellow
    Pause
}

function Set-EmptyWorkspaceTrust {
    Write-Host "`n=== Set Empty Workspace Trust ===`n" -ForegroundColor Cyan
    $trustPath = Join-Path $MetaDir "trust.json"

    $current = @{ emptyWorkspaceTrust = $false }
    if (Test-Path $trustPath) {
        $current = Get-Content $trustPath -Raw -Encoding UTF8 | ConvertFrom-Json
    }

    Write-Host "Current setting: emptyWorkspaceTrust = $($current.emptyWorkspaceTrust)"
    $toggle = Read-Host "Toggle? (y/n)"
    if ($toggle -eq 'y') {
        $current.emptyWorkspaceTrust = -not $current.emptyWorkspaceTrust
        $current.version = "1.0"
        $current | ConvertTo-Json -Depth 2 | Set-Content -Path $trustPath -Encoding UTF8 -NoNewline
        Write-Host "[OK] emptyWorkspaceTrust set to: $($current.emptyWorkspaceTrust)" -ForegroundColor Green
    }
    Pause
}
