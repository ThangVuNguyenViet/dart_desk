# 14 - Theme Toggle

## Prerequisites
- App launched via main_test.dart
- Marionette connected

## TC-14-01: Toggle dark/light theme

**Steps:**
1. Call get_interactive_elements to find theme toggle button (usually in header)
2. Take screenshot (capture current theme state)
3. Tap the theme toggle
4. Take screenshot (capture new theme state)
5. Call get_interactive_elements

**Expected:**
- App renders without errors after toggle
- Visual theme changes (background, text colors differ between screenshots)
- No crash or layout overflow

## TC-14-02: Theme persists across navigation

**Steps:**
1. Toggle to dark theme (if not already)
2. Tap "Test Document Alpha" to navigate to document editor
3. Take screenshot
4. Tap "Test Document Beta" to navigate to different document
5. Take screenshot

**Expected:**
- Theme remains consistent (dark) across all navigation
- No flash of opposite theme during navigation
