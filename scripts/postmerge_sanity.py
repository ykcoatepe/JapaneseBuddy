#!/usr/bin/env python3
import re, json, sys, os, glob
from collections import Counter
ROOT = os.path.dirname(os.path.abspath(__file__)) + "/.."
MIN_LEVEL_COUNTS = {"A1": 8, "A2": 6, "B1": 8}

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
l10n_sources = [
    os.path.join(ROOT, "JapaneseBuddy/Services/L10n.swift"),
    os.path.join(ROOT, "JapaneseBuddy/Services/Speaker.swift"),
]
keys_used = set()
parsed_sources = []
for src in l10n_sources:
    if not os.path.exists(src):
        continue
    raw_l10n = read(src)
    keys_used.update(re.findall(r'NSLocalizedString\("([^"]+)"', raw_l10n))
    keys_used.update(re.findall(r'localized\("([^"]+)"', raw_l10n))
    parsed_sources.append(os.path.relpath(src, ROOT))
langs = {
  "Base": os.path.join(ROOT, "JapaneseBuddy/Resources/L10n/Base.lproj"),
  "en":   os.path.join(ROOT, "JapaneseBuddy/Resources/L10n/en.lproj"),
  "tr":   os.path.join(ROOT, "JapaneseBuddy/Resources/L10n/tr.lproj"),
  "ja":   os.path.join(ROOT, "JapaneseBuddy/Resources/L10n/ja.lproj"),
}
missing = { lg: sorted(list(keys_used - set(load_strings(path).keys()))) for lg, path in langs.items() }
extra   = { lg: sorted(list(set(load_strings(path).keys()) - keys_used)) for lg, path in langs.items() }
lesson_langs = {
  "Base": os.path.join(ROOT, "JapaneseBuddy/Resources/lessons/L10n/Base.lproj"),
  "en":   os.path.join(ROOT, "JapaneseBuddy/Resources/lessons/L10n/en.lproj"),
  "tr":   os.path.join(ROOT, "JapaneseBuddy/Resources/lessons/L10n/tr.lproj"),
  "ja":   os.path.join(ROOT, "JapaneseBuddy/Resources/lessons/L10n/ja.lproj"),
}
lesson_base_keys = set(load_strings(lesson_langs["Base"]).keys())
lesson_missing = {
    lg: sorted(list(lesson_base_keys - set(load_strings(path).keys())))
    for lg, path in lesson_langs.items()
}
lesson_extra = {
    lg: sorted(list(set(load_strings(path).keys()) - lesson_base_keys))
    for lg, path in lesson_langs.items()
}

report.append("## Localization")
report.append("Parsed key sources: " + (", ".join(parsed_sources) if parsed_sources else "none"))
report.append(f"Keys discovered: {len(keys_used)}")
for lg in ["Base","en","tr","ja"]:
    report.append(f"- {lg}: missing {len(missing[lg])}, extra {len(extra[lg])}")
report.append(f"Lesson L10n keys: {len(lesson_base_keys)}")
for lg in ["Base","en","tr","ja"]:
    report.append(f"- Lesson {lg}: missing {len(lesson_missing[lg])}, extra {len(lesson_extra[lg])}")

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
    flow_ok = kinds[:5] == ["objective", "shadow", "listening", "reading", "check"]
    text_ok = all(
        isinstance(d.get(field), str) and d[field].strip()
        for field in ["id", "title", "canDo"]
    )

    # Find required activities with non-empty learner-facing text.
    objective_ok = False
    shadow_ok = False
    mcq_ok = {"listening": False, "reading": False}
    for a in activities:
        if not isinstance(a, dict) or not a:
            continue
        if "objective" in a and isinstance(a["objective"], dict):
            text = a["objective"].get("text")
            objective_ok = isinstance(text, str) and bool(text.strip())
        if "shadow" in a and isinstance(a["shadow"], dict):
            segs = a["shadow"].get("segments", [])
            if (
                isinstance(segs, list)
                and len(segs) >= 2
                and all(isinstance(seg, str) and seg.strip() for seg in segs)
            ):
                shadow_ok = True
        for kind in ["listening", "reading"]:
            if kind in a and isinstance(a[kind], dict):
                prompt = a[kind].get("prompt")
                choices = a[kind].get("choices", [])
                answer = a[kind].get("answer")
                mcq_ok[kind] = (
                    isinstance(prompt, str)
                    and bool(prompt.strip())
                    and isinstance(choices, list)
                    and len(choices) >= 2
                    and all(isinstance(choice, str) and choice.strip() for choice in choices)
                    and len(set(choices)) == len(choices)
                    and isinstance(answer, int)
                    and 0 <= answer < len(choices)
                )

    # KanjiWords count should be at least 3 with usable practice fields.
    kw = d.get("kanjiWords", [])
    kanji_ok = (
        isinstance(kw, list)
        and len(kw) >= 3
        and all(
            isinstance(word, dict)
            and all(
                isinstance(word.get(field), str) and word[field].strip()
                for field in ["id", "kanji", "reading", "meaning"]
            )
            for word in kw
        )
    )

    checks = [
        text_ok,
        flow_ok,
        objective_ok,
        shadow_ok,
        mcq_ok["listening"],
        mcq_ok["reading"],
        any(k == "check" for k in kinds),
        kanji_ok,
    ]
    return all(checks)

