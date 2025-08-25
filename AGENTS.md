# Repository Guidelines

## Project Structure & Module Organization
- `JapaneseBuddy/`: app sources
  - `Features/`: SwiftUI views (Home, SRS, Lessons, Onboarding, Practice)
  - `Models/`: core types (Card, SRS, Lesson, Goal)
  - `Services/`: persistence, speech, drawing, notifications, logging
  - `Resources/lessons/`: seed lesson JSONs (e.g., `A1-05-Prices.json`)
- `JapaneseBuddyTests/`: XCTest targets (unit/UI). Keep test helpers here.
- `docs/`, `prompts/`, `scripts/`: notes, briefs, local utilities.
- `.codex/`: lightweight in-repo memory (state, sessions, sanity snapshot).

## Build, Test, and Development Commands
- `make build`: build via Xcode (`-project JapaneseBuddyProj.xcodeproj -scheme JapaneseBuddyProj`).
- `make test`: run XCTest for the same scheme on iOS Simulator.
- `make lint`: run SwiftLint (non-failing locally).
- `make format`: apply SwiftFormat to the repo.
Example: `make format && make lint && make test` before opening a PR.

## Coding Style & Naming Conventions
- Swift 5.9+, SwiftUI. Indent 4 spaces; max line length 140.
- One primary type per file; keep files ≤150 LOC where practical.
- Naming: PascalCase types; camelCase vars/methods; use snake_case for files mirroring resources only.
- Tools: SwiftFormat + SwiftLint; prefer safe optionals over force-unwrapping.

## Testing Guidelines
- Frameworks: XCTest unit tests; minimal UI smoke as needed.
- Location: `JapaneseBuddyTests/*.swift` (e.g., `SRSProgressionTests.swift`).
- Scope: prioritize SRS progression, deck persistence, lesson decoding, simple navigation.
- Run: `make test`. Name tests `*Tests.swift` and keep them deterministic.

## Commit & Pull Request Guidelines
- Commits: use Conventional Commits (`feat:`, `fix:`, `chore:`, `refactor:`).
  - Example: `feat(models): add SM-2 scheduling`.
- PRs: clear description, link the brief/issue (e.g., `prompts/JP-APP-001.md`), screenshots for UI changes, and test notes (key cases or `make test` output).

## Security & Configuration Tips
- App runs fully offline; no analytics or network calls. Persist deck at `Documents/deck.json`.
- Avoid logging PII; prefer `Log.app` for structured messages.
- Do not add third‑party SDKs without discussion.

## Agent-Specific Notes
- Implement sources only; do not modify Xcode project files.
- Keep modules small and focused; follow existing folder layout.
- Memory helpers: `scripts/memory.sh init|append|sanity|progress|recall` to maintain `.codex/` state.

