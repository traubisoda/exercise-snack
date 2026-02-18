## Codebase Patterns
- App icon is generated programmatically via `generate_icon.swift` (run with `swift generate_icon.swift` from project root)
- Menu bar icon is generated via `generate_menubar_icon.swift`
- Icons use Core Graphics drawing with NSImage lockFocus/unlockFocus pattern
- Design is at 512px scale (app icon) or 36px scale (menu bar), everything scaled proportionally
- When subtracting shapes (like bite marks) from drawn paths, use clipping (rect + ellipse + even-odd) instead of adding the subtraction ellipse to the fill path with even-odd — the latter causes a fill bug when the subtraction ellipse extends beyond the outer boundary
- Generated PNGs go into `ExerciseSnack/Assets.xcassets/AppIcon.appiconset/` and `MenuBarIcon.imageset/`

---

## 2026-02-18 - US-001: Fix Bite Mark on App Icon
- What was implemented:
  - Fixed the even-odd fill bug where the bite ellipse extending beyond the donut's outer circle caused a filled "bulge" protruding from the donut
  - Changed approach from adding bite ellipse to the fill path (3 ellipses with even-odd) to clipping out the bite area first (rect + bite ellipse with even-odd clip), then drawing the donut ring (2 ellipses with even-odd)
  - Applied the same fix to the glazing layer which had the same bite subtraction pattern
  - Removed unused variables (`biteInnerPath`, `innerBiteRadius`, `crossSectionClip`) from cross-section code
  - Regenerated all 10 app icon sizes (16x16 through 512x512@2x)
- Files changed:
  - `generate_icon.swift` (modified — fixed bite subtraction in donut body and glazing drawing)
  - `ExerciseSnack/Assets.xcassets/AppIcon.appiconset/icon_*.png` (regenerated — all 10 sizes)
- **Learnings for future iterations:**
  - The even-odd fill rule with multiple ellipses is tricky: a region covered by exactly 1 shape gets filled. When a bite circle extends beyond the outer donut circle, the protruding area is covered by only the bite circle (1 shape = odd), so it gets filled — creating a bulge
  - The fix is to use clipping instead: create a clip path of (full rect + bite circle) with even-odd to exclude the bite area, then draw the remaining shapes normally
  - This clipping approach is more robust because it works regardless of whether the subtracted shape extends beyond the parent shape's bounds
---
