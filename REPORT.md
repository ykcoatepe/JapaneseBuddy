# Lessons Feature Design Notes

## Overview
Adds a minimal lesson system driven by JSON packs. Lessons follow a can-do flow: objective, activities, and a self-rated check.

## Data
- `Lesson` model with nested `Activity` enum for objective, shadowing, listening, reading and check steps.
- `LessonProgress` stores `lastStep`, `stars`, `completedAt`.
- Progress persists in `DeckStore.State` under `lessonProgress`.

## Services
- `LessonStore` loads `Resources/lessons/*.json` at startup and bridges progress calls to `DeckStore`.

## UI
- `HomeView` shows a new *Lessons* tile.
- `LessonListView` lists lessons with star counts.
- `LessonRunnerView` advances through activities:
  - `ObjectiveView` shows the goal.
  - `ShadowingView` speaks segments with `AVSpeechSynthesizer`.
  - `ListeningView` and `ReadingView` provide simple MCQs.
  - `CheckView` lets learners record 1–3 stars.

## Tests
`LessonDecodeTests` validates JSON decoding and progress persistence.
