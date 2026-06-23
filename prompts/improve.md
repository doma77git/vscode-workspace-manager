# Improve — Prompts for Evolving the Project

Copy-paste these into Reasonix to iteratively improve the VS Code Workspace Manager.

---

## 🔧 Add a New Feature

```
Goal: Add a new feature to the VS Code Workspace Manager: {describe feature in one sentence}.

Research:
- Check docs/ARCHITECTURE.md for where this fits
- Check similar projects for how they implement it
- Determine if it's a menu option, standalone script, or doc change

Implement:
- Add the code to the correct location (scripts/ or menu)
- Update AGENTS.md with the new component
- Update CHANGELOG.md with the addition
- Add any new prompts to prompts/
- Run scripts/Run-Tests.ps1

Stop when: feature works, is documented, and all tests pass.
```

---

## 📚 Improve Documentation

```
Goal: Review and improve the project documentation.

Steps:
- Read README.md, LANDING.md, ONBOARDING.md — are they accurate?
- Check that all menu options are documented in ONBOARDING.md
- Check that all scripts are documented in AGENTS.md
- Check the documentation map in LANDING.md — are all docs listed?
- Verify no broken links between docs
- Add any missing cross-references

Stop when: all docs are accurate and cross-linked.
```

---

## 🎨 Polish UX

```
Goal: Improve the user experience of the workspace manager.

Review:
- Menu layout: are options grouped logically?
- Output formatting: do all functions use consistent colors and emoji?
- Error messages: do they include recovery suggestions?
- Defaults: are the most common choices pre-filled?
- Speed: is there unnecessary output or waiting?

Implement 2-3 improvements, then run scripts/Run-Tests.ps1.
```

---

## 🔒 Harden Security

```
Goal: Review and strengthen the project's security posture.

Steps:
- Run scripts/Run-Checks.ps1 — confirm no secrets detected
- Review .gitignore — are all sensitive patterns covered?
- Review pre-commit hook — does it catch the latest leak patterns?
- Check that SECURITY.md is aligned with the current state
- Review CI workflows for pinned action versions
- Check that BYOK files are properly excluded

Implement any improvements found.
```

---

## 🧪 Expand Test Coverage

```
Goal: Add new tests to improve project reliability.

Steps:
- Review scripts/Run-Tests.ps1 — what isn't tested?
- Consider: YAML validation for CI workflows
- Consider: Markdown linting for doc files
- Consider: Workspace JSON schema validation
- Consider: Script functionality tests (mock the menu)
- Add at least one new test category

Stop when: the new test runs and catches at least one issue or confirms correctness.
```

---

## 🏎️ Optimize Performance

```
Goal: Profile and optimize the workspace manager startup and runtime.

Profile:
- Time the menu launch: Measure-Command { pwsh -File scripts\WorkspaceManager.ps1 }
- Identify slow file operations (recursive scans, stale caches)
- Check git operations in the auto-update check

Implement:
- Cache file counts between menu refreshes
- Reduce git fetch frequency (only once per session)
- Lazy-load expensive operations

Stop when: startup time is measurably faster and tests pass.
```

---

## 🌍 Cross-Platform Polish

```
Goal: Test and improve cross-platform support.

Steps:
- Run scripts/Run-Tests.ps1 on Linux or macOS (if available)
- Check that all paths use Join-Path (not hardcoded backslashes)
- Check that terminal profiles have platform-appropriate defaults
- Verify that Makefile targets work on macOS/Linux
- Update docs to reflect any platform-specific notes

Stop when: the project runs correctly on at least one non-Windows platform.
```

---

## 📊 Add Metrics & Reporting

```
Goal: Add a metrics/reporting feature to the workspace manager.

Steps:
- Create a new function that collects: template count, profile count, disk usage, last update date
- Add it as a menu option or integrate into Invoke-About
- Output a summary report (text table or JSON)
- Consider adding a --json flag for machine-readable output

Stop when: the report is generated and shows useful information.
```

---

## 🔄 Continuous Improvement Loop

```
Goal: Run the full improvement cycle on the workspace manager.

Steps:
1. Run scripts/Run-Tests.ps1 — baseline
2. Run scripts/Run-Checks.ps1 — security baseline
3. Read CHANGELOG.md — what's the current version?
4. Review the suggestions in docs/RECOMMENDATIONS.md — anything to implement?
5. Check the similar projects research — any best practice we're missing?
6. Implement 1 improvement
7. Run tests again
8. Commit with a descriptive message

Repeat 1-8 as needed.
```
