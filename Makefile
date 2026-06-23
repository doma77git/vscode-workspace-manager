# VS Code Workspace Manager — Makefile
# Run targets from Git Bash (Windows) or any POSIX shell.
# Prerequisites: pwsh 7+, git, code CLI

# Detect PowerShell
PWSH := $(shell command -v pwsh 2>/dev/null)
ifeq ($(PWSH),)
$(error PowerShell 7+ (pwsh) is required but not found. Install: https://github.com/PowerShell/PowerShell)
endif

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

## doctor      Full environment health check + prerequisites
doctor:
	@pwsh -NoProfile -File scripts/Check-Environment.ps1

## clean       Remove export archives
clean:
	@rm -rf exports/

## backup      Back up templates, profiles, and meta to timestamped zip
backup:
	@pwsh -NoProfile -File scripts/Auto-Backup.ps1

## schedule    Show or manage scheduled tasks
schedule:
	@pwsh -NoProfile -File scripts/Schedule-Tasks.ps1 -Action list

## recommend   Recommend VS Code extensions for a project (set PATH=)
recommend:
	@pwsh -NoProfile -File scripts/Recommend-Extensions.ps1 -Path $(or $(PATH),.)

## runner      Universal launcher — interactive or by task name
runner:
	@pwsh -NoProfile -File scripts/Runner.ps1

## repair      Auto-repair common issues (JSON, line endings, dirs, hooks)
repair:
	@pwsh -NoProfile -File scripts/Repair-Project.ps1 -Force

## docs-gen    Generate fresh PROJECT-STATS.md and stats summary
docs-gen:
	@pwsh -NoProfile -File scripts/Generate-Docs.ps1

## compile     Compile all scripts into deployable module (+ zip)
compile:
	@pwsh -NoProfile -File scripts/Compile-Module.ps1 -Zip

## export      Export .vscode/ files from a template to a project
export:
	@pwsh -NoProfile -File scripts/Export-Workspace.ps1 -OutputDir .

## ext-check   Verify all recommended extensions are installable
ext-check:
	@pwsh -NoProfile -File scripts/Check-Extensions.ps1

## deps        Run CI workflow locally (requires act + Docker)
deps:
	@act -W .github/workflows/validate.yml

## update       Self-update from git remote (pull + validate)
update:
	@pwsh -NoProfile -File scripts/Update-Self.ps1 -Force
