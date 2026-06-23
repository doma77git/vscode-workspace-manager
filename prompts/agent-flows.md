# Agent Flows — Decision Trees for Common Tasks

Use these flows when an AI agent needs to accomplish a task in this project.
Each flow is a decision tree: start at the top, follow the branches.

---

## Flow: Validate the Project

```
Is this a code change?
├─ Yes → Run make test
│   ├─ All pass? → Done ✅
│   └─ Failures?
│       ├─ PowerShell syntax error → Read the file at reported line → Fix → Re-run
│       ├─ JSON parse error → Read the file → Fix malformed JSON → Re-run
│       └─ After 2 attempts, same failure → Stop ✋, report to user
└─ No (just docs/config) → Run make validate
    ├─ All pass? → Done ✅
    └─ Failures? → Fix, re-run (max 2)
```

---

## Flow: Add a New Script

```
1. Understand the need → What should the script do?
2. Check existing scripts → Is there one that does this already?
   ├─ Yes → Enhance it instead
   └─ No → Continue
3. Choose the right location:
   ├─ Runner (executes something) → scripts/Run-*.ps1
   ├─ Checker (validates something) → scripts/Check-*.ps1
   ├─ Helper (shared functions) → Add to scripts/Helper-Functions.ps1
   ├─ Launcher (opens something) → scripts/Open-*.ps1
   └─ Other → scripts/<Verb>-<Noun>.ps1
4. Create the script:
   ├─ Start with .SYNOPSIS comment block
   ├─ Dot-source Helper-Functions.ps1
   ├─ Use Write-Banner, Write-Section, Write-Pass/Fail/Warn
   └─ Exit 0 on success, 1 on failure
5. Wire it in:
   ├─ Menu option? → Add function + case to WorkspaceManager.ps1
   ├─ Make target? → Add to Makefile
   ├─ npm script? → Add to package.json
   └─ None needed? → Skip
6. Update docs: AGENTS.md → CHANGELOG.md → run make test
```

---

## Flow: Add a New Menu Option

```
1. Determine category:
   ├─ Workspace management → ── Workspace ── section
   ├─ Profiles → ── Profiles ── section
   ├─ Security → ── Security ── section
   └─ Utilities → ── Tools ── section
2. Create the function:
   ├─ Name: Invoke-<Verb><Noun> (PascalCase)
   ├─ Use Write-Host with colors consistently
   ├─ End with Pause (so user sees output)
   └─ Return to menu after (don't exit)
3. Add menu item:
   ├─ Write-Host "  N) <emoji> <description>" (4-space indent, 2-digit align for 10+)
   └─ Add emoji from the project's convention
4. Add switch case: "N" { Invoke-<Name> }
5. Update function count in AGENTS.md
6. Run make test → validate → done
```

---

## Flow: Fix a Bug

```
1. Reproduce → Can you trigger the bug?
   ├─ Yes → Note steps
   └─ No → Ask user for reproduction
2. Diagnose:
   ├─ Read the error message
   ├─ Check the file at reported line
   ├─ Is it a script syntax error? → Run-Tests.ps1 will catch
   ├─ Is it a logic error? → Add Write-Host debug, re-run
   └─ Is it an environment issue? → Run Check-Environment.ps1
3. Fix:
   ├─ Small fix (< 5 lines) → edit_file
   ├─ Larger fix → write_file (re-read first)
   └─ Multiple files → multi_edit
4. Verify:
   ├─ Run make test
   ├─ Run the specific script that was broken
   └─ If test was missing → consider adding one
5. Document:
   ├─ Add to CHANGELOG.md under Fixed
   └─ If user-facing → update relevant doc
```

---

## Flow: Research a Topic

```
1. Is it a code question?
   ├─ Yes → Read the relevant files
   │   ├─ Use grep for symbols
   │   ├─ Use read_file for full context
   │   └─ Check AGENTS.md for conventions
   └─ No (external research) → Use web_fetch
       ├─ VS Code docs → code.visualstudio.com/docs/
       ├─ GitHub topics → github.com/topics/
       └─ Similar projects → github.com/<user>/<repo>
2. Synthesize:
   ├─ List findings with file:line or URL citations
   ├─ Distinguish "verified in code" from "read on docs page"
   └─ If uncertain → say so
3. Report back to user with actionable items
```

---

## Flow: Review Changes

```
1. Scope the diff:
   ├─ git status → what's changed?
   ├─ git diff --stat → how big?
   └─ > 20 files? → Focus on riskiest 2-3
2. Review by priority:
   ├─ Scripts that execute commands → injection risk?
   ├─ Config files → secrets exposed?
   ├─ JSON/YAML → valid syntax?
   └─ Docs → broken links?
3. For each file:
   ├─ Read the diff context
   ├─ Check callers (grep for function names)
   └─ Flag: security, correctness, hidden behavior
4. Report:
   ├─ One-sentence verdict (ship/no-ship/nits)
   ├─ Items grouped by severity
   └─ File:line + problem + fix direction
```

---

## Flow: Create a Release

```
1. Pre-flight:
   ├─ make test → must be all green
   ├─ make checks → no secrets
   └─ make doctor → environment OK
2. Version bump:
   ├─ Read CHANGELOG.md → what's the current version?
   ├─ What's the new version? (semver)
   └─ Update version in WorkspaceManager.ps1 (Invoke-About)
3. Changelog:
   ├─ Ensure all changes are documented since last version
   ├─ Group under Added / Changed / Fixed / Security
   └─ Set the date
4. Commit & Tag:
   ├─ git add -A
   ├─ git commit -m "Release vX.Y.Z"
   ├─ git tag vX.Y.Z
   └─ git push && git push --tags
5. Verify:
   └─ GitHub Actions → release.yml should create the Release
```

---

## Flow: Onboard a New User

```
1. Check environment:
   ├─ Run Check-Environment.ps1
   └─ Fix any missing prerequisites
2. Walk through ONBOARDING.md:
   ├─ Minute 0-2: basic setup
   ├─ Minute 3-5: create template, set trust, export profile
   └─ Minute 6-7: validation, advanced features
3. Verify:
   ├─ They can launch the menu
   ├─ They can create a template
   └─ They can run make validate
4. Point to next steps:
   ├─ prompts/learn-path.md for guided learning
   └─ prompts/run-cookbook.md for command reference
```
