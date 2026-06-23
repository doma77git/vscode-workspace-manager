# Architecture & UML — VS Code Workspace Manager

## 1. System Architecture (Component Diagram)

```mermaid
graph TB
    subgraph User["👤 User"]
        CLI["pwsh Terminal"]
        VSCODE["VS Code IDE"]
    end

    subgraph Manager["VS Code Workspace Manager"]
        WM["WorkspaceManager.ps1<br/>Interactive Menu"]
        INIT["Init-TemplatesRepo.ps1<br/>One-time Setup"]
        HOOK["pre-commit<br/>Git Hook"]
    end

    subgraph Storage["C:\\VSCode\\Templates"]
        direction TB
        T["templates/<br/>.code-workspace"]
        P["profiles/<br/>.json exports"]
        M["meta/<br/>BYOK + Trust"]
        D["docs/<br/>Guides"]
        PR["prompts/<br/>Reasonix snippets"]
        S["skills/<br/>Custom Reasonix skills"]
    end

    subgraph External["External Systems"]
        KMS["KMS Provider<br/>Azure/AWS/Vault"]
        GH["GitHub<br/>CI + Remote"]
        RSNX["Reasonix<br/>AI Agent"]
    end

    subgraph CI[".github/workflows"]
        LINT["JSON Lint"]
        SCAN["Secrets Scan"]
    end

    CLI -->|"pwsh -File"| WM
    CLI -->|"pwsh -File"| INIT
    VSCODE -->|"code --profile"| WM
    WM -->|"reads/writes"| T
    WM -->|"reads/writes"| P
    WM -->|"reads/writes"| M
    WM -->|"calls"| INIT
    WM -->|"opens"| VSCODE
    INIT -->|"creates"| HOOK
    HOOK -->|"blocks secrets"| GH
    GH -->|"triggers"| CI
    LINT -->|"validates"| T
    SCAN -->|"scans"| T
    M -->|"key reference"| KMS
    PR -->|"loaded by"| RSNX
    S -->|"installed into"| RSNX

    style User fill:#1a1a2e,stroke:#e94560,color:#eee
    style Manager fill:#16213e,stroke:#0f3460,color:#eee
    style Storage fill:#0f3460,stroke:#e94560,color:#eee
    style External fill:#1a1a2e,stroke:#533483,color:#eee
    style CI fill:#16213e,stroke:#0f3460,color:#eee
```

---

## 2. WorkspaceManager Interactive Flow

```mermaid
flowchart TD
    START([Start WorkspaceManager.ps1]) --> SHOW[Show Menu: 0-9]
    
    SHOW -->|"1"| CS[Check-VSCodeSettings<br/>code CLI · PS version · file counts]
    SHOW -->|"2"| NT[New-WorkspaceTemplate<br/>interactive var replacement]
    SHOW -->|"3"| ST[Save-WorkspaceTemplate<br/>timestamped copy]
    SHOW -->|"4"| BYOK[Set-DeepSeekBYOK<br/>KMS provider · metadata only]
    SHOW -->|"5"| TRUST[Set-EmptyWorkspaceTrust<br/>toggle trust.json]
    SHOW -->|"6"| OPEN[Open-Workspace<br/>list templates · code --profile]
    SHOW -->|"7"| PROF[Profiles Management]
    SHOW -->|"8"| REPO[Init-TemplatesRepo.ps1<br/>git init · commit · hook]
    SHOW -->|"9"| SEARCH[Search-Templates<br/>name · content · meta]
    SHOW -->|"0"| EXIT([Exit])
    
    PROF --> PROFLIST[List Profiles]
    PROF --> PROFIMP[Import Profile<br/>from .json]
    PROF --> PROFEXP[Export Profile<br/>from VS Code]
    PROF --> PROFEXPALL[Export-AllProfiles<br/>bulk archive + manifest]
    
    CS --> SHOW
    NT --> SHOW
    ST --> SHOW
    BYOK --> SHOW
    TRUST --> SHOW
    OPEN --> SHOW
    PROFLIST --> SHOW
    PROFIMP --> SHOW
    PROFEXP --> SHOW
    PROFEXPALL --> SHOW
    REPO --> SHOW
    SEARCH --> SHOW

    style START fill:#0f3460,stroke:#e94560,color:#eee
    style EXIT fill:#0f3460,stroke:#e94560,color:#eee
    style SHOW fill:#16213e,stroke:#0f3460,color:#eee
```

---

## 3. Template Lifecycle (State Machine)

```mermaid
stateDiagram-v2
    [*] --> Created : New-WorkspaceTemplate
    [*] --> Imported : Save-WorkspaceTemplate
    Created --> Modified : User edits .code-workspace
    Imported --> Modified : User edits .code-workspace
    Modified --> Committed : git commit
    Committed --> Modified : Further edits
    Created --> Opened : Open-Workspace
    Imported --> Opened : Open-Workspace
    Modified --> Opened : Open-Workspace
    Committed --> Opened : Open-Workspace
    Opened --> [*] : VS Code session ends
```

---

## 4. Security Chain (Sequence Diagram)

