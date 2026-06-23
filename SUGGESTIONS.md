# Suggestions — Future Ideas & Improvements

Ideas for evolving the project. See `ROADMAP.md` for prioritized plan and `TODO.md` for tracking.

---

## 🎨 UX Polish

- Interactive onboarding wizard on first launch (detects new install, walks through setup)
- Color theme support — light/dark mode terminal output
- Progress bars for recursive scans
- `--json` flag on all scripts for machine-readable output
- `--quiet` flag to suppress non-error output
- Tab-completion for profile names in PowerShell
- Shell integration indicator in the About box

---

## 🔧 New Features

- **Profile inheritance** — base profile + overrides (e.g., "python-dev extends base")
- **Template diff** — `Diff-Templates.ps1` to show what changed between versions
- **Batch operations** — apply profile to all templates at once
- **Export to `.vscode/`** — generate `.vscode/settings.json` + `.vscode/extensions.json` from a template
- **Extension health check** — verify all recommended extensions are installable
- **Template marketplace** — community-contributed templates
- **Profile presets** — curated profiles for common stacks (Python, Node, Go, Rust, etc.)

---

## 🧠 AI Integration

- **AI profile generator** — "I want a profile for React with TypeScript and Tailwind" → generates profile JSON
- **Smart workspace suggestions** — based on project structure, suggest the right template
- **Auto-detect improvements** — add more indicator files, use ML for ambiguous projects
- **Natural language task creation** — "create a task that runs pytest and opens coverage report"

---

## 🤝 Collaboration

- **Team sync** — `git push` profiles to a team repo, `git pull` from team
- **Shared trust database** — aggregate team trust decisions
- **Slack/Teams/Discord notifications** — alert on CI validation failures
- **Contributor metrics** — who added which templates/profiles
- **Review workflow** — PRs for profile/template changes

---

## 🚀 Platform Expansion

- **VS Code extension** — sidebar view, status bar indicator, command palette integration
- **Web dashboard** — browser-based management, no CLI needed
- **REST API** — programmatic access to templates, profiles, tasks
- **Docker image** — pre-configured workspace manager in a container
- **GitHub App** — auto-suggest profiles on PRs based on changed files
- **PowerShell Gallery** — publish as installable module (`Install-Module VSCodeWorkspaceManager`)

---

## 🔒 Security

- GPG signature verification for `Update-Self.ps1`
- Template content scanning (malicious settings detection)
- Extension allowlist/blocklist per profile
- SBOM generation for dependencies
- Supply chain attestation for releases

---

## 📊 Analytics & Observability

- Usage dashboard — most-used templates, most-assigned profiles
- Health metrics — validation pass rate over time
- Update cadence tracking — when was the last successful update?
- Performance benchmarks — startup time, scan time trends

---

## 🧪 Testing

- YAML validation for CI workflows in `Run-Tests.ps1`
- Markdown link checking for doc files
- Integration tests: create template → assign profile → validate → open
- Mock-mode for automated menu testing
- Performance regression tests
- Fuzz testing for JSON parsers

---

## 🌍 Community

- GitHub Discussions for Q&A
- Video walkthrough / tutorial series
- Blog posts: "Managing VS Code at Scale", "Profiles as Code"
- Conference talk / meetup presentation
- Contributor recognition (hall of fame in README)

---

## 📝 Maintenance

- Dependency update automation for `package.json`
- Automated changelog generation from conventional commits
- Issue auto-labeling via GitHub Actions
- Stale issue/pr cleanup workflow
- Release notes auto-generation from merged PRs

---

## How to Prioritize

1. **Vote** — open an issue with the `enhancement` label
2. **Discuss** — GitHub Discussions for community input
3. **Prototype** — create a branch and proof-of-concept
4. **Refine** — get feedback, iterate
5. **Ship** — merge, update CHANGELOG, tag release
