# Agent Research Paths — How to Investigate in This Project

Systematic investigation paths for AI agents. Start at the top, follow the branches.

---

## Research Path: "How does X work?"

```
1. Check AGENTS.md Architecture section → is X listed?
   └─ Yes → Read the description, note the file path
2. Find the file:
   ├─ Script → grep "^function " scripts/ for function definitions
   ├─ Config → grep "<setting>" templates/ meta/ .vscode/
   └─ Doc → grep "^## " docs/ for section headings
3. Read the file:
   ├─ Scripts → read_file offset/limit for the function body
   ├─ Config → read_file for the full JSON structure
   └─ Docs → read_file for the section context
4. Trace dependencies:
   ├─ grep for function name across scripts/
   └─ grep for setting name across templates/ .vscode/
5. Report: file:line + what it does + who depends on it
```

---

## Research Path: "Where is X used?"

```
1. Search for the symbol:
   ├─ grep -r "SymbolName" scripts/ templates/ meta/
   ├─ grep -r "setting.name" templates/ .vscode/
   └─ grep -r "## Section" docs/
2. Categorize hits:
   ├─ Definition → the source
   ├─ Caller → scripts that invoke it
   ├─ Documented → docs that reference it
   └─ Configured → JSON files that set it
3. Report: "X appears in N places: definition at file:line, called by Y and Z, documented in A and B"
```

---

## Research Path: "Is X supported?"

```
1. Check the code first:
   ├─ grep for the feature name in scripts/
   ├─ Check WorkspaceManager.ps1 menu for related options
   └─ Check Makefile + package.json for related targets
2. Check the docs:
   ├─ grep for the topic in docs/INDEX.md
   └─ grep for the topic in docs/*.md
3. If not found locally → check external:
   ├─ web_fetch: code.visualstudio.com/docs/ for VS Code features
   └─ web_fetch: github.com/topics/ for similar projects
4. Report: "Found / Not found in code (searched scripts/, docs/). External docs say..."
   └─ If "not found" → list what you searched to reach that conclusion
```

---

## Research Path: "What's our policy on X?"

```
1. Check AGENTS.md Conventions section → is X mentioned?
2. Check SECURITY.md → if X is security-related
3. Check CONTRIBUTING.md → if X is contribution-related
4. Check CHANGELOG.md → if X was recently changed
5. Check the relevant script → grep for X in scripts/
6. Check meta/trust.json → if X is a configuration preference
7. Report: "Project policy: [finding]. Source: [file:line]."
```

---

## Research Path: "Compare our implementation against spec"

```
1. Read our implementation:
   ├─ Find the relevant file(s)
   ├─ Note the key decisions and values
   └─ Count: how many items, what format, what defaults
2. Fetch the spec:
   ├─ web_fetch: official VS Code docs
   └─ web_fetch: canonical reference URL
3. Compare item by item:
   ├─ Spec says X → we do Y → match / mismatch / partial
   └─ Note gaps as "missing" or "different"
4. Report:
   ├─ Lead with verdict: "fully compliant" / "minor gaps" / "major gaps"
   ├─ Table: Spec Requirement → Our Status → Detail
   └─ Cite code (file:line) AND web source (URL)
```

---

## Research Path: "Find similar projects"

```
1. Search GitHub topics:
   ├─ web_fetch: github.com/topics/vscode-workspace
   ├─ web_fetch: github.com/topics/vscode-profiles
   └─ web_fetch: github.com/topics/vscode-templates
2. For each interesting project:
   ├─ web_fetch: github.com/<user>/<repo> (README)
   ├─ Note: what does it do differently?
   └─ Note: what can we learn?
3. Compare against our project:
   ├─ What do they have that we don't?
   ├─ What do we have that they don't?
   └─ What's worth adopting?
4. Report:
   ├─ Table: Project → Approach → What we can learn
   ├─ Gaps to fill (prioritized)
   └─ Unique strengths (what we do better)
```

---

## Research Path: "Optimal way to implement X"

```
1. Check if X exists in the project:
   ├─ grep for related terms
   └─ Check ROADMAP.md and TODO.md for plans
2. Research external best practices:
   ├─ web_fetch: official VS Code docs for X
   └─ web_fetch: similar projects' implementation
3. Determine the right location:
   ├─ Menu option? → WorkspaceManager.ps1
   ├─ Standalone script? → scripts/
   ├─ Config? → meta/ or .vscode/
   ├─ Doc? → docs/
   └─ CI? → .github/workflows/
4. Propose:
   ├─ What to create (filename)
   ├─ Where it fits (category)
   ├─ What it depends on (scripts/settings)
   └─ What tests to add
```

---

## Research Path: "Diagnose a test failure"

```
1. Run the failing test:
   ├─ make test → which file failed?
   └─ make validate → which JSON is invalid?
2. Read the error:
   ├─ PowerShell syntax → line number + error message
   ├─ JSON parse → file name + exception
   └─ Secret scan → which file matched the pattern
3. Read the file at the reported location
4. Determine: production bug or test bug?
   ├─ Production bug → fix the code
   ├─ Test bug (false positive) → fix the test/pattern
   └─ Environment → report to user
5. Fix → re-run (max 2 attempts on same failure)
6. If still failing after 2 → STOP, report with context
```

---

## Quick-Reference: Search Commands

```bash
# Find a function definition
grep -rn "^function " scripts/ | grep "FunctionName"

# Find all callers of a function
grep -rn "FunctionName" scripts/

# Find where a setting is used
grep -rn "setting\.name" templates/ .vscode/ meta/

# Find a section in documentation
grep -rn "^## " docs/ | grep "Topic"

# Find a menu option
grep -rn "Write-Host.*N)" scripts/WorkspaceManager.ps1

# Find a Makefile target
grep -rn "^## " Makefile

# Find an npm script
grep ":" package.json
```
