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

## 2026-02-18 - US-002: Full-Coverage Purple Glazing on App Icon
- What was implemented:
  - Changed the purple glazing from top-half-only to full 360-degree ring coverage
  - Removed the `glazeClipRect` that restricted glazing to the top portion of the donut
  - Removed the vertical offset on glazing ellipses (they were shifted up with `glazeThickness * 0.5` and `0.3` offsets)
  - Centered the glazing ellipses on the donut center for uniform coverage
  - Increased the inset margins from `0.008` to `0.018` (outer and inner) to show a visible rim of raw tan dough at both edges
  - Removed the unused `glazeThickness` variable
  - Regenerated all 10 app icon sizes
- Files changed:
  - `generate_icon.swift` (modified — full-ring glazing, removed top-half clipping, removed unused variable)
  - `ExerciseSnack/Assets.xcassets/AppIcon.appiconset/icon_*.png` (regenerated — all 10 sizes)
- **Learnings for future iterations:**
  - The original glazing used a combination of vertical offsets on the ellipses and a clip rect to restrict to top-half; making it full-ring is simpler — just center the ellipses and remove the clip rect
  - The inset margin (`0.018 * size`) creates a nice visible dough rim at both outer and inner edges
  - Sprinkle positions didn't need changes — they were already distributed around the full ring and the existing bounds-checking code handles the rest
---

## 2026-02-18 - US-003: Fix Bite Mark on Menu Bar Icon
- What was implemented:
  - Applied the same clipping-based bite subtraction fix from the app icon (US-001) to the menu bar icon
  - Donut body: replaced 3-ellipse even-odd fill (outer + hole + bite) with clip-first approach (rect + bite with even-odd clip, then outer + hole with even-odd fill)
  - Glazing clip path: replaced 3-ellipse even-odd clip (outer + hole + bite) with two-step clipping (first clip out bite, then clip to donut body minus hole)
  - Regenerated both menu bar icon sizes (18px @1x and 36px @2x)
  - Verified both sizes render correctly with clean bite mark, no bulge
- Files changed:
  - `generate_menubar_icon.swift` (modified — fixed bite subtraction in donut body and glazing clip)
  - `ExerciseSnack/Assets.xcassets/MenuBarIcon.imageset/menubar_icon.png` (regenerated)
  - `ExerciseSnack/Assets.xcassets/MenuBarIcon.imageset/menubar_icon@2x.png` (regenerated)
- **Learnings for future iterations:**
  - The menu bar icon had the exact same even-odd fill bug as the app icon — when fixing a drawing pattern in one icon generator, always check if the other icon generator has the same pattern
  - For the glazing clip, the menu bar icon needed a two-step clip (bite exclusion, then donut body clip) since clips are intersected — you can't combine bite exclusion and hole exclusion in a single 3-ellipse even-odd clip without the same bug
  - The icon remains a proper template image (black with alpha) after the fix — the clipping approach doesn't affect the color/alpha properties
---
