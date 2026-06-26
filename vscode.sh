#!/usr/bin/env bash
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
pwsh -NoProfile -ExecutionPolicy Bypass -File "$SCRIPT_DIR/vscode.ps1" "$@"
exit $?
