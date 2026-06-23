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

**When to use each type:**
| Type | Use for |
|------|---------|
| `user` | Personal preferences, identity, who you are |
| `feedback` | How Reasonix should work in this project |
| `project` | Facts the code doesn't record (roadmap, decisions, constraints) |
| `reference` | External resource pointers, URLs, docs |

**Memory workflow:**
```
1. Search memories for: deployment  → check for duplicates
2. Remember: deploy-pipeline-azure
   Body: Deploy to Azure via .azure/deployment-plan.md...
   Type: project
3. Later: Read memory: deploy-pipeline-azure
4. Stale? → Update by re-running Remember with same name
5. Obsolete? → Forget memory: deploy-pipeline-azure
```

---

## todo

Track multi-step work with structured task lists.

### Create a task list
```
Todo:
1. {phase 1 title} (phase)
   - {sub-step A}
   - {sub-step B}
2. {phase 2 title} (phase)
   - {sub-step C}
   - {sub-step D}
```

**Example:**
```
Todo:
1. Setup (phase)
   - Create project directory
   - Initialize git
2. Core logic (phase)
   - Add config loader
   - Add CLI parser
3. Polish (phase)
   - Write README
   - Run tests
```

### Best practices
- Keep exactly **one step** in progress at a time
- Mark completed IMMEDIATELY after finishing — don't batch
- Use **phases** (level 0) for milestones, **sub-steps** (level 1) for concrete tasks
- Each step needs an `activeForm` (present-continuous verb: "Adding the parser")

### The todo lifecycle
```
pending → in_progress (one at a time) → completed
                                              ↓
                              evidence required (verification/diff/files/manual)
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

### Plan mode rules
- **Read-only** — writers are blocked until approved
- Plans are **two-level markdown lists**: phases (numbered) with sub-steps (bullets)
- 2–6 phases recommended
- Present the plan, then **stop** — the user approves before execution

---

## instructions

Write and reuse instruction files, slash commands, and skills.

### Write an instruction file
```
Create instructions: {path/instructions.md}

Purpose: {what this instruction set does}

Steps:
1. {step 1}
2. {step 2}
3. {step 3}

Output: {expected result}
```

**Example:**
```
Create instructions: .reasonix/instructions/release.md

Purpose: Cut a new release — version bump, changelog, tag, push.

Steps:
1. Read current version from package.json
2. Prompt for new version (major/minor/patch)
3. Update package.json and CHANGELOG.md
4. git add, git commit -m "Release v{version}"
5. git tag v{version}
6. git push --follow-tags

Output: New version committed, tagged, and pushed.
```

### Create a slash command (skill)
```
Create skill: {skill-name}
Description: {≤120 chars, one-liner}
Body:
{markdown instructions}

Run as: inline | subagent
Scope: project | global
```

### Run a skill or slash command
```
/{skill-name} {arguments}
```

**Example:**
```
/azure-deploy
→ runs the azure-deploy skill
→ reads .azure/deployment-plan.md
→ executes deployment
```

---

## kb

Build and query a project knowledge base with Reasonix.

### Bootstrap a knowledge base
```
Init this project.

Then document:
- Architecture decisions (ADR-style)
- API endpoints and their contracts
- Data models and relationships
- Deployment topology
- Onboarding guide for new contributors
```

### Index and search the codebase
```
Explore: {question about the codebase}

Example:
Explore: Where is authentication handled, and how does the token flow work end-to-end?
→ Returns distilled answer with file:line citations
```

### Research with external + local context
```
Research: {question}

Example:
Research: Is our rate-limiting implementation consistent with RFC 6585? Compare our impl in src/ratelimit/ against the spec.
→ Returns synthesis citing code (file:line) and web (URL)
```

### Build a structured KB
```
Memo workflow:
1. Remember: architecture-overview
   Body: System diagram description, key services, data flow...
   Type: reference
2. Remember: api-endpoints
   Body: GET /api/users, POST /api/auth, ...
   Type: reference
3. Remember: deploy-topology
   Body: Azure App Service + AKS, regions, failover...
   Type: reference

Search memories for: {topic} → find relevant context
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

## graphical workflow

Generate visual diagrams for architecture, workflows, and deployment.

### Architecture diagram from resources
```
Analyze resource group {name} and generate a Mermaid architecture diagram.
```

### Data flow diagram
```
Draw a Mermaid sequence diagram showing:
1. User submits login form
2. Auth service validates credentials
3. JWT token issued
4. Frontend stores token in httpOnly cookie
5. Subsequent requests include token in Authorization header
```

### Deployment pipeline
```
Diagram the CI/CD pipeline:
1. Push to main → GitHub Actions trigger
2. Build → Lint → Test → Package
3. Deploy to staging (Azure App Service slot)
4. Smoke tests
5. Swap to production
Use Mermaid flowchart.
```

### Project structure map
```
Generate a Mermaid mindmap of this project's directory structure and key files.
```

### Common diagram types

