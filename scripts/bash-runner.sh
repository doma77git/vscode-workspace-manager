#!/usr/bin/env bash
# VS Code Workspace Manager — Bash Runner
# Fallback for systems without PowerShell 7+ (WSL, Linux, macOS)
# Usage: bash scripts/bash-runner.sh [validate|checks|test|all|help]

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TASK="${1:-help}"

# Colors
GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; NC='\033[0m'; BOLD='\033[1m'

banner() {
    echo -e "${CYAN}╭──────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│${NC}  ${BOLD}VS Code Workspace Manager${NC} — Bash Runner  ${CYAN}│${NC}"
    echo -e "${CYAN}╰──────────────────────────────────────╯${NC}"
    echo ""
}

ok()   { echo -e "  ${GREEN}✅${NC}  $1"; }
fail() { echo -e "  ${RED}❌${NC}  $1"; }
warn() { echo -e "  ${YELLOW}⚠️${NC}   $1"; }

# ── JSON Validation ──────────────────────────────
validate_json() {
    banner
    echo "  ── JSON Validation ──────────────────────────"
    local ok=0 fail=0
    while IFS= read -r -d '' f; do
        if command -v jq &>/dev/null; then
            if jq . "$f" > /dev/null 2>&1; then
                ok "$(basename "$f")" && ((ok++))
            else
                fail "$(basename "$f") — invalid JSON" && ((fail++))
            fi
        elif command -v python3 &>/dev/null; then
            if python3 -c "import json; json.load(open('$f'))" 2>/dev/null; then
                ok "$(basename "$f")" && ((ok++))
            else
                fail "$(basename "$f") — invalid JSON" && ((fail++))
            fi
        elif command -v node &>/dev/null; then
            if node -e "JSON.parse(require('fs').readFileSync('$f','utf8'))" 2>/dev/null; then
                ok "$(basename "$f")" && ((ok++))
            else
                fail "$(basename "$f") — invalid JSON" && ((fail++))
            fi
        else
            warn "No JSON validator found (install jq, python3, or node)"
            break
        fi
    done < <(find "$ROOT" -type f \( -name "*.json" -o -name "*.code-workspace" \) -not -path "*/.git/*" -print0)

    echo ""
    echo "  ── Result ────────────────────────────────────"
    if [ "$fail" -eq 0 ]; then
        ok "All $ok file(s) validated successfully"
    else
        fail "$ok passed, $fail failed"
    fi
    return $fail
}

# ── Secret Scan ──────────────────────────────────
scan_secrets() {
    echo "  ── Secret Scan ───────────────────────────────"
    local found=0
    local pattern='(password|secret|api[_-]?key|token|private_key)'
    # Exclude docs, known-safe files
    while IFS= read -r -d '' f; do
        local name=$(basename "$f")
        # Skip .md, .txt, .editorconfig, known-safe
        case "$name" in
            *.md|*.txt|.editorconfig|.gitignore) continue ;;
            deepseek-byok.json|deepseek-keys.json) continue ;;
            Init-TemplatesRepo.ps1|Run-Checks.ps1|WorkspaceManager.ps1|Makefile|bash-runner.sh) continue ;;
        esac
        if grep -E -n -i "$pattern" "$f" 2>/dev/null; then
            warn "$name — potential secret pattern"
            found=1
        fi
    done < <(find "$ROOT" -type f -not -path "*/.git/*" -not -path "*/.github/*" -print0)

    if [ "$found" -eq 0 ]; then
        ok "No secrets detected"
    fi
    return $found
}

# ── Full Checks ──────────────────────────────────
run_checks() {
    banner
    echo "  ── Step 1/2 : JSON Validation ───────────────"
    validate_json
    local vret=$?
    echo ""
    echo "  ── Step 2/2 : Secret Scan ───────────────────"
    scan_secrets
    local sret=$?
    echo ""
    if [ $vret -eq 0 ] && [ $sret -eq 0 ]; then
        ok "ALL CHECKS PASSED"
    else
        fail "SOME CHECKS FAILED"
    fi
    return $(( vret + sret ))
}

# ── Quick Stats ──────────────────────────────────
run_stats() {
    banner
    echo "  ── Project Stats ─────────────────────────────"
    local scripts=$(find "$ROOT/scripts" -name "*.ps1" 2>/dev/null | wc -l)
    local docs=$(find "$ROOT/docs" -name "*.md" 2>/dev/null | wc -l)
    local templates=$(find "$ROOT/templates" -name "*.code-workspace" 2>/dev/null | wc -l)
    local profiles=$(find "$ROOT/profiles" -name "*.json" 2>/dev/null | wc -l)
    local prompts=$(find "$ROOT/prompts" -name "*.md" 2>/dev/null | wc -l)
    ok "Scripts   : $scripts"
    ok "Docs      : $docs"
    ok "Templates : $templates"
    ok "Profiles  : $profiles"
    ok "Prompts   : $prompts"
    local version=$(grep -m1 '^## \[' "$ROOT/CHANGELOG.md" 2>/dev/null | sed 's/## \[\(.*\)\].*/\1/' || echo "unknown")
    ok "Version   : $version"
}

# ── Parallel Runner ──────────────────────────────
run_parallel() {
    banner
    echo "  ── Parallel Execution ────────────────────────"
    local pids=()
    echo "  Starting validate in background..."
    validate_json & pids+=($!)
    echo "  Starting secret scan in background..."
    scan_secrets & pids+=($!)
    echo "  Starting stats in background..."
    run_stats & pids+=($!)
    echo ""
    echo "  Waiting for all tasks to complete..."
    for pid in "${pids[@]}"; do wait $pid; done
    echo ""
    ok "All parallel tasks completed"
}

# ── Help ─────────────────────────────────────────
show_help() {
    banner
    echo "  Usage: bash scripts/bash-runner.sh [task]"
    echo ""
    echo "  Tasks:"
    echo "    validate    Validate all JSON files"
    echo "    checks      Full validation + secret scan"
    echo "    scan        Secret scan only"
    echo "    stats       Project statistics"
    echo "    parallel    Run all checks in parallel"
    echo "    help        This help"
    echo ""
    echo "  For full features, install PowerShell 7+:"
    echo "    https://github.com/PowerShell/PowerShell"
}

# ── Main ─────────────────────────────────────────
case "$TASK" in
    validate)  validate_json ;;
    checks)    run_checks ;;
    scan)      banner; scan_secrets ;;
    stats)     run_stats ;;
    parallel)  run_parallel ;;
    *)         show_help ;;
esac
