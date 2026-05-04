# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

### Added
- Guided A1/A2/B1 lesson path with 22 indexed can-do lessons, path ordering, next-lesson unlocks, and per-lesson completion tracking.
- iPad-first app shell with `NavigationSplitView`, refreshed Home/Lessons/Practice/Review/Stats/Settings surfaces, and shared UI components.
- Daily lesson-goal tracking, onboarding goal setup, lesson completion logging, and active-target regression specs for goal/path behavior.
- Optional local audio packs for shadowing segments with built-in ja-JP text-to-speech fallback.

### Changed
- Documentation and sanity reports now cover localization parity, iPad project settings, content structure, privacy checks, and the goal-completion audit.
- `make test` now prefers an available iPad simulator and supports `SIM_DEVICE` overrides with names containing spaces.

### Fixed
- Preserved legacy deck compatibility for daily goals and study logs while adding lesson completion metrics.
- Ensured local audio playback and TTS do not overlap when switching between bundled audio and fallback speech.

## [0.1.0-rc1] - 2025-08-26

### Added
- Lessons: activity runner (Objective, Shadowing, Listening, Reading) with progress tracking and final check.
- Kanji practice tab for lesson kanji words; integrates with SRS and respects stroke-hint setting.
- Kana tracing practice with optional stroke hints.
- Daily goals and reminder scheduling (local notifications) in Settings.
- Backup & Restore: export/import `deck.json` via share sheet / Files.
- Onboarding flow and profile display name.
- App icon and light/dark theme polish.

### Changed
- Deck persistence unified into `deck.json` with atomic writes and reload support.
- SRS interactions updated to log kanji/vocab progress within lessons.

### Fixed
- Resolved `LessonRunnerView` builder inference compile error in `contentView`.
- Settings build issue when `BackupSection.swift` not in target; added namespaced fallback `SettingsBackupSection`.
- Improved save stability and error logging for persistence.

### Docs
- README improvements and initial reports.
- Added release notes for v0.1.0.
- Documented Makefile targets for build/test/lint/format.