| Diagram | Mermaid type | Use for |
|---------|-------------|---------|
| Architecture | `graph TD` / `flowchart` | Services, resources, dependencies |
| Sequence | `sequenceDiagram` | API calls, auth flows, async ops |
| State | `stateDiagram-v2` | State machines, lifecycle |
| Class | `classDiagram` | Data models, interfaces |
| Entity relation | `erDiagram` | Database schemas |
| Mindmap | `mindmap` | Project structure, feature breakdown |

### Prompt template
```
Generate a Mermaid {diagram type} showing:
- {entity 1}
- {entity 2}
- {relationship 1}
- {relationship 2}

Include: {annotations, colors, notes}
Output: Raw Mermaid syntax in a markdown code block.
```

---

## agentic deployment

Autonomous deployment with Reasonix — from code to cloud.

### Azure deployment (full pipeline)
```
Goal: Deploy this project to Azure.

Context:
- App type: {web app / function app / container / AKS}
- Framework: {Node.js / Python / .NET / Go / ...}
- Target: {new resource group / existing environment}

The agent should:
1. Run azure-prepare to generate Bicep/Terraform, Dockerfile, azure.yaml
2. Run azure-validate to check readiness
3. Run azure-deploy to execute the deployment plan
4. Verify the deployed app responds on its endpoint

Stop when: curl {endpoint} returns 200.
```

### Quick deploy prompt
```
/azure-prepare
→ generates infrastructure and deployment files
→ then:
/azure-validate
→ deep pre-deployment checks
→ then:
/azure-deploy
→ executes .azure/deployment-plan.md
```

### Deployment checklists
```
Before deploying, verify:
[ ] .azure/deployment-plan.md exists
[ ] Bicep/Terraform templates are valid
[ ] Dockerfile builds locally
[ ] azure.yaml is configured
[ ] Secrets are in environment variables, NOT in code
[ ] Resource quotas are sufficient (run /azure-quotas)
```

### Multi-environment workflow
```
Plan: Set up staging + production deployment slots in Azure App Service.
Goal: Implement the approved plan.
→ swap to production when smoke tests pass.
```

### AKS deployment
```
/azure-kubernetes
→ plan and create production-ready AKS cluster
→ then:
/azure-deploy
→ deploy the application to AKS
```

### Post-deployment verification
```
After deployment:
1. Check resource health (azure-diagnostics)
2. Verify endpoints respond
3. Check logs for errors
4. Set up Application Insights (appinsights-instrumentation)
5. Save deployment context as memory:
   Remember: deploy-{date}
   Body: Deployed to {resource-group}. Endpoint: {url}. Commit: {sha}.
   Type: reference
```

---

## Quick Combinations

### Start a new feature (plan → goal → todo)
```
Plan task: Add export-all-profiles to WorkspaceManager.ps1.
→ approve plan
Goal: Implement the approved plan.
→ the agent creates a todo list automatically
```

### Save context for next session (memo + project)
```
Remember: workspace-manager-stack
Body: Stack: PowerShell 7, Git, VS Code CLI. Scripts at C:\VSCode\Templates\scripts. No external dependencies. UTF-8 no BOM. pwsh -NoProfile -ExecutionPolicy Bypass.
Type: project

This project is: VS Code Workspace Manager — templates, profiles, BYOK, trust.
```

### Bootstrap a new repo (init → project → kb → goal)
```
Init this project.
→ then:
This project is: {description from generated AGENTS.md}
→ then:
Explore: What is the overall architecture and where are the key modules?
→ then:
Goal: {first task based on the project structure}
```

### Deploy from scratch (prepare → validate → deploy → verify)
```
/azure-prepare
/azure-validate
/azure-deploy
→ then: curl the endpoint to verify
→ then: remember the deployment context
```

### Visualize and understand (explore → graphical workflow)
```
Explore: How does the request flow from entry point to database?
→ then:
Draw a Mermaid sequence diagram of the request lifecycle based on the exploration.
```

---

## pr follow-up

Pull request review, security audit, and post-merge workflows.

### Review a PR before merging
```
Review the current branch diff.
Focus on: {auth changes / error handling / new API / general}.
→ Returns per-file:line findings with correctness, security, missing-tests flags.
```

**Example:**
```
Review the current branch diff.
Focus on: the auth changes in internal/auth/.
```

### Security-focused review
```
Security review the current branch diff.
Focus on: {token handling / input parsing / file IO / auth / full}.
→ Returns severity-tagged findings: injection, authz, secrets, deserialization, path-traversal, crypto.
```

**Example:**
```
Security review the current branch diff.
Focus on: token handling in internal/auth/.
```

### PR checklist (pre-submit)
```
Before opening this PR, check:
[ ] All tests pass locally
[ ] No secrets in the diff (run security review)
[ ] New code has tests
[ ] Documentation updated
[ ] Breaking changes noted in commit body
[ ] Branch rebased on main
```

### Post-merge follow-up
```
Goal: Post-merge cleanup for PR #{number}.
- Delete the feature branch
- Update any stale memories related to the changed code
- Verify the deployment succeeded
- Close linked issues
```

