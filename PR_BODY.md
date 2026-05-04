Summary

This PR expands JapaneseBuddy into a guided iPad-first Japanese learning app. It adds a 22-lesson A1/A2/B1 path, next-lesson progression, daily lesson goals, refreshed iPad navigation, local audio fallback, localization parity, and regression coverage for the new course path and goal logic.

What changed

- Guided learning path
  - Added 22 indexed can-do lessons across A1:8, A2:6, and B1:8
  - Added path metadata, level filters, locked/next/completed states, and next-lesson flow
  - Lesson completion now counts toward daily lesson goals without double-counting study duration
- iPad-first product surface
  - App-wide `NavigationSplitView` shell with Home, Lessons, Practice, Review, Stats, and Settings
  - Refreshed lesson runner, tracing, SRS, stats, onboarding, backup/restore, and settings surfaces
  - Shared components and progress UI tightened for large iPad layouts, Dynamic Type, and accessibility
- Practice loop
  - Kana tracing, lesson runner, kanji/vocab practice, SRS review, daily goals, streaks, and weekly minutes are connected into one learning loop
  - Optional local shadowing audio under `Resources/lessons/audio`, with ja-JP TTS fallback when files are missing
- Localization and content health
  - Base/en/tr/ja strings mirrored across app and bundled lesson localization folders
  - `scripts/postmerge_sanity.py` now validates lesson structure, localization parity, iPad project gates, accessibility coverage, and privacy checks
- Tests and verification
  - Added active-target Swift Testing specs for goal progress and lesson path ordering
  - `make test` now prefers an available iPad simulator and handles `SIM_DEVICE` names with spaces

Acceptance checks

- `make sanity`: passed
- `git diff --check`: passed
- SwiftLint touched files: 0 violations
- `xcodebuild ... -only-testing:JapaneseBuddyProjTests test`: passed with 2 XCTest tests and 13 Swift Testing tests
- Independent `codex review --uncommitted`: no discrete actionable bugs
- Earlier full `make test` passed on iPad Pro 13-inch (M5), including UI launch/navigation tests

Known verification note

- Latest full UI reruns on iPad Air 13-inch (M4) hit a CoreSimulator `SBMainWorkspace` Busy / preflight launch error. Build and target-scoped app/unit tests still pass, and the audit records this as simulator service instability rather than a source regression.

Documentation

- README, docs index, architecture, contributing, screenshot guidance, release notes, changelog, and goal-completion audit now describe the shipped A1/A2/B1 iPad learning app.

Rollback

- Revert this PR. No destructive data migration is required because new deck fields are optional/backward-compatible.
