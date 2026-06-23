# VS Code Workspace Manager — Makefile
# Run targets from Git Bash (Windows) or any POSIX shell.
# Prerequisites: pwsh 7+, git, code CLI

# Detect PowerShell
PWSH := $(shell command -v pwsh 2>/dev/null)
BASH_RUNNER := scripts/bash-runner.sh

# Fallback to bash runner if pwsh not found
ifneq ($(PWSH),)
  VALIDATE_CMD = @$(PWSH) -NoProfile -File scripts/Run-Validate.ps1
  CHECKS_CMD   = @$(PWSH) -NoProfile -File scripts/Run-Checks.ps1
  TEST_CMD     = @$(PWSH) -NoProfile -File scripts/Run-Tests.ps1
  ALL_CMD      = @$(PWSH) -NoProfile -File scripts/Run-All.ps1
  INSTALL_CMD  = @$(PWSH) -NoProfile -ExecutionPolicy Bypass -File scripts/Init-TemplatesRepo.ps1
  DOCTOR_CMD   = @$(PWSH) -NoProfile -File scripts/Check-Environment.ps1
  REPAIR_CMD   = @$(PWSH) -NoProfile -File scripts/Repair-Project.ps1 -Force
  BACKUP_CMD   = @$(PWSH) -NoProfile -File scripts/Auto-Backup.ps1
  UPDATE_CMD   = @$(PWSH) -NoProfile -File scripts/Update-Self.ps1 -Force
else
  $(warning PowerShell (pwsh) not found — using bash fallback. Install pwsh for full features.)
  VALIDATE_CMD = @bash $(BASH_RUNNER) validate
  CHECKS_CMD   = @bash $(BASH_RUNNER) checks
  TEST_CMD     = @echo "[SKIP] pwsh required for tests — using bash validate only" && bash $(BASH_RUNNER) validate
  ALL_CMD      = @bash $(BASH_RUNNER) checks
  INSTALL_CMD  = @echo "[SKIP] pwsh required for full install"
  DOCTOR_CMD   = @bash $(BASH_RUNNER) stats
  REPAIR_CMD   = @echo "[SKIP] pwsh required for repair"
  BACKUP_CMD   = @echo "[SKIP] pwsh required for backup"
  UPDATE_CMD   = @echo "[SKIP] pwsh required for self-update"
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
	$(VALIDATE_CMD)

## checks      Run full checks (validate + secret scan)
checks:
	$(CHECKS_CMD)

## test         Run tests (PowerShell syntax + JSON validation)
test:
	$(TEST_CMD)

## all          Run all operations (test + validate + checks + doctor)
all:
	$(ALL_CMD)

## install     Initialize the repo (one-time) and install pre-commit hook
install:
	$(INSTALL_CMD)

## doctor      Full environment health check + prerequisites
doctor:
	$(DOCTOR_CMD)

## clean       Remove export archives
clean:
	@rm -rf exports/

## backup      Back up templates, profiles, and meta to timestamped zip
backup:
	$(BACKUP_CMD)

## schedule    Show or manage scheduled tasks
schedule:
	@pwsh -NoProfile -File scripts/Schedule-Tasks.ps1 -Action list

## recommend   Recommend VS Code extensions for a project (set PATH=)
recommend:
	@pwsh -NoProfile -File scripts/Recommend-Extensions.ps1 -Path $(or $(PATH),.)

## maintain    Full maintenance: test → repair → backup → docs → clean
maintain:
	@pwsh -NoProfile -File scripts/Maintain-Project.ps1

## auto-launch Register auto-start on system boot
auto-launch:
	@pwsh -NoProfile -File scripts/Auto-Launch.ps1 -Action status

## reasonix    Launch with Reasonix context pre-loaded
reasonix:
	@pwsh -NoProfile -File scripts/Launch-Reasonix.ps1

## runner      Universal launcher — interactive or by task name
runner:
	@pwsh -NoProfile -File scripts/Runner.ps1

## parallel    Run validate + scan + stats in parallel (bash)
parallel:
	@bash scripts/bash-runner.sh parallel

## repair      Auto-repair common issues (JSON, line endings, dirs, hooks)
repair:
	$(REPAIR_CMD)

## update-gists Auto-update prompt files with live stats
update-gists:
	@pwsh -NoProfile -File scripts/Update-Gists.ps1

## docs-gen    Generate fresh PROJECT-STATS.md and stats summary
docs-gen:
	@pwsh -NoProfile -File scripts/Generate-Docs.ps1
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
	$(UPDATE_CMD)
