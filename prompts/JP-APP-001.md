---
id: JP-APP-001
style: elegant,minimal,typed,teach
constraints: ["≤150 LOC/file","SwiftLint/SwiftFormat"]
deliverables: ["diff","tests","README snippet"]
---
# Goal
Implement the Swift sources for JapaneseBuddy: Kana tracing (PencilKit), simplified SM-2 SRS, ja-JP TTS, and local JSON persistence. Target iPadOS 17+.

# Tasks
- Complete the full Hiragana seed; add a Katakana deck and a toggle in Home to switch decks.
- Improve `TraceEvaluator` with a simple stroke-count heuristic and an overlap score threshold.
- Add a daily goal (10 new / 10 review) and a small stats card on Home.
- Add unit tests for SRS progression; add one minimal UI test plan for Home (navigation smoke test).

# Notes
- No App Store distribution; personal provisioning only.
- Do not generate or modify the Xcode project; only Swift sources/resources.
