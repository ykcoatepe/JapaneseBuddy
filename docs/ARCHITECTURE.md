# Architecture

JapaneseBuddy uses a layered structure:

- **Features** contain SwiftUI views for the app's sections.
- **Models** manage data and SRS logic.
- **Services** handle persistence, speech, and drawing utilities.

Data is stored locally at `Documents/deck.json`.
The app is fully offline; no analytics or network calls are made.
