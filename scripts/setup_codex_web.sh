#!/usr/bin/env bash
set -euo pipefail

# Codex Web setup helper
# - Ensures Node.js and pnpm are available
# - Optionally clones a Codex Web repo
# - Writes a .env.local with workspace defaults
# - Installs dependencies and can start the dev server

usage() {
  cat <<EOF
Usage: $0 [options]

Options:
  --web-dir DIR       Path to existing Codex Web project (e.g., ~/src/codex-web)
  --clone URL         Git URL to clone Codex Web (e.g., https://github.com/<org>/codex-web)
  --workspace DIR     Workspace directory to mount (default: current repo)
  --install           Run dependency installation in web dir (pnpm)
  --run               Start the dev server (pnpm dev)
  --no-env            Do not write/update .env.local
  -h, --help          Show this help

Notes:
  - Provide either --web-dir or --clone.
  - This script uses corepack to enable pnpm if available.
EOF
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: required command not found: $1" >&2
    exit 1
  fi
}

node_ok() {
  if ! command -v node >/dev/null 2>&1; then
    echo "Node.js not found. Install Node 18+ (e.g., via nvm or Homebrew)." >&2
    exit 1
  fi
  local MAJOR
  MAJOR=$(node -p 'process.versions.node.split(".")[0]')
  if [ "$MAJOR" -lt 18 ]; then
    echo "Node.js >= 18 is required. Found: $(node -v)" >&2
    exit 1
  fi
}

enable_pnpm() {
  if command -v corepack >/dev/null 2>&1; then
    corepack enable >/dev/null 2>&1 || true
    corepack prepare pnpm@8 --activate >/dev/null 2>&1 || true
  fi
  if ! command -v pnpm >/dev/null 2>&1; then
    echo "pnpm not found. Install with: npm i -g pnpm (or enable corepack)." >&2
    exit 1
  fi
}

WEB_DIR=""
CLONE_URL=""
WORKSPACE_DIR="$(pwd)"
DO_INSTALL=false
DO_RUN=false
WRITE_ENV=true

while [ "$#" -gt 0 ]; then
  case "$1" in
    --web-dir)
      WEB_DIR="$2"; shift 2;;
    --clone)
      CLONE_URL="$2"; shift 2;;
    --workspace)
      WORKSPACE_DIR="$2"; shift 2;;
    --install)
      DO_INSTALL=true; shift;;
    --run)
      DO_RUN=true; shift;;
    --no-env)
      WRITE_ENV=false; shift;;
    -h|--help)
      usage; exit 0;;
    *)
      echo "Unknown option: $1" >&2; usage; exit 1;;
  esac
done

node_ok
enable_pnpm

if [ -z "$WEB_DIR" ] && [ -z "$CLONE_URL" ]; then
  echo "Provide --web-dir or --clone." >&2
  usage
  exit 1
fi

if [ -n "$CLONE_URL" ]; then
  if [ -z "$WEB_DIR" ]; then
    WEB_DIR="$HOME/.codex-web"
  fi
  if [ -d "$WEB_DIR/.git" ]; then
    echo "Web dir already initialized: $WEB_DIR"
  else
    echo "Cloning Codex Web into $WEB_DIR ..."
    git clone "$CLONE_URL" "$WEB_DIR"
  fi
fi

if [ ! -d "$WEB_DIR" ]; then
  echo "Web dir does not exist: $WEB_DIR" >&2
  exit 1
fi

# Write .env.local with sensible defaults if requested
if [ "$WRITE_ENV" = true ]; then
  ENV_FILE="$WEB_DIR/.env.local"
  echo "Writing $ENV_FILE ..."
  cat > "$ENV_FILE" <<EOF
# Codex Web local configuration
# Adjust values to match your environment.

# Default workspace path for new sessions
CODEX_DEFAULT_WORKSPACE="$WORKSPACE_DIR"

# Sandbox and approval modes (examples; adjust if your web app uses different keys)
CODEX_FILESYSTEM_SANDBOX="workspace-write"
CODEX_NETWORK_SANDBOX="restricted"
CODEX_APPROVAL_MODE="on-request"

# Optional: port overrides
PORT=3000
EOF
fi

if [ "$DO_INSTALL" = true ]; then
  echo "Installing dependencies in $WEB_DIR ..."
  (cd "$WEB_DIR" && pnpm install)
fi

if [ "$DO_RUN" = true ]; then
  echo "Starting dev server in $WEB_DIR ..."
  (cd "$WEB_DIR" && pnpm dev)
else
  cat <<EOF

Done. Next steps:
  1) Review $WEB_DIR/.env.local and adjust as needed.
  2) Install deps:   (cd "$WEB_DIR" && pnpm install)
  3) Start server:   (cd "$WEB_DIR" && pnpm dev)

Tip: Re-run with --install and/or --run to automate steps 2–3.
EOF
fi

