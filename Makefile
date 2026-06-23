# VS Code Workspace Manager — Makefile
# Run targets from Git Bash (Windows) or any POSIX shell.
# Prerequisites: pwsh 7+, git, code CLI

.PHONY: help validate checks install clean deps doctor

## help        Show this help (default)
help:
	@echo "VS Code Workspace Manager"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@grep '^##' Makefile | sed 's/^## //'

## validate    Validate all JSON and .code-workspace files
validate:
	@pwsh -NoProfile -File scripts/Run-Validate.ps1

## checks      Run full checks (validate + secret scan)
checks:
	@pwsh -NoProfile -File scripts/Run-Checks.ps1

## test         Run tests (PowerShell syntax + JSON validation)
test:
	@pwsh -NoProfile -File scripts/Run-Tests.ps1

## all          Run all operations (test + validate + checks + doctor)
all:
	@pwsh -NoProfile -File scripts/Run-All.ps1

## install     Initialize the repo (one-time) and install pre-commit hook
install:
	@pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/Init-TemplatesRepo.ps1

## doctor      Check prerequisites (PowerShell, VS Code CLI, git)
doctor:
	@echo "PowerShell:"
	@pwsh --version || echo "  MISSING: install PowerShell 7+"
	@echo "VS Code CLI:"
	@code --version || echo "  MISSING: install code in PATH"
	@echo "Git:"
	@git --version || echo "  MISSING: install git"
	@echo "act (optional):"
	@act --version 2>/dev/null || echo "  Not installed — optional for CI simulation"

## clean       Remove export archives
clean:
	@rm -rf exports/

## backup      Back up templates, profiles, and meta to timestamped zip
backup:
	@pwsh -NoProfile -File scripts/Auto-Backup.ps1

## schedule    Show or manage scheduled tasks
schedule:
	@pwsh -NoProfile -File scripts/Schedule-Tasks.ps1 -Action list

## doctor      Full environment health check
doctor:
	@pwsh -NoProfile -File scripts/Check-Environment.ps1

## recommend   Recommend VS Code extensions for a project (set PATH=)
recommend:
	@pwsh -NoProfile -File scripts/Recommend-Extensions.ps1 -Path $(or $(PATH),.)

## repair      Auto-repair common issues (JSON, line endings, dirs, hooks)
repair:
	@pwsh -NoProfile -File scripts/Repair-Project.ps1 -Force

## docs-gen    Generate fresh PROJECT-STATS.md and stats summary
docs-gen:
	@pwsh -NoProfile -File scripts/Generate-Docs.ps1

## deps        Run CI workflow locally (requires act + Docker)
deps:
	@act -W .github/workflows/validate.yml

## update       Self-update from git remote (pull + validate)
update:
	@pwsh -NoProfile -File scripts/Update-Self.ps1 -Force
