#!/usr/bin/env python3
import re, json, sys, os, glob
from collections import defaultdict
ROOT = os.path.dirname(os.path.abspath(__file__)) + "/.."

def read(p):
    with open(p, "r", encoding="utf-8") as f:
        return f.read()

def load_strings(path):
    kv = {}
    if not os.path.isdir(path): return kv
    for fn in glob.glob(os.path.join(path, "*.strings")):
        with open(fn, "r", encoding="utf-8") as f:
            for line in f:
                m = re.match(r'\s*"([^"]+)"\s*=\s*"([^"]*)";', line)
                if m: kv[m.group(1)] = m.group(2)
    return kv

report = []

# --- L10n keys used in code
l10n_swift = os.path.join(ROOT, "JapaneseBuddy/Services/L10n.swift")
keys_used = set()
if os.path.exists(l10n_swift):
    raw_l10n = read(l10n_swift)
    keys_used.update(re.findall(r'NSLocalizedString\("([^"]+)"', raw_l10n))
    keys_used.update(re.findall(r'localized\("([^"]+)"', raw_l10n))
langs = {
  "Base": os.path.join(ROOT, "JapaneseBuddy/Resources/L10n/Base.lproj"),
  "en":   os.path.join(ROOT, "JapaneseBuddy/Resources/L10n/en.lproj"),
  "tr":   os.path.join(ROOT, "JapaneseBuddy/Resources/L10n/tr.lproj"),
  "ja":   os.path.join(ROOT, "JapaneseBuddy/Resources/L10n/ja.lproj"),
}
missing = { lg: sorted(list(keys_used - set(load_strings(path).keys()))) for lg, path in langs.items() }
extra   = { lg: sorted(list(set(load_strings(path).keys()) - keys_used)) for lg, path in langs.items() }

report.append("## Localization")
report.append(f"Keys in L10n.swift: {len(keys_used)}")
for lg in ["Base","en","tr","ja"]:
    report.append(f"- {lg}: missing {len(missing[lg])}, extra {len(extra[lg])}")

# --- Lessons & index
lessons_dir = os.path.join(ROOT, "JapaneseBuddy/Resources/lessons")
index_file = os.path.join(lessons_dir, "index.json")
idx = {}
if os.path.exists(index_file):
    try:
        idx = json.loads(read(index_file))
    except Exception as e:
        report.append(f"⚠️ index.json decode error: {e}")
else:
    report.append("⚠️ index.json not found")

def lesson_ok(js):
    # minimal structure check aligned with acceptance
    try:
        d = json.loads(js)
    except:
        return False
    if not isinstance(d, dict):
        return False
    if not ("id" in d and "activities" in d):
        return False
    activities = d.get("activities", [])
    kinds = [list(a.keys())[0] for a in activities if isinstance(a, dict) and a]

    # Find a shadow activity with >=2 segments
    shadow_ok = False
    for a in activities:
        if not isinstance(a, dict) or not a:
            continue
        if "shadow" in a and isinstance(a["shadow"], dict):
            segs = a["shadow"].get("segments", [])
            if isinstance(segs, list) and len(segs) >= 2:
                shadow_ok = True
                break

    # KanjiWords count should be at least 3
    kw = d.get("kanjiWords", [])
    kanji_ok = isinstance(kw, list) and len(kw) >= 3

    checks = [
        any(k == "objective" for k in kinds),
        shadow_ok,
        any(k == "listening" for k in kinds),
        any(k == "reading" for k in kinds),
        any(k == "check" for k in kinds),
        kanji_ok,
    ]
    return all(checks)

missing_lessons = []
bad_lessons = []
all_ids = []
# From index
for lvl, arr in idx.items():
    for lid in arr:
        path = os.path.join(lessons_dir, f"{lid}.json")
        if not os.path.exists(path):
            missing_lessons.append(lid)
        else:
            all_ids.append(lid)
            if not lesson_ok(read(path)):
                bad_lessons.append(lid)

# Also scan directory for extras
disk_lessons = [os.path.splitext(os.path.basename(p))[0] for p in glob.glob(os.path.join(lessons_dir, "*.json")) if os.path.basename(p) != "index.json"]
extras = sorted(set(disk_lessons) - set(all_ids))

report.append("\n## Lessons")
report.append(f"Indexed lessons: {len(all_ids)}; extras on disk: {len(extras)}")
if missing_lessons: report.append("Missing from disk: " + ", ".join(missing_lessons))
if bad_lessons: report.append("Fail structure check: " + ", ".join(bad_lessons))
if extras: report.append("Extras not in index: " + ", ".join(extras))

# --- Screenshots placeholders existence
shots = ["home.svg","lessons.svg","trace.svg","srs.svg"]
shot_missing = [s for s in shots if not os.path.exists(os.path.join(ROOT,"docs/screenshots",s))]
report.append("\n## Screenshots")
report.append("Missing placeholders: " + (", ".join(shot_missing) if shot_missing else "none"))

# Write report
out = os.path.join(ROOT, "REPORT-POSTMERGE.md")
with open(out, "w", encoding="utf-8") as f:
    f.write("\n".join(report))
print("Wrote", out)
# Exit non-zero if critical failures
crit = []
if missing["Base"]: crit.append("Base missing l10n keys")
if missing_lessons: crit.append("Indexed lessons missing on disk")
if bad_lessons: crit.append("Lessons failing structure check")
sys.exit(1 if crit else 0)
