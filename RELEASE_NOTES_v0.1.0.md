# JapaneseBuddy v0.1.0 (RC1) — Release Notes

This release delivers the core learning loop, practice flows, and offline persistence with a lightweight settings experience.

## Highlights

- Lessons: ordered activities (Objective, Shadowing, Listening, Reading) with progress and a final check.
- Kanji tab: per-lesson kanji practice with SRS integration and progress tracking.
- Kana tracing: handwriting practice with optional stroke hints.
- Goals & reminders: daily new/review targets and a scheduled local notification.
- Backup & restore: export/import `deck.json` via share and Files picker.
- Onboarding: quick first-run setup and optional display name.
- Icon & theme: app icon plus light/dark theme polish.

## Details

- Lesson runner remembers your last step; resuming returns you to where you left off.
- Kanji practice automatically credits related vocab when appropriate.
- Stroke hints can be toggled in Settings under Tracing.
- Reminders respect iOS permission prompts; the time picker is disabled until enabled.
- Backup writes to `Documents/deck.json` atomically and can import validated JSON.

## Known Limitations

- Manual backup only: no iCloud/online sync and no background restores.
- Seed content: initial lessons/kanji only; broader coverage is planned.
- Reminder delivery depends on user permission and system focus modes.
- Stroke hints are limited to supported characters; complex glyphs may vary.
- iOS-only target; no iPad multitasking-specific layouts yet.
- Some settings subviews are namespaced fallbacks to avoid target-membership issues.

## Next Up

- Expand lesson catalog and kanji packs with richer audio.
- Fine-tune SRS intervals and add review session polish.
- Optional iCloud Drive backup and bulk import/export guardrails.
- Widgets and lock-screen reminder surfaces.
- Accessibility and localization pass; larger fonts and VoiceOver cues.
- Lightweight analytics-free insights (on-device) to track streaks and goals.

## Build & Test

- Build: `make build` (Xcode project + scheme).
- Tests: `make test` for XCTest on iOS Simulator.
- Lint/format: `make format && make lint`.

