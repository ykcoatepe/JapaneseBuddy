---
title: Architecture
type: note
---

# Architecture

JapaneseBuddy uses a layered structure:

- **App** starts in `JapaneseBuddyProjApp` and hosts `AppSidebar`.
- **Features** contain SwiftUI views for the app's sections.
- **Models** manage data and SRS logic.
- **Services** handle persistence, speech, and drawing utilities.
- **Resources** contain localized strings, lesson JSON, optional local audio packs, and app assets.
- **UI** contains shared theme tokens and reusable components.

Data is stored locally at `Documents/deck.json`.
The app is fully offline; no analytics or network calls are made.

The main shell is iPad-first: `NavigationSplitView` drives Home, Lessons, Practice, Review, Stats, and Settings. Lesson content loads from `JapaneseBuddy/Resources/lessons/index.json`, then falls back to path ordering when a manifest is missing. Shadowing prefers bundled audio under `JapaneseBuddy/Resources/lessons/audio/<lessonID>/seg-<n>.m4a`; missing files fall back to built-in ja-JP text-to-speech.
