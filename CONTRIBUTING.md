# Contributing

**Style:** small, focused PRs; Conventional Commits (`feat(ui): …`, `docs: …`).

**PR Checklist:** screenshots (UI changes), run build/tests in Xcode, docs touched if behavior changes.

**Docs edits:** keep README concise; deep content in `/docs/`. Use relative links.

## Dev quickstart
- Open `JapaneseBuddyProj/JapaneseBuddyProj.xcodeproj`
- Scheme `JapaneseBuddyProj` → Run on an iPad simulator or device
- Build with `make build`
- Test with `make test` (prefers an available iPad simulator; set `SIM_DEVICE` to override)
- Run content/localization/iPad sanity checks with `make sanity`
- For content, see `JapaneseBuddy/Resources/lessons/*.json` and update `JapaneseBuddy/Resources/lessons/index.json`
- Put active Xcode target tests under `JapaneseBuddyProj/JapaneseBuddyProjTests/`; keep legacy helper coverage in `JapaneseBuddyTests/` only when it is intentionally outside the active project target.
