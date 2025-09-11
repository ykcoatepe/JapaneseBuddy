# Screenshots

This folder holds screenshots used in the README.
Replace the placeholder SVGs with real captures when ready.

## How to capture and replace
1) Capture on device or Simulator
- iPad: press Top button + Volume Up to take a screenshot.
- Simulator: File → New Screenshot (or Command-S).

2) Export to your Mac
- AirDrop from device, or drag the Simulator-captured images to Finder.

3) Prepare files (PNG)
- Target names: home.png, lessons.png, trace.png, srs.png
- Place them in: docs/screenshots/
- Recommended size: 2048×1536 (iPad landscape) or similar aspect ratio.

4) README uses PNGs by default
- README’s Screenshots section embeds the PNGs.
- The existing SVGs remain as fallbacks/placeholders.

5) Optional: Large files and LFS
- If any PNG exceeds ~10 MB, consider using Git LFS.
- See GitHub Docs → “About Git Large File Storage”.

6) Commit and push
- `git add docs/screenshots/*.png`
- `git commit -m "docs(screenshots): add real screenshots"`
- `git push`