def lesson_id_ok(index_id, js):
    try:
        d = json.loads(js)
    except:
        return False
    lesson_id = d.get("id") if isinstance(d, dict) else None
    path_code = "-".join(index_id.split("-")[:2])
    return isinstance(lesson_id, str) and lesson_id == path_code

def kanji_word_ids(js):
    try:
        d = json.loads(js)
    except:
        return []
    words = d.get("kanjiWords", []) if isinstance(d, dict) else []
    if not isinstance(words, list):
        return []
    return [word.get("id") for word in words if isinstance(word, dict)]

def path_number(lesson_id):
    match = re.match(r"^[A-Z][0-9]-(\d+)-", lesson_id)
    return int(match.group(1)) if match else None

missing_lessons = []
bad_lessons = []
bad_ids = []
bad_levels = []
bad_sequences = []
duplicate_kanji_ids = []
all_ids = []
level_counts = {}
# From index
for lvl, arr in idx.items():
    level_counts[lvl] = len(arr) if isinstance(arr, list) else 0
    if isinstance(arr, list):
        numbers = [path_number(lid) for lid in arr]
        expected = list(range(1, len(arr) + 1))
        if numbers != expected:
            bad_sequences.append(
                f"{lvl}: expected "
                + ", ".join(f"{n:02d}" for n in expected)
                + "; found "
                + ", ".join("--" if n is None else f"{n:02d}" for n in numbers)
            )
    for lid in arr:
        path = os.path.join(lessons_dir, f"{lid}.json")
        if not os.path.exists(path):
            missing_lessons.append(lid)
        else:
            all_ids.append(lid)
            js = read(path)
            if not lesson_id_ok(lid, js):
                bad_ids.append(lid)
            if not lid.startswith(f"{lvl}-"):
                bad_levels.append(lid)
            if not lesson_ok(js):
                bad_lessons.append(lid)
            word_counts = Counter(kanji_word_ids(js))
            duplicate_kanji_ids.extend(
                f"{lid}:{word_id}"
                for word_id, count in word_counts.items()
                if count > 1
            )

# Also scan directory for extras
disk_lessons = [
    os.path.splitext(os.path.basename(p))[0]
    for p in glob.glob(os.path.join(lessons_dir, "*.json"))
    if os.path.basename(p) != "index.json"
]
extras = sorted(set(disk_lessons) - set(all_ids))
duplicate_lessons = sorted([
    lesson_id
    for lesson_id, count in Counter(all_ids).items()
    if count > 1
])

report.append("\n## Lessons")
report.append(f"Indexed lessons: {len(all_ids)}; extras on disk: {len(extras)}")
if level_counts:
    levels = ", ".join(f"{level}: {level_counts[level]}" for level in sorted(level_counts))
    report.append(f"By level: {levels}")
