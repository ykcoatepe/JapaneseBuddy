# UI Design System — JapaneseBuddy (iPad)

## 0) Principles
- Calm “washi” canvas, vivid accent; large touch targets; Dynamic Type & VoiceOver first  
- Fast feedback (haptics), minimal chrome, consistent toolbars

## 1) Tokens (`UI/Theme.swift`)
- **Spacing:** xsmall=6, small=10, medium=16, large=24  
- **Radii:** small=10, medium=16, large=20  
- **Shadow:** soft card shadow helpers  
- **Typography:** `Typography.title()`, `subtitle()`, `number()` (guidance)  
- **Colors:** `Color("AccentColor")`, `washiBg`, `cardBg`

## 2) Components (`UI/Components/*`)
- **JBButton (primary|secondary):** large CTAs; add `.accessibilityLabel/_Hint`  
- **JBCard:** `.ultraThinMaterial` with border; use for sections/cards  
- **StatTile:** title + big number; tap target ≥44×44  
- **ProgressBar:** thin progress; use for Daily Goal  
- **SectionHeader:** left title + optional trailing action  
- **EmptyState:** SF Symbol + short hint

## 3) Navigation (`App/AppSidebar.swift`)
`NavigationSplitView` → destinations: Home, Lessons, Practice, Review, Stats, Settings  
Apply theme: `.applyTheme(store.themeMode)` at root; keep sidebar labels short.

## 4) Page Specs
- **Home:** Greeting, `DailyGoalCard`, three Quick Actions; VO order: greeting → goal → actions  
- **Lessons:** Filter chips (All/A1/A2); row shows title, can-do, ★ count, `step/total`  
- **Runner:** Segmented header (Objective/Shadow/Listening/Reading/Kanji/Check)  
- **Trace:** Fixed bottom bar (Clear/Hint/Speak/Check); guard preview when `UIAccessibility.isReduceMotionEnabled`  
- **SRS:** Centered card; Speak; Hard/Good/Easy with haptic; large tap targets  
- **Stats:** 7-day bars from `sessionLog` (or EmptyState)

## 5) Accessibility & Motion
- Provide labels/hints for Speak, Check, Play/Pause, Grade; `.dynamicTypeSize(... .xxxLarge)`  
- With Reduce Motion ON: no stroke animations; show static hints only

## 6) Performance
- Off-main overlap scoring; single `CIContext`; debounced saves; idempotent notifications

## 7) Theming
- Persist `ThemeMode` (system|light|dark) in `DeckStore.State`  
- Root applies `.applyTheme(mode)`; tint from `AccentColor`

## 8) QA Checklist
- Portrait/landscape OK on 11" Pro & 13" Air  
- Theme switch live; motion guard active; VO/swipe order sane  
- Trace pass: overlap ≥0.6 AND strokes in [expected…expected+1]
