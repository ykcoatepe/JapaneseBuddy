#!/usr/bin/env bash
# Codex Web environment setup for JapaneseBuddy
# - Safe to run on macOS or Linux containers
# - Skips Xcode steps unless available (macOS)
# - Controlled by ENV flags; no network installs by default

set -euo pipefail

echo "[codex-setup] Starting setup for JapaneseBuddy..."

OS="$(uname -s)"
IS_MAC=false
if [ "$OS" = "Darwin" ]; then IS_MAC=true; fi

# Flags (override via environment)
: "${RUN_FORMAT:=1}"        # run swiftformat if available
: "${RUN_LINT:=1}"          # run swiftlint if available
: "${RUN_XCODEBUILD:=0}"    # run make build/test if xcodebuild exists

# Make Git happy inside containerized/sandboxed environments
git config --global --add safe.directory "$(pwd)" || true

# Summary
echo "[codex-setup] OS=$OS macOS=$IS_MAC RUN_FORMAT=$RUN_FORMAT RUN_LINT=$RUN_LINT RUN_XCODEBUILD=$RUN_XCODEBUILD"

# Run format if available
if [ "$RUN_FORMAT" = "1" ] && command -v swiftformat >/dev/null 2>&1; then
  echo "[codex-setup] Running swiftformat..."
  swiftformat . || true
else
  echo "[codex-setup] Skipping swiftformat (not installed or disabled)."
fi

# Run lint if available
if [ "$RUN_LINT" = "1" ] && command -v swiftlint >/dev/null 2>&1; then
  echo "[codex-setup] Running swiftlint..."
  swiftlint || true
else
  echo "[codex-setup] Skipping swiftlint (not installed or disabled)."
fi

# Build/test only on macOS with Xcode present
if [ "$RUN_XCODEBUILD" = "1" ] && $IS_MAC && command -v xcodebuild >/dev/null 2>&1; then
  echo "[codex-setup] xcodebuild detected. Running make build/test..."
  make build || true
  make test || true
else
  echo "[codex-setup] Skipping xcodebuild (not macOS, not installed, or disabled)."
fi

echo "[codex-setup] Done. Next: open README.md or run 'make lint'/'make format'."

