# Repository Guidelines

## Project Structure & Module Organization
- `JapaneseBuddy/`: App source (Features, Models, Services, Resources).
- `JapaneseBuddyProj/`: Xcode app shell and shared schemes.
- `JapaneseBuddyTests/`: Unit tests (XCTest).
- `JapaneseBuddy/Resources/lessons/`: Lesson JSON and `index.json` ordering.
- `scripts/`: Utility scripts (e.g., `csv_to_lessons.py`).

## Build, Test, and Development Commands
- Build: `make build` — xcodebuild for scheme `JapaneseBuddyProj` (iOS Simulator).
- Test: `make test` — runs XCTest targets.
- Lint: `make lint` — runs SwiftLint (non-fatal if missing).
- Format: `make format` — runs SwiftFormat across the repo.
Open in Xcode and run the `JapaneseBuddyProj` scheme for local development.

## Coding Style & Naming Conventions
- Swift style enforced via `.swiftlint.yml`; max line length 140; opt-in rules include `explicit_init`, `first_where`.
- Run `make format` before PRs. Prefer small, focused changes.
- Naming: `UpperCamelCase` types/protocols; `lowerCamelCase` vars/functions; `enum` cases lowerCamel.
- Keep Swift files ≤150 LOC when practical; avoid one-letter identifiers.

## Testing Guidelines
- Framework: XCTest; tests live under `JapaneseBuddyTests/` and project test targets.
- Name tests `*Tests.swift`; one concern per test; keep fixtures minimal.
- Run `make test` locally before pushing. Add tests for bug fixes and new behavior.

## Commit & Pull Request Guidelines
- Commits: Conventional Commits style (e.g., `feat(lessons): add A2 units`, `fix(audio): activate session for TTS`).
- PRs: clear title and description, linked issue(s), screenshots for UI changes, and brief test notes.
- Keep PRs small and reviewable; note any follow-ups.

## Architecture & Resources
- Lessons are data-driven. Add JSON files under `JapaneseBuddy/Resources/lessons/` and update `index.json` for ordering. In Xcode, ensure JSONs are included in “Copy Bundle Resources” or use the blue folder reference.
- `LessonStore` prefers the `lessons` subdirectory at runtime and falls back to flat bundle JSONs.

## Security & Configuration Tips
- No external analytics; all data is on-device. Do not commit secrets.
- Use simulator-safe destinations in CI; avoid device-only settings in project files.

