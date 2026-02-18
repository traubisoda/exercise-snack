## Codebase Patterns
- Icon generation uses `generate_icon.swift` (standalone Swift script, run with `swift generate_icon.swift`)
- All drawing is done in CoreGraphics with a 512-unit design space scaled via `size / 512.0`
- In CG's y-up coordinate system with non-flipped CTM: `addArc(clockwise: false)` goes counter-clockwise in math convention (increasing angles)
- Arc-based donut shape uses `donutArcPath()` helper that creates outer arc → bite edge → inner arc → bite edge → close
- Bite gap defined by `biteStartAngle` and `biteEndAngle` constants; the donut arc covers everything outside this range
- Scalloped bite edges use quadratic Bézier curves with alternating perpendicular control points
- Glazing is inset from donut edges by `glazeInset` to show tan dough margins
- Sprinkles are placed at specific angles/radii within the glazing band, not as absolute positions
- Menu bar icon is in separate `generate_menubar_icon.swift` — never modify when changing app icon

---

## 2026-02-18 - US-001: Reshape Donut and Narrow Glazing
- What was implemented:
  - Rewrote `generate_icon.swift` to use arc-based 3/4 donut shape instead of full circle with bite circle subtraction
  - Donut now covers ~270° with missing quarter in upper-right (biteStartAngle=0.08π to biteEndAngle=0.58π)
  - Added scalloped/wavy bite edges using quadratic Bézier curves with alternating perpendicular control points for realistic tooth marks
  - Narrowed the glazing band with `glazeInset = size * 0.035` leaving visible tan dough margins on both inner and outer edges
  - Repositioned sprinkles to use angle/radius coordinates on the glazing band instead of absolute dx/dy offsets
  - Added cross-section darker tan strips at bite edges using narrow wedge clips
  - Preserved purple gradient glazing, drop shadow, and 3D highlight effects
  - Highlight is now clipped to the donut arc shape so it doesn't appear in the bite gap
- Files changed:
  - `generate_icon.swift` (rewritten — arc-based donut shape with scalloped bites and narrower glazing)
  - `ExerciseSnack/Assets.xcassets/AppIcon.appiconset/*.png` (all 10 icon sizes regenerated)
- **Learnings for future iterations:**
  - CoreGraphics `addArc(clockwise:)` in the default y-up coordinate system: `false` = counter-clockwise in math (increasing angles), `true` = clockwise in math (decreasing angles). This is the opposite of what the name suggests intuitively for screen coordinates.
  - When building an arc ring (outer + inner arcs), the inner arc must go in the OPPOSITE direction to the outer arc to form a proper closed ring shape
  - Scalloped edges work best with 3+ scallops, depth ~4*scale, and alternating +/- perpendicular offsets
  - Placing sprinkles by angle+radius on the donut is more robust than absolute coordinates when the donut shape changes
  - Always verify icon generation at both small (16px, 32px) and large (512px, 1024px) sizes
---
