# UML Diagrams — VS Code Workspace Manager

All architecture diagrams in one place. Renders in GitHub, VS Code, and any Mermaid-compatible viewer.

---

## 1. System Architecture

```mermaid
graph TB
    subgraph User["👤 User"]
        CLI["pwsh Terminal"]
        VSCODE["VS Code"]
    end

    subgraph Entry["Entry Points"]
        MENU["WorkspaceManager.ps1<br/>15-option Interactive Menu"]
        MAKE["Makefile<br/>26 targets"]
        NPM["package.json<br/>19 scripts"]
    end

    subgraph Scripts["Scripts Layer (34 scripts)"]
        RUNNERS["🏃 Runners<br/>Run-Validate, Run-Checks, Run-Tests"]
        HELPERS["🔧 Helpers<br/>Helper-Functions"]
        CHECKERS["🔍 Checkers<br/>Check-Environment"]
        LAUNCHERS["🚀 Launchers<br/>Open-WithProfile"]
        BACKUP["💾 Backup<br/>Auto-Backup"]
        SCHEDULE["⏰ Scheduler<br/>Schedule-Tasks"]
        RECOMMEND["💡 Recommender<br/>Recommend-Extensions"]
        UPDATE["🔄 Updater<br/>Update-Self"]
        NAV["🧭 Navigator<br/>Navigate-Project"]
    end

    subgraph Data["Data Layer"]
        T["templates/<br/>.code-workspace"]
        P["profiles/<br/>profile JSON"]
        M["meta/<br/>trust + BYOK"]
    end

    subgraph Security["Security Layer"]
        HOOK["pre-commit hook"]
        CI["CI (3 workflows)"]
        BYOK["BYOK metadata"]
    end

    CLI --> MENU
    CLI --> MAKE
    CLI --> NPM
    MENU --> RUNNERS
    MENU --> HELPERS
    MENU --> CHECKERS
    MENU --> LAUNCHERS
    MENU --> BACKUP
    MENU --> SCHEDULE
    MENU --> RECOMMEND
    MENU --> UPDATE
    MENU --> NAV
    RUNNERS --> T
    RUNNERS --> P
    RUNNERS --> M
    SECURITY --> HOOK
    SECURITY --> CI
    SECURITY --> BYOK

    style User fill:#1a1a2e,stroke:#e94560,color:#eee
    style Entry fill:#16213e,stroke:#0f3460,color:#eee
    style Scripts fill:#0f3460,stroke:#e94560,color:#eee
    style Data fill:#1a1a2e,stroke:#533483,color:#eee
    style Security fill:#16213e,stroke:#ff6b6b,color:#eee
```

---

## 2. Menu Option Flow

```mermaid
flowchart TD
    START([Launch WorkspaceManager.ps1]) --> DASH[Show Dashboard<br/>version, counts, update check]
    DASH --> MENU[Show 15-Option Menu]

    MENU -->|1| CS[Check Settings]
    MENU -->|2| NT[New Template]
    MENU -->|3| ST[Save Template]
    MENU -->|4| BYOK[Set BYOK]
    MENU -->|5| TRUST[Set Trust]
    MENU -->|6| OPEN[Open Workspace]
    MENU -->|7| PROF[Profiles Mgmt]
    MENU -->|8| INIT[Init Repo]
    MENU -->|9| SEARCH[Search Templates]
    MENU -->|10| VAL[Run Validation]
    MENU -->|11| DOCS[Open Docs]
    MENU -->|12| ABOUT[About / Stats]
    MENU -->|13| SCAN[Scan Project]
    MENU -->|14| UPDATE[Check Updates]
    MENU -->|15| SCHED[Schedule Tasks]
    MENU -->|0| EXIT([Exit])

    PROF --> LIST[List Profiles]
    PROF --> IMP[Import Profile]
    PROF --> EXP[Export Profile]
    PROF --> EXPALL[Export All]

    CS --> MENU
    NT --> MENU
    ST --> MENU
    BYOK --> MENU
    TRUST --> MENU
    OPEN --> MENU
    INIT --> MENU
    SEARCH --> MENU
    VAL --> MENU
    DOCS --> MENU
    ABOUT --> MENU
    SCAN --> MENU
    UPDATE --> MENU
    SCHED --> MENU
    LIST --> MENU
    IMP --> MENU
    EXP --> MENU
    EXPALL --> MENU
```

---

## 3. Self-Update Sequence

```mermaid
sequenceDiagram
    actor User
    participant Menu as WorkspaceManager.ps1
    participant Update as Update-Self.ps1
    participant Git as Git Remote
    participant Test as Run-Tests.ps1

    Note over User,Git: Startup auto-check
    User->>Menu: Launch
    Menu->>Git: git fetch origin
    Git-->>Menu: behind commits?
    alt Updates available
        Menu-->>User: ⚡ N update(s) available
    end

    Note over User,Test: Manual update
    User->>Menu: Option 14 → y
    Menu->>Update: pwsh -File Update-Self.ps1
    Update->>Git: git stash (if dirty)
    Update->>Git: git fetch + merge origin/main
    alt Merge conflict
        Update->>Git: git stash pop (restore)
        Update-->>User: ❌ Update aborted
    else Success
        Update->>Git: git stash pop (restore)
        Update->>Test: Run-Tests.ps1
        Test-->>Update: Pass/Fail
        Update-->>User: ✅ Update complete
    end
```

---

## 4. Validation Pipeline

