Summary

This PR lands the front-end redesign and learning-content expansion, adds an audio playback fallback path, localizes new surfaces, and introduces streak + weekly minutes tracking. It also polishes documentation (README, docs index, contributing, reports) and adds sanity checks to keep lesson content healthy.

What changed

- Front-end redesign
  - App-wide NavigationSplitView layout with sidebar entry for Lessons/Trace/SRS/Stats
  - ThemeMode support and design tokens/components applied across views
  - Respect Reduce Motion and optional haptics toggles
  - Consistent typography, spacing, and interactive states
- Screenshots and docs
  - README now shows a 2×2 screenshots grid; placeholders added and later swapped to PNGs
  - docs/README.md created; CONTRIBUTING.md and .markdownlint.yml added; linkcheck workflow optional
  - REPORT-FE.md and REPORT-POSTMERGE.md included for auditability
- Lessons content
  - Added six original B1 lessons (B1-01 … B1-06) with objectives, shadowing, listening/reading MCQs, checks, and kanjiWords
  - Updated lessons/index.json to include B1 and validated A1/A2 entries
- Audio playback fallback
  - New AudioEngine with local file playback for shadowing segments when audio packs are present
  - Speaker.playSegment prefers local audio; gracefully falls back to TTS when missing
- Streaks and study minutes
  - Track session begin/end to compute minutesToday, weeklyMinutes, current/best streak
  - HomeView shows “Streak: N days” and “Today: X min”; StatsView shows weekly minutes bars and best streak
  - Added compact Sparkline component for recent activity
- Localization
  - New strings added for Stats (streak/minutes/noData) with Base/en/tr/ja coverage
  - Minor copy tweaks to align across views
- Post-merge sanity
  - scripts/postmerge_sanity.py validates lessons index, segment counts, and kanjiWords presence
  - REPORT-POSTMERGE.md captures results and guidance

Acceptance checks

- UI/UX
  - Sidebar structure visible; NavigationSplitView adapts across orientations
  - ThemeMode applies correctly; typography and spacing consistent
  - Reduce Motion disables non-essential animations; haptics toggle respected
- Lessons
  - lessons/index.json present and valid; all referenced lesson files load
  - B1-01 … B1-06 render with shadowing, MCQs, and checks
- Audio
  - When audio packs exist, segments play locally; otherwise TTS fallback is invoked
  - Playback controls do not overlap or double-play; TTS cancels on local playback
- Streak/Minutes
  - beginStudy/endStudy paired on appear/disappear for study views (Trace/SRS)
  - Today minutes increments during active sessions; weekly minutes aggregates by day
  - Current streak increments once per day with activity; best streak persists
- Localization
  - New keys present in Base/en/tr/ja; missing-key warnings do not appear at runtime
- Stability
  - App launches cleanly; no crashes when switching tabs or rotating the device

QA matrix

- Devices: iPad Pro 11" (M2), iPad Air 13" (M2)
- Appearance: Light, Dark
- Languages: EN, TR, JA
- Accessibility: Reduce Motion ON/OFF

Results snapshot (manual sanity pass):

- iPad Pro 11" / Light / EN / Reduce Motion OFF → NavigationSplitView, lessons load, audio fallback OK, streak/minutes update ✅
- iPad Pro 11" / Dark / TR / Reduce Motion ON → Animations reduced, typography/theme OK, localized strings present ✅
- iPad Air 13" / Light / JA / Reduce Motion OFF → Layout scales, B1 lessons playable, weekly minutes chart renders ✅
- iPad Air 13" / Dark / EN / Reduce Motion ON → Audio packs preferred; TTS fallback when missing; no overlaps ✅

Risks/Rollback

- Audio: Mixed local/TTS playback paths—guard against double-start and interruption
- Data: Session logging changes add optional fields; ensure backup/restore continues to serialize unknown keys safely
- Localization: Missing keys could surface as fallback text
- Rollback plan: Revert this PR; no data migration required since new fields are optional

Checklist

- [x] NavigationSplitView, ThemeMode applied across main views
- [x] B1-01 … B1-06 added and indexed
- [x] AudioEngine + TTS fallback wired in shadowing flow
- [x] Streak + weekly minutes visible on Home/Stats; Sparkline included
- [x] Localization for Base/en/tr/ja updated for new keys
- [x] README/docs updated; screenshots placeholders and PNGs referenced
- [x] Post-merge sanity script run; REPORT-POSTMERGE.md updated
- [x] Smoke tested on iPad simulators for layout and playback

