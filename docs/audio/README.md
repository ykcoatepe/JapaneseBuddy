# Audio Packs

Shadowing can use local audio files when present, and falls back to built‑in ja‑JP text‑to‑speech (TTS) otherwise.

Folder layout
- JapaneseBuddy/Resources/lessons/audio/<lessonID>/seg-1.m4a
- JapaneseBuddy/Resources/lessons/audio/<lessonID>/seg-2.m4a
- …

Naming
- Files are zero‑based in lessons but 1‑based for filenames: seg-1.m4a, seg-2.m4a, …
- Example: for lesson B1-01, place files in Resources/lessons/audio/B1-01/.

Encoding
- Mono AAC at 44.1 kHz recommended
- Keep files short (a few seconds per segment)

Behavior
- On play, the app tries the local file first; if missing, it speaks the Japanese text via TTS.
- No network is used; playback is fully local.