```mermaid
flowchart LR
    A[User runs<br/>make validate] --> B[Run-Validate.ps1]
    B --> C[Scan all .json files]
    B --> D[Scan all .code-workspace]
    C --> E{Valid?}
    D --> E
    E -->|Yes| F[✅ PASS]
    E -->|No| G[❌ FAIL<br/>show error]

    A2[User runs<br/>make checks] --> B2[Run-Checks.ps1]
    B2 --> B
    B2 --> H[Secret scan<br/>grep for patterns]
    H --> I{Match?}
    I -->|No| J[✅ PASS]
    I -->|Yes| K[❌ FAIL<br/>list matched files]

    A3[User runs<br/>make test] --> B3[Run-Tests.ps1]
    B3 --> L[Parse .ps1 files<br/>AST check]
    B3 --> M[Parse .json files<br/>ConvertFrom-Json]
    L --> N{Errors?}
    M --> N
    N -->|No| O[✅ PASS<br/>show summary]
    N -->|Yes| P[❌ FAIL<br/>show line + error]
```

---

## 5. Data Structures

```mermaid
classDiagram
    class WorkspaceTemplate {
        +folders: array
        +settings: object
        +extensions: object
        +tasks: object
        +launch: object
    }
    class ProfileExport {
        +name: string
        +icon: string
        +settings: string
        +extensions: string
        +keybindings: string
        +version: number
    }
    class TrustConfig {
        +version: string
        +emptyWorkspaceTrust: boolean
        +autoUpdateCheck: boolean
        +trustedParentFolders: array
        +decisions: array
        +updatedAt: string
    }
    class BYOKMetadata {
        +version: string
        +provider: string
        +status: string
        +createdAt: string
        +keyReference: string
        +kmsInstructions: object
    }
    class TemplateMeta {
        +template: string
        +profile: string
        +projectName: string
        +projectPath: string
        +created: string
    }

    WorkspaceTemplate --> TemplateMeta : assigned to
    ProfileExport --> TemplateMeta : bound by
```

---

## 6. Automation Flow

```mermaid
flowchart TD
    subgraph Scheduled["Scheduled Tasks"]
        DAILY["Daily 09:00<br/>Run-Validate.ps1"]
        WEEKLY["Weekly Mon 12:00<br/>Auto-Backup.ps1"]
        MONTHLY["Monthly 1st 08:00<br/>Update-Self.ps1 -DryRun"]
    end

    subgraph CI["GitHub Actions"]
        PUSH["On Push<br/>validate.yml"]
        TAG["On Tag<br/>release.yml"]
        CRON["Weekly Mon 09:00<br/>scheduled-checks.yml"]
    end

    subgraph Manual["Manual Triggers"]
        MENU["Menu Option 15"]
        CLI["Schedule-Tasks.ps1"]
    end

    DAILY --> |writes| EXPORTS["exports/"]
    WEEKLY --> |writes| EXPORTS
    MONTHLY --> |notifies| USER["User"]

    PUSH --> |validates| REPO["GitHub Repo"]
    TAG --> |creates| RELEASE["GitHub Release"]
    CRON --> |alerts| ISSUE["Auto-Issue on Fail"]

    MENU --> Scheduled
    CLI --> Scheduled
```

---

## 7. Script Dependency Graph

```mermaid
graph TD
    HF["Helper-Functions.ps1<br/>(shared library)"]

    HF --> RV["Run-Validate.ps1"]
    HF --> RC["Run-Checks.ps1"]
    HF --> RT["Run-Tests.ps1"]
    HF --> CE["Check-Environment.ps1"]
    HF --> OW["Open-WithProfile.ps1"]
    HF --> AB["Auto-Backup.ps1"]
    HF --> RE["Recommend-Extensions.ps1"]
    HF --> NP["Navigate-Project.ps1"]

    RV --> RC
    RT --> US["Update-Self.ps1"]

    RV --> ST["Schedule-Tasks.ps1"]
    AB --> ST
    US --> ST

    WM["WorkspaceManager.ps1"] --> HF
    WM --> RV
    WM --> US
    WM --> ST

    style HF fill:#0f3460,stroke:#00ff88,color:#eee
    style WM fill:#16213e,stroke:#e94560,color:#eee
    style ST fill:#1a1a2e,stroke:#533483,color:#eee
```

---

## 9. Universal Launcher (v1.1.0)

```mermaid
flowchart TD
    START([vscode.ps1]) --> CHECK{args?}
    
    CHECK -->|"vscode"| MENU[Interactive Menu]
    CHECK -->|"vscode <id>"| DISPATCH[Direct Dispatch]
    CHECK -->|"vscode list"| LIST[List Tools]
    CHECK -->|"vscode init"| INIT[Regenerate Registry]
    
    MENU --> LOAD[Get-AllTools<br/>registry + scan]
    LOAD --> SHOW[Show-Menu<br/>category-grouped]
    SHOW --> PICK{User picks}
    PICK -->|"1..N"| DISPATCH
    PICK -->|"0"| EXIT([Exit])
    PICK -->|"H/L/?"| HELP[Show-Help/List]
    HELP --> SHOW
    
    DISPATCH --> FIND{Find tool<br/>by id}
    FIND -->|"found"| RUN[pwsh -File <path> @args]
    FIND -->|"not found"| ERR([Error: Unknown])
    RUN --> EXIT2([Exit])

    style START fill:#0f3460,stroke:#e94560,color:#eee
    style MENU fill:#16213e,stroke:#0f3460,color:#eee
    style DISPATCH fill:#0f3460,stroke:#e94560,color:#eee
```
