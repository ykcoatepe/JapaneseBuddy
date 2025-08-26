# JapaneseBuddy

Private iPad app for kana and kanji practice with Apple Pencil and a spaced repetition system. Includes Japanese text-to-speech and works fully offline.

## Run
Open in Xcode, select the `JapaneseBuddyProj` scheme, pick an iPad simulator or device, and press **Run**.

### Run & Test
- Build: `make build` (uses `xcodebuild -scheme JapaneseBuddyProj`)
- Tests: `make test`

## Architecture
- `JapaneseBuddy/`: App source (Features, Models, Services, Resources, UI, App). Reusable and project-agnostic.
- `JapaneseBuddyProj/`: Xcode project shell that references `JapaneseBuddy/` sources and contains the app target and tests.
- Entry point: `JapaneseBuddyProjApp` launches `AppSidebar` using `NavigationSplitView` and injects a shared `DeckStore` with `.environmentObject`.
- Only one `@main` exists in the app target.

## Privacy
All data stays on the device. No analytics or third-party SDKs.

## License
MIT — see [LICENSE](LICENSE).

## Branding
JapaneseBuddy sports a red sun app icon with kana and uses a warm accent tint throughout the app.

## Goals & Reminders
Set daily targets for new and review cards and track progress on the Home screen. Configure goals and optional local reminders in Settings; notifications stay on-device and are fully optional.

## Backup & Restore
Use **Settings ▸ Backup & Restore** to export or import your study deck. Export shares `deck.json` from the Documents folder via the system share sheet. Import validates the file then replaces the existing deck. All data stays local on your device.

## Stroke Order
Trace practice shows optional stroke hints with numbered overlays and an animated preview. Use the Play/Pause button before tracing; disable hints in Settings if preferred.

## Lessons
Learn with short can-do based lessons. Each lesson starts with an objective, runs through activities like shadowing with Japanese TTS, listening or reading checks, then ends with a self-rated star review. Progress and stars save offline per lesson.

## Authoring lessons
Lessons live in `JapaneseBuddy/Resources/lessons/` as JSON.
Generate them from a CSV with fields:

```
id,title,canDo,shadow1,shadow2,shadow3,shadow4,listQ,A,B,C,lAns,readQ,choices,rAns,kanji,reading,meaning
```

Example row:

```
A1-05,Prices,Ask prices,りんごは いくら ですか。,３００円 です.,,,How much is the apple?,300 yen,500 yen,700 yen,1,Pick the notebook price.,１００円|３００円|６００円,2,円|百|千,えん|ひゃく|せん,yen|hundred|thousand
```

## Kanji Words
Type the reading in hiragana; tap Speak to hear it; correct answers join your SRS queue.
## Onboarding
First launch presents a short onboarding flow to choose decks, learn the tracing pass rule, set goals, and optionally save your name.

## UI Design System
- Tokens: defined in `UI/Theme.swift`
  - Colors: `Color.accentColor`, `Color.washi` (background), `Color.wasabi` (support), `Color.cardBackground` (cards)
  - Spacing: `Theme.Spacing` (xsmall/small/medium/large)
  - CornerRadius: `Theme.CornerRadius` (small/medium/large)
  - Shadow: `Theme.Shadow.card`
  - Typography helpers: `Typography.title/_header/_label`
- Components: under `UI/Components/`
  - `JBButton` (primary/secondary)
  - `JBCard` (material card with border + shadow)
  - `ProgressBar` (thin semantic progress)
  - `SectionHeader` (title + trailing action slot)
  - `StatTile` (value+label in a card)
  - `EmptyState` (icon + message)
- Navigation: `App/AppSidebar.swift` uses `NavigationSplitView` with sidebar items Home, Lessons, Practice, Review, Stats, Settings.
- Views:
  - Home: greeting, DailyGoal card, quick actions (Continue Lesson / Trace / Review)
  - Lessons: filter chips A1/A2/All, progress stars
  - Runner: segmented header (Objective/Shadow/Listening/Reading/Kanji/Check)
  - Trace: fixed bottom toolbar (Clear/Hint/Speak/Check), respects Reduce Motion
  - SRS: large type card + haptics
  - Stats: streak + weekly chart, falls back to EmptyState
  - Settings: theme toggle (System/Light/Dark)
