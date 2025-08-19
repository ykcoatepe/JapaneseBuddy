#!/usr/bin/env bash
set -euo pipefail

# List available iOS simulators and connected physical devices with UDIDs.
# Requires Xcode command line tools.

if ! command -v xcrun >/dev/null 2>&1; then
  echo "xcrun not found. Install Xcode command line tools." >&2
  exit 1
fi

# Prefer xctrace (newer) but fall back to instruments if needed.
if xcrun xctrace list devices >/dev/null 2>&1; then
  echo "=== Devices (xctrace) ==="
  # Filter to iOS/tvOS/watchOS and physical devices; still prints simulators for reference
  xcrun xctrace list devices | sed -n '1,200p'
  exit 0
fi

if xcrun instruments -s devices >/dev/null 2>&1; then
  echo "=== Devices (instruments) ==="
  xcrun instruments -s devices | sed -n '1,200p'
  exit 0
fi

echo "Unable to list devices with xctrace or instruments." >&2
exit 1

