## Codebase Patterns
- Icon generation uses a standalone Swift script (`generate_icon.swift`) that can be re-run to regenerate all icons
- All icon sizes are defined in Contents.json already — just replace the PNG files
- The icon generator designs at 512px and scales all coordinates proportionally using `size / 512.0`
- CoreGraphics even-odd fill rule is used to create the donut shape (outer circle minus hole minus bite)
- Sprinkles are only drawn at sizes >= 64px where they'd be visible

---

## 2026-02-18 - US-001: Programmatic App Icon
- What was implemented:
  - Created `generate_icon.swift` — a standalone Swift script using CoreGraphics/AppKit to programmatically draw a bitten-donut icon
  - Design: green gradient background (light→dark, top-left→bottom-right), tan donut body, purple/violet glazing on top half, bite taken from upper-right, colorful sprinkles
  - Generated all 10 required macOS icon sizes (16x16 through 512x512@2x, actual pixels 16-1024)
  - Replaced existing icon PNGs in `Assets.xcassets/AppIcon.appiconset/`
  - Contents.json was already configured correctly — no changes needed
  - Build verified successfully with `xcodebuild`
- Files changed:
  - `generate_icon.swift` (new — icon generation script)
  - `ExerciseSnack/Assets.xcassets/AppIcon.appiconset/icon_*.png` (all 10 files replaced)
- **Learnings for future iterations:**
  - CGContext with lockFocus/unlockFocus on NSImage is the simplest way to draw programmatic icons on macOS
  - Use NSBitmapImageRep for precise pixel-size control when saving PNGs (NSImage size is in points, not pixels)
  - Even-odd fill rule (`ctx.fillPath(using: .evenOdd)`) is perfect for creating shapes with holes (donut = outer circle + hole circle + bite circle filled with even-odd)
  - Design at a fixed base size (512) and multiply all coordinates by `size / 512.0` for clean scaling
  - Sprinkles and fine details should be conditionally drawn only at sizes where they're visible (>= 64px)
---
