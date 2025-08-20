# Contributing

This repo splits app code from the Xcode project shell to keep diffs clean and enable reuse.

## Architecture
- `JapaneseBuddy/`: Reusable app code (Features, Models, Services, Resources).
- `JapaneseBuddyProj/`: Xcode project that references sources from `JapaneseBuddy/` and contains the app target and tests.
- Entry point: `JapaneseBuddyProjApp` launches `HomeView` in a `NavigationStack` and injects `.environmentObject(DeckStore)`.

## Getting Started
- Xcode: Open `JapaneseBuddyProj/JapaneseBuddyProj.xcodeproj` and select the `JapaneseBuddyProj` scheme.
- Run: Product → Clean Build Folder (Option+Shift+Cmd+K) → Run (Cmd+R).
- CLI: `make build` and `make test` (requires full Xcode, not just Command Line Tools).

## Code Style
- Swift version: Swift 5.9+.
- SwiftLint: `make lint` (non-blocking).
- SwiftFormat: `make format`.
- File size: Prefer ≤150 LOC per file where practical.

## QA Invariants
- Tracing pass: `overlapScore >= 0.6` AND stroke count gate (`>= expected`, `<= expected + 1`).
- Persist `showStrokeHints` in `DeckStore.State` and expose a toggle in Settings.
- `SRSView` `Text` must not receive an optional.
- `CardType` includes `hiragana` and `katakana`.
- Canonical `KanaTraceView.swift` lives at `JapaneseBuddy/Features/KanaTraceView.swift`.

## State & Persistence
- `DeckStore` persists `deck.json` in the app’s Documents directory.
- Fields include: `cards`, `dailyGoal`, `notificationsEnabled`, `reminderTime`, `sessionLog`, `showStrokeHints`.

## Branching & Commits
- Keep changes focused; prefer small, reviewable diffs.
- Use descriptive commit messages (imperative mood), e.g.:
  - `Tidy: remove unused @main and template view`
  - `SRS: adjust ease factor for Hard rating`

## Adding Features
- Place new UI under `JapaneseBuddy/Features/<FeatureName>/`.
- Add models/services under `JapaneseBuddy/Models` or `JapaneseBuddy/Services` as appropriate.
- Wire navigation from `HomeView` where it makes sense.

## Tests
- Add unit tests under `JapaneseBuddyProj/JapaneseBuddyProjTests`.
- Run via Xcode or `make test`.

## Schemes
- The `JapaneseBuddyProj` scheme is shared so CI/teammates can build without manual setup.