### Review-then-fix loop
```
1. Review the current branch diff.
2. → apply fixes for the findings
3. Security review the current branch diff.
4. → apply fixes for any high/medium findings
5. Re-run tests
6. Merge
```

### PR review prompts for common scenarios

| Scenario | Prompt |
|----------|--------|
| General review | `Review the current branch diff.` |
| Auth changes | `Security review the current branch diff. Focus on token handling.` |
| New API endpoint | `Review the current branch diff. Focus on input validation and error handling.` |
| Refactor | `Review the current branch diff. Focus on behavioral changes and regressions.` |
| Config changes | `Review the current branch diff. Focus on defaults and environment-specific values.` |
| SQL/database | `Review the current branch diff. Focus on query safety and migration correctness.` |

### Branch-diff summary for PR description
```
Summarize the recent git changes into a PR description.
Include: what changed, why, testing done, breaking changes.
```

---

## skills

Reasonix skills ecosystem — built-in, custom, install, discover.

### Discover available skills
```
List available skills.
→ or: /list
```

### Built-in skills (always available)

| Skill | Type | Use for |
|-------|------|---------|
| `init` | inline | Bootstrap AGENTS.md from codebase |
| `explore` | subagent | Deep codebase investigation, returns distilled answer |
| `research` | subagent | Web + code combined research, returns synthesis |
| `review` | subagent | Code review of current branch diff |
| `security_review` | subagent | Security-focused review, severity-tagged |
| `test` | inline | Generate and run tests |
| `install-capability` | inline | Install MCP servers and skills |
| `azure-prepare` | inline | Generate Bicep/Terraform, Dockerfile, azure.yaml |
| `azure-deploy` | inline | Execute .azure/deployment-plan.md |
| `azure-validate` | inline | Pre-deployment readiness checks |
| `azure-kubernetes` | inline | Plan and create AKS clusters |
| `azure-diagnostics` | inline | Debug production Azure issues |
| `azure-cost` | inline | Query, forecast, and optimize Azure costs |
| `azure-rbac` | inline | Find least-privilege RBAC roles |
| `azure-quotas` | inline | Check/manage Azure quotas |
| `azure-resource-lookup` | inline | List/find/show Azure resources |
| `azure-resource-visualizer` | inline | Generate Mermaid architecture from resource groups |
| `azure-storage` | inline | Blob, File Shares, Queue, Table, Data Lake |
| `azure-messaging` | inline | Event Hubs and Service Bus troubleshooting |
| `azure-ai` | inline | Azure AI: Search, Speech, OpenAI, Document Intelligence |
| `entra-app-registration` | inline | Microsoft Entra ID app registration and OAuth |
| `entra-agent-id` | inline | Entra Agent Identity provisioning |
| `appinsights-instrumentation` | inline | Application Insights telemetry patterns |

### Skill types

| Type | Behavior |
|------|----------|
| **inline** | Body folds into current turn — you read and act on it immediately |
| **subagent** | Spawns isolated child loop — only the distilled answer returns |

### When to use subagent vs inline
- **subagent**: Context-heavy work (deep exploration, multi-step research, reviews). Use when you only need the conclusion.
- **inline**: Lightweight playbooks (config, checklist, setup). Use when you need to follow step-by-step instructions.

### Install a skill from a URL
```
Install skill from: {https://raw.githubusercontent.com/user/repo/main/skill-name/SKILL.md}
```

### Install a local skill folder
```
Install skill from: {C:\path\to\skill-folder}
Mode: copy | link | register
```

### Install an MCP server
```
Install MCP server from: {URL / .mcp.json / npm-package / executable}
Scope: project | global
```

### Uninstall a skill or MCP server
```
Uninstall skill: {skill-name}
→ or:
Uninstall MCP server: {server-name}
```

### Create a custom skill
```
Create skill: {skill-name}
Description: {≤120 chars}
Body:

# {Skill Title}

## When to use
{trigger conditions}

## Steps
1. {step}
2. {step}

## Output
{expected result}

Run as: inline | subagent
Scope: project | global
```

**Example — custom release skill:**
```
Create skill: cut-release
Description: Version bump, changelog, tag, and push a new release.

Body:

# Cut Release

## When to use
User says "release", "cut a release", "ship it".

## Steps
1. Read current version from package.json
2. Prompt: major, minor, or patch?
3. Bump version, update CHANGELOG.md
4. git add, git commit -m "Release v{version}"
5. git tag v{version} && git push --follow-tags

## Output
New version on remote with tag.

Scope: project
```

### Skill discovery workflow
```
1. /list → see all available slash commands and skills
2. Read skill: {skill-name} → preview without running
3. /{skill-name} {args} → run it
4. Install skill from: {source} → add new capabilities
```

### Composing skills into workflows
```
Goal: Audit and deploy.

1. /security-review → find vulnerabilities
2. → fix findings
3. /azure-prepare → generate deployment files
4. /azure-validate → check readiness
5. /azure-deploy → ship it
6. Remember: deploy-{date} → save context
```
