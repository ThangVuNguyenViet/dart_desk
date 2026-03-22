# 12 - Media Browser Navigation

## Prerequisites
- App launched via main_test.dart
- Marionette connected
- 4 seeded media assets exist: hero-banner.jpg, profile-photo.png, mountain-landscape.jpg, app-icon.png
- Note: If media browser is in a ShadDialog, Marionette may not traverse overlays. Test via the standalone Media route instead.

## TC-12-01: Media route renders with seeded assets

**Steps:**
1. Navigate to Media route (tap Media in sidebar or navigate via route)
2. Call get_interactive_elements
3. Take screenshot

**Expected:**
- Media browser renders without errors
- 4 media asset thumbnails/items are visible
- Grid or list view toggle is available

## TC-12-02: Search filters assets

**Steps:**
1. Find search input in media browser
2. Enter text "hero"
3. Call get_interactive_elements

**Expected:**
- Only 1 result visible: hero-banner.jpg
- Other 3 assets are filtered out

## TC-12-03: Clear search restores all assets

**Steps:**
1. Clear the search field (select all + delete)
2. Call get_interactive_elements

**Expected:**
- All 4 media assets are visible again

## TC-12-04: Sort by name ascending

**Steps:**
1. Find sort dropdown/control
2. Select "Name (A-Z)" or equivalent
3. Call get_interactive_elements

**Expected:**
- Assets in order: app-icon.png, hero-banner.jpg, mountain-landscape.jpg, profile-photo.png

## TC-12-05: Filter by type (image)

**Steps:**
1. Find type filter dropdown
2. Select "Images" filter
3. Call get_interactive_elements

**Expected:**
- All 4 assets shown (all seeded assets are images)

## TC-12-06: Select asset shows detail panel

**Steps:**
1. Tap on hero-banner.jpg asset
2. Call get_interactive_elements
3. Take screenshot

**Expected:**
- Detail panel appears/updates with metadata
- Shows dimensions (800x400)
- Shows file size
- Shows blurHash preview or value
