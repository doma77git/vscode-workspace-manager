# Goal Templates — Copy-Paste into Reasonix

Replace `{placeholders}` with your values. Each goal is self-contained — paste it and the agent runs it.

---

## 1. Set Up a New Project

```
Goal: Set up a new VS Code workspace from scratch for {project-name}.

Steps:
- Create a workspace template using the sample template as a guide
- Set ${PROJECT_NAME} to "{project-name}"
- Set ${GIT_REMOTE} to "{your-git-url}"
- Choose a profile from profiles/ that matches the stack
- Assign the profile to the template in meta/

Stop when: the template exists in templates/, has a valid profile assigned, and passes Run-Validate.ps1.
```

---

## 2. Create a Profile for a Specific Stack

```
Goal: Create a new VS Code profile for {stack-name} development.

Steps:
- Read profiles/profile-template.json for the metadata format
- Research the best extensions for {stack-name} (linters, formatters, language support)
- Create a new profile JSON in profiles/ named {stack-name}-dev.json
- Include recommended settings (tab size, formatter, terminal profile)
- Include at least 3 recommended extensions

Stop when: the profile JSON is valid and has settings + extensions populated.
```

---

## 3. Audit Project Security

```
Goal: Run a full security audit of the workspace manager project.

Steps:
- Run scripts/Run-Checks.ps1 and report results
- Review meta/deepseek-byok.json — confirm no real keys present
- Review .gitignore — confirm all secret patterns are excluded
- Run the pre-commit hook on staged files
- Check that SECURITY.md is up to date
- Verify CI workflow covers all required checks

Stop when: all checks pass or issues are documented.
```

---

## 4. Onboard a New Team Member

```
Goal: Prepare the workspace manager for a new team member joining the {team-name} team.

Steps:
- Create a workspace template for their primary repo
- Set up a profile matching their stack (Python/Node/Go/etc.)
- Assign the profile to the template
- Update meta/trust.json with their trusted parent folder
- Generate an onboarding summary: which menu options they'll use most

Stop when: the new member can run WorkspaceManager.ps1 and open their project with the right profile.
```

---

## 5. Migrate Profiles from Another Machine

```
Goal: Migrate VS Code profiles from an export file into this workspace manager.

Steps:
- Read the exported profile JSON at {path-to-export}
- Import it into profiles/ using WorkspaceManager.ps1 option 7
- Validate the profile JSON
- Scan a project and assign the best-matching profile
- Test opening the workspace with code --profile

Stop when: the profile is imported and assigned to a template.
```

---

## 6. Set Up Terminal + Tasks for a Project

```
Goal: Configure terminal profiles and VS Code tasks for {project-name}.

Steps:
- Read templates/sample-project.code-workspace for the current terminal config
- Customize terminal.integrated.profiles.windows to add a project-specific profile
- Add a task for the project's build command ({build-command})
- Add a task for the project's test command ({test-command})
- Add a compound task with dependsOn that chains build + test
- Validate the workspace JSON after changes

Stop when: the workspace has at least 2 new tasks and 1 new terminal profile, and JSON is valid.
```

---

## 7. Self-Update and Verify

```
Goal: Update the workspace manager to the latest version and verify everything works.

Steps:
- Run scripts/Update-Self.ps1 -Force
- Run scripts/Run-Tests.ps1 to verify all scripts parse
- Run scripts/Run-Checks.ps1 to verify no regressions
- Check CHANGELOG.md for new features
- Try the new features (if any)

Stop when: all tests pass and the version in CHANGELOG.md matches the update.
```

---

## 8. Add a New Best Practice

```
Goal: Research and implement a new best practice for the workspace manager.

Research:
- What do similar VS Code management projects do that we don't?
- What does the official VS Code docs recommend for {topic}?
- What would make the project more maintainable?

Implement:
- {describe the change}
- Update AGENTS.md, CHANGELOG.md, and relevant docs
- Run scripts/Run-Tests.ps1 to confirm nothing broke

Stop when: the change is implemented, documented, and all tests pass.
```

---

## 9. Benchmark and Optimize

```
Goal: Review the project for performance and usability optimizations.

Steps:
- Profile menu startup time (how long from launch to prompt?)
- Review all script outputs for unnecessary verbosity
- Check if any file scans could be cached
- Look for redundant validation steps
- Suggest and implement 2-3 optimizations

Stop when: optimizations are implemented and Run-Tests.ps1 passes.
```

---

## 10. Create a Release

```
Goal: Prepare and tag a new release of the workspace manager.

Steps:
- Review CHANGELOG.md — is everything documented since the last version?
- Bump version in WorkspaceManager.ps1 (Invoke-About header)
- Run scripts/Run-Tests.ps1 — must be all green
- Run scripts/Run-Checks.ps1 — must be all green
- Update deploy-instructions.txt checklist
- Commit with message "Release vX.Y.Z"
- Tag: git tag vX.Y.Z
- Push: git push && git push --tags

Stop when: the tag is pushed and the release workflow creates the GitHub Release.
```
