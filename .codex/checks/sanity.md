# Sanity Snapshot

- Updated: 2026-02-15T19:35:49Z

## Project
- xcodeproj: present

## Lessons Wiring
- lessons folder reference present in project (blue folder)
- A1-01 present via folder reference
- A1-04 present via folder reference

## Loader Checks
17:        let fromFolder = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: "lessons")
18:        let fromRoot = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil)
