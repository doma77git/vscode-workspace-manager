# TODO — Tracking

> Items marked `[x]` are done. Check `ROADMAP.md` for the strategic plan.

---

## Immediate

- [x] Add PowerShell module manifest (`.psd1`) for PSGallery publishing
- [x] Add shell tab-completion for `Open-WithProfile.ps1`
- [ ] Create interactive onboarding wizard (first-run experience)
- [ ] Add JSON Schema validation for `.code-workspace` files
- [ ] Profile health check — verify extensions are installable

---

## Scripts

- [ ] `Export-WorkspaceSettings.ps1` — generate `.vscode/settings.json` from template
- [ ] `Batch-AssignProfile.ps1` — apply one profile to multiple templates
- [ ] `Diff-Templates.ps1` — show changes between template versions
- [ ] `Sync-Team.ps1` — push/pull team profiles and templates
- [ ] `Convert-ToModule.ps1` — package scripts as installable PowerShell module

---

## Documentation

- [x] `ROADMAP.md` — project roadmap
- [x] `TODO.md` — this file
- [x] `SUGGESTIONS.md` — future ideas
- [x] `docs/TUNEUP.md` — tune-up guide
- [x] `docs/HOWTO.md` — how-to recipes
- [x] `docs/AUTOMATION.md` — automation guide
- [x] `docs/FAQ.md` — frequently asked questions
- [x] `docs/TERMINAL.md` — terminal profiles and tasks
- [x] `docs/SELF-UPDATE.md` — self-update system

---

## UI / UX

- [ ] Add progress bar for long operations
- [x] Add `--json` output flag to all scripts for machine parsing
- [ ] Add `--quiet` flag to suppress non-error output
- [ ] Color-code validation output consistently across all scripts
- [ ] Add spinner animation for git fetch operations
- [ ] Add estimated time display for recursive scans

---

## Security

- [ ] Add signature verification for `Update-Self.ps1` (verify git tag GPG)
- [ ] Add template content sanitization check
- [ ] Add extension allowlist/blocklist for profiles
- [ ] Audit all scripts for injection vectors (done: clean)
- [ ] Add SBOM generation for dependencies

---

## Testing

- [x] Add YAML validation to `Run-Tests.ps1` (CI workflows)
- [x] Add Markdown linting to `Run-Tests.ps1` (broken links)
- [ ] Add integration test: create template, assign profile, validate
- [ ] Add mock-mode to menu for automated testing
- [ ] Add performance benchmarks (startup time, scan time)

---

## Community

- [ ] Create GitHub Discussions for Q&A
- [ ] Add contributor spotlight section to README
- [ ] Create video walkthrough (YouTube / Loom)
- [ ] Write blog post: "Managing VS Code at Scale"
- [ ] Publish to PowerShell Gallery

---

## Completed Recently

- [x] 12 PowerShell scripts (runners, checkers, helpers, backup, scheduler)
- [x] 15 menu options
- [x] 3 CI workflows (validate, release, scheduled)
- [x] Self-update system
- [x] Auto-backup system
- [x] Cross-platform path support
- [x] Prompt library (goals, run cookbook, learn path, improve, usage)
- [x] Box-drawn beautiful terminal output
- [x] Helper-Functions.ps1 shared library
- [x] Check-Environment.ps1 health check
- [x] Recommend-Extensions.ps1
- [x] Schedule-Tasks.ps1
