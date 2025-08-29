# Content Audit Report

**Acceptance Gate**
- index.json: MISSING
- Each lesson: objective, ≥2 shadow, listening MCQ, reading MCQ, check, 3–5 KanjiWord with hiragana readings

## Index.json
- Status: MISSING (acceptance will fail)
## Lessons Overview
- Lessons found: 5
- Duplicate lesson ids: none
- Duplicate KanjiWord ids: none
## Per-Lesson Checks
- A1-01 (A1-01-Greetings.json): ISSUES: missing reading
  - activities: objective, shadow, listening, check
  - shadow segments: 2 | kanjiWords: 3
- A1-04 (A1-04-WhereYouLive.json): OK
  - activities: objective, shadow, listening, reading, check
  - shadow segments: 2 | kanjiWords: 3
- A1-05 (A1-05-Prices.json): OK
  - activities: objective, shadow, listening, reading, check
  - shadow segments: 2 | kanjiWords: 3
- A1-06 (A1-06-TimeDate.json): OK
  - activities: objective, shadow, listening, reading, check
  - shadow segments: 2 | kanjiWords: 3
- A1-07 (A1-07-Ordering.json): OK
  - activities: objective, shadow, listening, reading, check
  - shadow segments: 3 | kanjiWords: 3
## Totals
- With objective: 5/5
- With ≥2 shadow segments: 5/5
- With listening MCQ: 5/5
- With reading MCQ: 4/5
- With check: 5/5
## Diagnostics
- error: Missing index.json
## Suggested Minimal Fixes
- Add lessons/index.json with ordered lesson ids.
- A1-01: add a reading MCQ activity (items + answer).

