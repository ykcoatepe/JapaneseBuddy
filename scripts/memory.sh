#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE="$ROOT_DIR/.codex/state.json"
SESS_DIR="$ROOT_DIR/.codex/sessions"
CHECKS_DIR="$ROOT_DIR/.codex/checks"
SANITY_MD="$CHECKS_DIR/sanity.md"
PROGRESS_MD="$ROOT_DIR/PROGRESS.md"

ensure() {
  mkdir -p "$SESS_DIR" "$CHECKS_DIR"
  if [[ ! -f "$STATE" ]]; then
    cat >"$STATE" <<'JSON'
{
  "plan": [],
  "next_step": "",
  "blockers": [],
  "decisions": [],
  "context_notes": [],
  "last_updated": ""
}
JSON
  fi
}

append_note() {
  ensure
  local msg=${1:-}
  if [[ -z "$msg" ]]; then
    echo "Usage: $0 append \"note text\"" >&2; exit 1
  fi
  local day
  day=$(date +%F)
  local file="$SESS_DIR/$day.md"
  # avoid printf parsing '-' as an option by using '--'
  printf -- "- %s %s\n" "$(date -u +%FT%TZ)" "$msg" >> "$file"
}

sanity() {
  ensure
  # Collect quick static signals. Keep portable (Linux/macOS).
  {
    echo "# Sanity Snapshot"
    echo
    echo "- Updated: $(date -u +%FT%TZ)"
    echo
    echo "## Project"
    if [[ -f "$ROOT_DIR/JapaneseBuddyProj/JapaneseBuddyProj.xcodeproj/project.pbxproj" ]]; then
      echo "- xcodeproj: present"
    else
      echo "- xcodeproj: missing"
    fi
    echo
    echo "## Lessons Wiring"
    grep -R "lessons/A1-01-Greetings.json" -n "$ROOT_DIR/JapaneseBuddyProj/JapaneseBuddyProj.xcodeproj/project.pbxproj" >/dev/null 2>&1 && echo "- A1-01 present in project" || echo "- A1-01 missing in project"
    grep -R "lessons/A1-04-WhereYouLive.json" -n "$ROOT_DIR/JapaneseBuddyProj/JapaneseBuddyProj.xcodeproj/project.pbxproj" >/dev/null 2>&1 && echo "- A1-04 present in project" || echo "- A1-04 missing in project"
    echo
    echo "## Loader Checks"
    grep -n 'urls(forResourcesWithExtension: "json", subdirectory: "lessons")' "$ROOT_DIR/JapaneseBuddy/Services/LessonStore.swift" || true
    grep -n 'subdirectory: nil' "$ROOT_DIR/JapaneseBuddy/Services/LessonStore.swift" || true
  } > "$SANITY_MD"
}

progress() {
  ensure
  # Update last_updated inline without requiring jq.
  local iso
  iso=$(date -u +%FT%TZ)
  # Create a temp state with updated last_updated
  awk -v ts="$iso" 'BEGIN{updated=0} {
    if ($0 ~ /"last_updated"/) { print "  \"last_updated\": \"" ts "\","; updated=1; next }
    print
  } END { if (!updated) print "  \"last_updated\": \"" ts "\"" }' "$STATE" > "$STATE.tmp" || true
  mv "$STATE.tmp" "$STATE"

  # Rewrite PROGRESS.md Updated line
  if [[ -f "$PROGRESS_MD" ]]; then
    awk -v ts="$iso" 'NR==1{print; next} NR==2{sub(/Updated:.*/, "Updated: " ts); print; next} {print}' "$PROGRESS_MD" > "$PROGRESS_MD.tmp" || true
    mv "$PROGRESS_MD.tmp" "$PROGRESS_MD"
  fi
}

case ${1:-} in
  init) ensure ;;
  append) shift; append_note "$*" ;;
  sanity) sanity ;;
  progress) progress ;;
  recall)
    ensure
    iso=$(date -u +%FT%TZ)
    echo "# Recall Summary"
    echo
    echo "- Updated: $iso"
    echo
    if [[ -f "$STATE" ]]; then
      echo "## Next Step"
      awk -F '"' '/"next_step"/ { print "- " $4 }' "$STATE" || true
      echo
      echo "## Plan"
      awk '
        /\"plan\"[[:space:]]*:/ { inplan=1; next }
        inplan && /\]/ { inplan=0 }
        inplan {
          if ($0 ~ /\"step\"[[:space:]]*:/) {
            line=$0; sub(/.*\"step\"[[:space:]]*:[[:space:]]*\"/, "", line); sub(/\".*/, "", line); step=line
          }
          if ($0 ~ /\"status\"[[:space:]]*:/) {
            line=$0; sub(/.*\"status\"[[:space:]]*:[[:space:]]*\"/, "", line); sub(/\".*/, "", line); status=line
            if (length(step) > 0 && length(status) > 0) { print "- " step " (" status ")" }
            step=""; status=""
          }
        }
      ' "$STATE" || true
      echo
      echo "## Decisions (recent)"
      awk '
        /\"decisions\"[[:space:]]*:/ { indec=1; count=0; next }
        indec && /\]/ { indec=0 }
        indec && count<3 {
          # extract text between the first pair of double quotes on the line
          s=$0; i=index(s, "\""); if (i>0) { rest=substr(s, i+1); j=index(rest, "\""); if (j>0) { line=substr(rest, 1, j-1); if (length(line)>0) { print "- " line; count++ } } }
        }
      ' "$STATE" || true
      echo
    fi
    echo "## Latest Session"
    if [[ -d "$SESS_DIR" ]]; then
      latest=$(ls -1 "$SESS_DIR" 2>/dev/null | sort | tail -1)
      if [[ -n "$latest" && -f "$SESS_DIR/$latest" ]]; then
        echo "- File: $latest"
        tail -n 5 "$SESS_DIR/$latest" || true
      else
        echo "- No session notes yet"
      fi
    else
      echo "- Sessions directory missing"
    fi
    ;;
  *) echo "Usage: $0 {init|append <msg>|sanity|progress}" >&2; exit 1 ;;
esac
