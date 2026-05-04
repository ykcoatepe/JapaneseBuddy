Release v0.3.0-rc1

Highlights

- New iPad-first NavigationSplitView UI with a clean sidebar
- A guided 22-lesson A1/A2/B1 path for zero-to-intermediate study
- Local audio packs with automatic fallback to TTS for shadowing segments
- Study streaks and weekly minutes tracking with a compact sparkline
- Expanded localization: English, Turkish, Japanese

Added

- Front-end redesign: NavigationSplitView, sidebar destinations, and theme application
- ThemeMode support and design tokens/components applied app-wide
- 22 indexed lessons across A1:8, A2:6, and B1:8 with objectives, shadowing, MCQs, checks, and kanjiWords
- AudioEngine: local audio playback; Speaker fallback to TTS when files are missing
- Streaks and time tracking: minutesToday, weeklyMinutes, current/best streak
- Sparkline component and updated Home/Stats views
- Post-merge sanity tooling and reports to validate lessons/index and content structure

Improved

- Consistent typography, spacing, and interaction across views; reduced motion support
- Stats view shows a weekly minutes chart and best streak summary
- Stability: begin/end study session handling to avoid double counting and ensure clean backgrounding
- Localization coverage expanded (Base/en/tr/ja) for new Stats strings
- Backup/restore: compatibility maintained with new optional log fields (no migration required)

Fixed

- Avoid overlapping TTS and local audio by canceling TTS when local playback starts
- Lessons index sanity checks catch missing or malformed entries earlier

Docs

- README refreshed with screenshots grid and placeholder guidance
- docs/README.md added as a docs index; CONTRIBUTING.md and .markdownlint.yml
- Reports: REPORT-FE.md and REPORT-POSTMERGE.md for auditability
- Design system and pedagogy notes consolidated in documentation sections

Known issues

- Latest sanity reports 161 Base/en/tr/ja localization keys with missing/extra 0
- Audio packs are optional; without them, TTS is used automatically (network/voice availability may vary)
- Screenshot PNGs are placeholders until final captures are added

Upgrade/Install (dev provisioning)

- No data migrations required; new fields added as optional
- If using local audio packs, include the audio resources folder in target Copy Bundle Resources
- Ensure Base/en/tr/ja `.strings` files stay mirrored across main and bundled lesson localization folders
- Run the post-merge sanity script to validate lessons/index and content consistency before release

Thanks

Huge thanks to contributors who shaped the FE redesign, expanded the A1/A2/B1 path, refined audio behavior, and helped verify localization and stats. Your feedback guided NavigationSplitView structure, ThemeMode application, and the learning flow polish.
