# Project Progress

- Updated: 2026-02-15T18:22:13Z

## Current Plan

See `.codex/state.json` for machine-readable plan. This section is auto-updated by CI.

## Done Since Last Update

- Lessons JSON bundled via blue folder `lessons`.
- LessonStore logs gated under DEBUG; flat-bundle fallback supported.
- JSON decode compatibility for reading `items`/`choices`.
- Xcode project tidy:
  - Added missing target membership (Lesson views, LessonListView, LessonProgress, LessonStore).
  - Removed duplicate App.swift compile entry.
  - Ensured `lessons` folder is in Copy Bundle Resources.
- Settings: iOS 17-safe onChange compatibility wrapper.
- Persistence: DeckStore writes now use `Data.WritingOptions[.atomic]`.
- Onboarding: Full-screen hero uses aspect-fit (no cropping) and a proportional invisible "Get Started" hotspot; falls back to `art/wellcome_1.png`.
- Assets: Removed invalid PDF icon; added `scripts/make_appicon.sh` to generate full AppIcon set.
- Project: Added `art/` folder reference to Copy Bundle Resources.

## Next Up

- Open RC1 PR (title/body ready in `PR_TITLE.txt` and `PR_BODY.md`).
- Run quick on-device A1 smoke (launch, Lessons nav, one lesson flow) before merge.
- Keep repo memory up-to-date via `.codex/` and CI workflow.

## Blockers

- None reported.

## Decisions

- Use blue folder reference for `lessons`.
- Gate runtime diagnostics under DEBUG.
- Accept both `items` and `choices` for reading activities.
- Load welcome image from `art/` at runtime; keep page simple and accessible.
- Generate icons via script using macOS `sips` tool.

## Sanity Snapshot

Latest: `.codex/checks/sanity.md` (auto-generated)
