## Codebase Patterns
- See main PRD progress.md at `.chief/prds/excercise-snack/progress.md` for general patterns
- Settings window fix: Use `.windowToolbarStyle(.unified(showsTitle: true))` on Window scene and `.toolbarBackground(.visible, for: .windowToolbar)` on the view to prevent content from scrolling behind the title bar

---

## 2026-02-17 - US-001: Fix Settings Content Scrolling Behind Title Bar
- What was implemented:
  - Added `.windowToolbarStyle(.unified(showsTitle: true))` to the settings Window scene in `ExerciseSnackApp.swift` — this creates a unified toolbar with an opaque title bar separator that prevents content from scrolling behind it
  - Added `.toolbarBackground(.visible, for: .windowToolbar)` to the SettingsView Form — this ensures the toolbar background is always visible (not just when content starts scrolling)
  - The grouped form style, frame size, and `.windowResizability(.contentSize)` remain unchanged
- Files changed:
  - `ExerciseSnack/ExerciseSnackApp.swift` (modified — added `.windowToolbarStyle(.unified(showsTitle: true))` to settings Window)
  - `ExerciseSnack/SettingsView.swift` (modified — added `.toolbarBackground(.visible, for: .windowToolbar)`)
- **Learnings for future iterations:**
  - On macOS, `Form` with `.formStyle(.grouped)` uses an internal `NSScrollView` that allows content to scroll behind the title bar by default
  - `.windowToolbarStyle(.unified(showsTitle: true))` on the Window scene creates an opaque title bar separator — this is the primary fix for the "content behind title bar" issue
  - `.toolbarBackground(.visible, for: .windowToolbar)` provides additional insurance that the toolbar background is always visible
  - Both modifiers are available from macOS 14.0 (the project's deployment target)
  - The `.unified(showsTitle: true)` style is visually compatible with grouped forms — it doesn't change the overall aesthetic
---