required_total = sum(MIN_LEVEL_COUNTS.values())
report.append(
    "Required path coverage: "
    + ", ".join(f"{level}>={minimum}" for level, minimum in MIN_LEVEL_COUNTS.items())
    + f" (total>={required_total})"
)
if missing_lessons: report.append("Missing from disk: " + ", ".join(missing_lessons))
if duplicate_lessons: report.append("Duplicate index ids: " + ", ".join(duplicate_lessons))
if bad_ids: report.append("ID mismatch: " + ", ".join(bad_ids))
if bad_levels: report.append("Level mismatch: " + ", ".join(bad_levels))
if bad_sequences: report.append("Path sequence mismatch: " + " | ".join(bad_sequences))
if duplicate_kanji_ids: report.append("Duplicate kanji ids: " + ", ".join(duplicate_kanji_ids))
if bad_lessons: report.append("Fail structure check: " + ", ".join(bad_lessons))
if extras: report.append("Extras not in index: " + ", ".join(extras))

# --- Project gates
project_file = os.path.join(ROOT, "JapaneseBuddyProj/JapaneseBuddyProj.xcodeproj/project.pbxproj")
project_text = read(project_file) if os.path.exists(project_file) else ""
target_families = re.findall(r'TARGETED_DEVICE_FAMILY = "([^"]+)"', project_text)
ipad_targeted = any("2" in [part.strip() for part in family.split(",")] for family in target_families)
ipad_orientations = re.findall(r'INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "([^"]+)"', project_text)
ipad_landscape = any(
    "UIInterfaceOrientationLandscapeLeft" in orientations
    and "UIInterfaceOrientationLandscapeRight" in orientations
    for orientations in ipad_orientations
)
lessons_in_resources = "lessons in Resources" in project_text
makefile = os.path.join(ROOT, "Makefile")
makefile_text = read(makefile) if os.path.exists(makefile) else ""
ipad_test_first = "awk '/iPad/" in makefile_text
ipad_test_fallback = "iPad Pro 13-inch" in makefile_text

report.append("\n## Project")
report.append(f"iPad target family: {'yes' if ipad_targeted else 'no'}")
report.append(f"iPad landscape orientations: {'yes' if ipad_landscape else 'no'}")
report.append(f"Lessons folder in resources: {'yes' if lessons_in_resources else 'no'}")
report.append(f"make test prefers iPad: {'yes' if ipad_test_first else 'no'}")
report.append(f"make test iPad fallback: {'yes' if ipad_test_fallback else 'no'}")

swift_sources = [
    path
    for path in glob.glob(os.path.join(ROOT, "JapaneseBuddy/**/*.swift"), recursive=True)
]

# --- iPad UI gates
def source_contains(relative_path, needle):
    path = os.path.join(ROOT, relative_path)
    return os.path.exists(path) and needle in read(path)

split_view_ok = source_contains("JapaneseBuddy/App/AppSidebar.swift", "NavigationSplitView")
balanced_split_ok = source_contains("JapaneseBuddy/App/AppSidebar.swift", "navigationSplitViewStyle")
adaptive_layout_hits = [
    os.path.relpath(path, ROOT)
    for path in swift_sources
    if "GridItem(.adaptive" in read(path) or "GeometryReader" in read(path)
]
adaptive_layout_ok = len(adaptive_layout_hits) >= 5
dynamic_type_files = [
    "JapaneseBuddy/Features/Home/HomeView.swift",
    "JapaneseBuddy/Features/Practice/PracticeView.swift",
    "JapaneseBuddy/Features/KanaTraceView.swift",
    "JapaneseBuddy/Features/SRS/SRSView.swift",
    "JapaneseBuddy/Features/Lessons/LessonRunnerView.swift",
    "JapaneseBuddy/Features/StatsView.swift",
    "JapaneseBuddy/Features/Settings/SettingsView.swift",
    "JapaneseBuddy/Features/Onboarding/OnboardingView.swift",
]
missing_dynamic_type = [
    path for path in dynamic_type_files
    if not source_contains(path, "dynamicTypeSize")
]
accessibility_files = [
    "JapaneseBuddy/Features/Home/HomeView.swift",
    "JapaneseBuddy/Features/Home/DailyGoalCard.swift",
    "JapaneseBuddy/Features/Practice/PracticeView.swift",
    "JapaneseBuddy/Features/KanaTraceView.swift",
    "JapaneseBuddy/Features/SRS/SRSView.swift",
    "JapaneseBuddy/Features/Lessons/LessonListView.swift",
    "JapaneseBuddy/Features/Lessons/LessonRunnerView.swift",
    "JapaneseBuddy/Features/Lessons/ListeningView.swift",
    "JapaneseBuddy/Features/Lessons/ReadingView.swift",
    "JapaneseBuddy/Features/Lessons/CheckView.swift",
    "JapaneseBuddy/Features/Lessons/KanjiPracticeView.swift",
    "JapaneseBuddy/Features/StatsView.swift",
]
missing_accessibility = [
    path for path in accessibility_files
    if not source_contains(path, ".accessibility")
]

