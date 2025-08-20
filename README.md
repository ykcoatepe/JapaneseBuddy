# JapaneseBuddy

Private iPad app for kana and kanji practice with Apple Pencil and a spaced repetition system. Includes Japanese text-to-speech and works fully offline.

## Run
Open in Xcode, select the `JapaneseBuddyProj` scheme, pick an iPad simulator or device, and press **Run**.

### Run & Test
- Build: `make build` (uses `xcodebuild -scheme JapaneseBuddyProj`)
- Tests: `make test`

## Architecture
- `JapaneseBuddy/`: App source (Features, Models, Services, Resources). Reusable and project-agnostic.
- `JapaneseBuddyProj/`: Xcode project shell that references `JapaneseBuddy/` sources and contains the app target and tests.
- Entry point: `JapaneseBuddyProjApp` launches `HomeView` in a `NavigationStack` and injects a shared `DeckStore` with `.environmentObject`.
- Only one `@main` exists in the app target. An older app entry file was removed from `JapaneseBuddy/App` to avoid confusion.

## Privacy
All data stays on the device. No analytics or third-party SDKs.

## License
MIT — see [LICENSE](LICENSE).

## Goals & Reminders
Set daily targets for new and review cards and track progress on the Home screen. Configure goals and optional local reminders in Settings; notifications stay on-device and are fully optional.

## Stroke Order
Trace practice shows optional stroke hints with numbered overlays and an animated preview. Use the Play/Pause button before tracing; disable hints in Settings if preferred.

## Lessons
Learn with short can-do based lessons. Each lesson starts with an objective, runs through activities like shadowing with Japanese TTS, listening or reading checks, then ends with a self-rated star review. Progress and stars save offline per lesson.

## Kanji Words
Type the reading in hiragana; tap Speak to hear it; correct answers join your SRS queue.
