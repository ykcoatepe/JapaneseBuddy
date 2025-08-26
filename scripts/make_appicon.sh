#!/usr/bin/env bash
set -euo pipefail

# Generate iPhone + iPad AppIcon set from a single square source image.
# Usage: scripts/make_appicon.sh "art/app icon.png"

SRC=${1:-}
APPICON_DIR="JapaneseBuddyProj/JapaneseBuddyProj/Assets.xcassets/AppIcon.appiconset"

if [[ -z "${SRC}" ]]; then
  echo "Usage: $0 path/to/source-square.png" >&2
  exit 1
fi

if [[ ! -f "${SRC}" ]]; then
  echo "Source file not found: ${SRC}" >&2
  exit 1
fi

command -v sips >/dev/null 2>&1 || { echo "This script requires 'sips' (macOS)." >&2; exit 1; }

mkdir -p "${APPICON_DIR}"

# Map of filename -> size
declare -A ICONS=(
  [iphone_20@2x.png]=40
  [iphone_20@3x.png]=60
  [iphone_29@2x.png]=58
  [iphone_29@3x.png]=87
  [iphone_40@2x.png]=80
  [iphone_40@3x.png]=120
  [iphone_60@2x.png]=120
  [iphone_60@3x.png]=180

  [ipad_20@1x.png]=20
  [ipad_20@2x.png]=40
  [ipad_29@1x.png]=29
  [ipad_29@2x.png]=58
  [ipad_40@1x.png]=40
  [ipad_40@2x.png]=80
  [ipad_76@1x.png]=76
  [ipad_76@2x.png]=152
  [ipad_83.5@2x.png]=167

  [marketing_1024.png]=1024
)

for name in "${!ICONS[@]}"; do
  px=${ICONS[$name]}
  out="${APPICON_DIR}/${name}"
  echo "Generating ${name} (${px}x${px})"
  sips -s format png -z ${px} ${px} "${SRC}" --out "${out}" >/dev/null
done

cat > "${APPICON_DIR}/Contents.json" <<'JSON'
{
  "images" : [
    {"idiom":"iphone","size":"20x20","scale":"2x","filename":"iphone_20@2x.png"},
    {"idiom":"iphone","size":"20x20","scale":"3x","filename":"iphone_20@3x.png"},
    {"idiom":"iphone","size":"29x29","scale":"2x","filename":"iphone_29@2x.png"},
    {"idiom":"iphone","size":"29x29","scale":"3x","filename":"iphone_29@3x.png"},
    {"idiom":"iphone","size":"40x40","scale":"2x","filename":"iphone_40@2x.png"},
    {"idiom":"iphone","size":"40x40","scale":"3x","filename":"iphone_40@3x.png"},
    {"idiom":"iphone","size":"60x60","scale":"2x","filename":"iphone_60@2x.png"},
    {"idiom":"iphone","size":"60x60","scale":"3x","filename":"iphone_60@3x.png"},

    {"idiom":"ipad","size":"20x20","scale":"1x","filename":"ipad_20@1x.png"},
    {"idiom":"ipad","size":"20x20","scale":"2x","filename":"ipad_20@2x.png"},
    {"idiom":"ipad","size":"29x29","scale":"1x","filename":"ipad_29@1x.png"},
    {"idiom":"ipad","size":"29x29","scale":"2x","filename":"ipad_29@2x.png"},
    {"idiom":"ipad","size":"40x40","scale":"1x","filename":"ipad_40@1x.png"},
    {"idiom":"ipad","size":"40x40","scale":"2x","filename":"ipad_40@2x.png"},
    {"idiom":"ipad","size":"76x76","scale":"1x","filename":"ipad_76@1x.png"},
    {"idiom":"ipad","size":"76x76","scale":"2x","filename":"ipad_76@2x.png"},
    {"idiom":"ipad","size":"83.5x83.5","scale":"2x","filename":"ipad_83.5@2x.png"},

    {"idiom":"ios-marketing","size":"1024x1024","scale":"1x","filename":"marketing_1024.png"}
  ],
  "info" : { "version" : 1, "author" : "script" }
}
JSON

echo "AppIcon set updated in ${APPICON_DIR}"