report.append("\n## iPad UI")
report.append(f"NavigationSplitView: {'yes' if split_view_ok else 'no'}")
report.append(f"Balanced split style: {'yes' if balanced_split_ok else 'no'}")
report.append(f"Adaptive layout files: {len(adaptive_layout_hits)}")
report.append(f"Adaptive layout coverage: {'yes' if adaptive_layout_ok else 'no'}")
report.append(f"Dynamic type coverage: {len(dynamic_type_files) - len(missing_dynamic_type)}/{len(dynamic_type_files)}")
report.append(f"Accessibility coverage: {len(accessibility_files) - len(missing_accessibility)}/{len(accessibility_files)}")
if missing_dynamic_type:
    report.append("Missing dynamic type: " + ", ".join(missing_dynamic_type))
if missing_accessibility:
    report.append("Missing accessibility: " + ", ".join(missing_accessibility))

# --- Privacy/offline gate
forbidden_network_patterns = [
    r"\bURLSession\b",
    r"\bNWConnection\b",
    r"\bimport\s+Network\b",
    r"\bFirebase\b",
    r"\bAnalytics\b",
    r"https?://",
]
network_hits = []
for path in swift_sources:
    rel = os.path.relpath(path, ROOT)
    text = read(path)
    for pattern in forbidden_network_patterns:
        if re.search(pattern, text):
            network_hits.append(f"{rel}:{pattern}")

report.append("\n## Privacy")
report.append(f"Swift sources scanned: {len(swift_sources)}")
report.append(f"Network or analytics references: {len(network_hits)}")
if network_hits:
    report.append("References: " + ", ".join(network_hits))

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
for lang in ["Base", "en", "tr", "ja"]:
    if missing[lang]:
        crit.append(f"{lang} missing l10n keys")
    if extra[lang]:
        crit.append(f"{lang} has extra l10n keys")
for lang in ["Base", "en", "tr", "ja"]:
    if lesson_missing[lang]:
        crit.append(f"Lesson {lang} missing l10n keys")
    if lesson_extra[lang]:
        crit.append(f"Lesson {lang} has extra l10n keys")
for required_level, minimum in MIN_LEVEL_COUNTS.items():
    if level_counts.get(required_level, 0) < minimum:
        crit.append(f"{required_level} has fewer than {minimum} indexed lessons")
if len(all_ids) < sum(MIN_LEVEL_COUNTS.values()):
    crit.append("Course path has too few indexed lessons")
if missing_lessons: crit.append("Indexed lessons missing on disk")
if duplicate_lessons: crit.append("Duplicate indexed lesson ids")
if bad_ids: crit.append("Indexed lessons have mismatched JSON ids")
if bad_levels: crit.append("Indexed lessons are under the wrong level")
if bad_sequences: crit.append("Indexed lesson path sequence is not contiguous")
if duplicate_kanji_ids: crit.append("Duplicate kanji word ids")
if bad_lessons: crit.append("Lessons failing structure check")
if not ipad_targeted: crit.append("Project does not target iPad")
if not ipad_landscape: crit.append("Project is missing iPad landscape orientations")
if not lessons_in_resources: crit.append("Lessons folder is not in resources")
if not ipad_test_first: crit.append("make test does not prefer iPad")
if not ipad_test_fallback: crit.append("make test is missing an iPad fallback device")
if not split_view_ok: crit.append("App shell does not use NavigationSplitView")
if not balanced_split_ok: crit.append("App shell does not set a split view style")
if not adaptive_layout_ok: crit.append("Not enough adaptive iPad layout surfaces")
if missing_dynamic_type: crit.append("Key learner surfaces are missing dynamic type coverage")
if missing_accessibility: crit.append("Key learner surfaces are missing accessibility coverage")
if network_hits: crit.append("Swift sources include network or analytics references")
sys.exit(1 if crit else 0)