```mermaid
sequenceDiagram
    actor Dev as 👤 Developer
    participant WM as WorkspaceManager.ps1
    participant FS as Filesystem
    participant Hook as pre-commit
    participant GH as GitHub
    participant CI as CI Workflow
    participant KMS as KMS Provider

    Note over Dev,FS: BYOK Setup
    Dev->>WM: Set DeepSeek BYOK
    WM->>FS: Write meta/deepseek-byok.json<br/>(metadata only, no key)
    FS-->>WM: Saved
    WM-->>Dev: Key reference stored

    Note over Dev,KMS: Runtime Key Retrieval
    Dev->>KMS: CLI: az keyvault / aws kms / vault
    KMS-->>Dev: Real key (in-memory only)

    Note over Dev,CI: Commit Flow
    Dev->>FS: git commit
    FS->>Hook: Trigger pre-commit
    alt Secret detected
        Hook-->>Dev: ❌ COMMIT BLOCKED
    else Clean
        Hook-->>FS: ✅ Pass
        FS->>GH: Push
        GH->>CI: Trigger validate.yml
        CI->>CI: JSON Lint
        CI->>CI: Secrets Scan
        CI-->>GH: ✅ / ❌
    end
```

---

## 5. File Dependency Map

```mermaid
graph LR
    subgraph Config["Configuration"]
        GITIGNORE[".gitignore"]
        GITATTR[".gitattributes"]
        DEPLOY["deploy-instructions.txt"]
    end

    subgraph Core["Scripts"]
        WM["WorkspaceManager.ps1"]
        INIT["Init-TemplatesRepo.ps1"]
    end

    subgraph Data["Data Files"]
        TPL["templates/*.code-workspace"]
        PROF["profiles/*.json"]
        META["meta/*.json"]
    end

    subgraph Docs["Documentation"]
        README["README.md"]
        ONBOARD["ONBOARDING.md"]
        CHLOG["CHANGELOG.md"]
        DSETUP["docs/SETUP.md"]
        DWF["docs/WORKFLOW.md"]
        DBYOK["docs/BYOK-GUIDE.md"]
        DCI["docs/CI-CD.md"]
        DDSR["docs/DEEPSEEK-RECOMMENDATIONS.md"]
        DARCH["docs/ARCHITECTURE.md"]
        PWP["prompts/workspace-manager-prompt.md"]
        PUP["prompts/usage-prompts.md"]
    end

    subgraph Skills["Reasonix Skills"]
        SBYOK["skills/deepseek-byok/SKILL.md"]
        SRSNX["skills/deepseek-reasonix/SKILL.md"]
    end

    subgraph CI_Files["CI/CD"]
        CIF["validate.yml"]
        HOOK["pre-commit"]
    end

    INIT -->|"generates"| GITIGNORE
    INIT -->|"generates"| README
    INIT -->|"generates"| TPL
    INIT -->|"generates"| PROF
    INIT -->|"installs"| HOOK
    WM -->|"reads/writes"| TPL
    WM -->|"reads/writes"| PROF
    WM -->|"reads/writes"| META
    WM -->|"calls"| INIT
    HOOK -->|"blocks"| CIF
    CIF -->|"validates"| TPL
    CIF -->|"validates"| PROF
    CIF -->|"scans"| META
    PWP -->|"describes"| WM
    PUP -->|"references"| WM
    SBYOK -->|"manages"| META
    SRSNX -->|"tunes"| WM
    DARCH -->|"diagrams"| WM
    DARCH -->|"diagrams"| HOOK
    DARCH -->|"diagrams"| CIF
```

---

## 6. Data Structures

### meta/deepseek-byok.json
```json
{
  "version": "1.0",
  "provider": "azure-keyvault | aws-kms | hashicorp-vault | placeholder",
  "status": "configured | placeholder",
  "createdAt": "ISO 8601 timestamp",
  "keyReference": "URL/ARN/path — NOT the key itself",
  "kmsInstructions": {
    "azureKeyVault": { "command": "az keyvault ..." },
    "awsKms": { "command": "aws kms ..." },
    "hashicorpVault": { "command": "vault kv ..." }
  }
}
```

### meta/trust.json
```json
{
  "version": "1.0",
  "emptyWorkspaceTrust": false,
  "updatedAt": "ISO 8601 timestamp"
}
```

### templates/*.code-workspace
```json
{
  "folders": [{ "path": "." }],
  "settings": {},
  "extensions": { "recommendations": [] },
  "name": "${PROJECT_NAME}"
}
```

### profiles/*.json (VS Code Profile Export)
```json
{
  "name": "profile-name",
  "settings": "...",
  "extensions": "...",
  "keybindings": "...",
  "snippets": "..."
}
```

---

## 7. Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| **BYOK stores metadata only** | No real keys on disk. `.gitignore` + pre-commit + CI as defense layers |
| **Separate init script** | One-time setup is idempotent; daily manager is interactive |
| **Template variables `${X}`** | Keeps templates generic; resolved at creation time |
| **Profiles as exported JSON** | VS Code native format; no custom serialization needed |
| **Pre-commit is a shell script** | Works on Windows (git bash) and any POSIX shell |
| **CI uses `ubuntu-latest`** | JSON lint + regex scan are OS-agnostic |
| **Skills are Reasonix-native** | Installable with `Install skill from:` — no custom packaging |
| **Mermaid for diagrams** | Renders in GitHub, VS Code, and any Markdown viewer |
