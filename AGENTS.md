# Repository Guidelines

## Project Structure & Module Organization
- `JapaneseBuddy/`: app sources — `App/`, `Features/` (SwiftUI), `Models/` (SRS, Card), `Services/` (persistence, speech, drawing), `Resources/` (seed data).
- `JapaneseBuddyTests/`: XCTest targets (unit/UI). Keep test helpers here.
- `docs/`: architecture notes; `prompts/`: product/sprint briefs; `scripts/`: local utilities.

## Build, Test, and Development Commands
- `make build`: build the iPad app via `xcodebuild -scheme JapaneseBuddy` (iPad simulator target).
- `make test`: run XCTest for the scheme on the simulator.
- `make lint`: run SwiftLint (non-failing locally).
- `make format`: apply SwiftFormat to the repo.
Example: `make format && make lint && make test` before opening a PR.

## Coding Style & Naming Conventions
- Swift 5.9+, SwiftUI; indent 4 spaces; line length ≤ 140 (see `.swiftlint.yml`).
- File guideline: ≤ 150 LOC/file where practical (see TODOs and prompts).
- Names: `PascalCase` for types, `camelCase` for methods/vars, `snake_case` only for file names that mirror resources.
- One primary type per file; place files under the matching module folder (e.g., `Models/SRS.swift`).

## Testing Guidelines
- Frameworks: XCTest (unit) and minimal UI tests.
- Location: `JapaneseBuddyTests/*.swift` (e.g., `SRSProgressionTests.swift`).
- Scope: prioritize SRS progression, deck persistence, and simple navigation smoke tests.
- Run: `make test`. Aim for meaningful coverage on core logic; snapshot/UI tests are optional.

## Commit & Pull Request Guidelines
- Commits: follow Conventional Commits where possible (`feat:`, `fix:`, `chore:`, `refactor:`). Example: `feat(models): add SM-2 scheduling`.
- PRs: include a clear description, linked issue/brief (e.g., `prompts/JP-APP-001.md`), screenshots for UI changes, and test notes (`make test` output or key cases).

## Security & Configuration Tips
- App is fully offline; no analytics or network calls. Store decks at `Documents/deck.json`.
- Do not add third-party SDKs without discussion. Keep PII off logs.

## Agent-Specific Notes
- Implement sources only; do not modify Xcode project files.
- Adhere to `SwiftLint`/`SwiftFormat` and keep modules small and focused.
