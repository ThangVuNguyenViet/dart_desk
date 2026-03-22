# 13 - Document Metadata Editing

## Prerequisites
- App launched via main_test.dart
- Marionette connected
- 3 seeded documents exist

## TC-13-01: Edit document title updates sidebar

**Steps:**
1. Tap "Test All Fields" in sidebar
2. Tap "Test Document Alpha" to select it
3. Find the document title input field (in document editor header area)
4. Clear the field and enter "Alpha Renamed"
5. Save the document
6. Call get_interactive_elements to check the sidebar document list

**Expected:**
- Sidebar document list shows "Alpha Renamed" instead of "Test Document Alpha"

## TC-13-02: Edit document slug

**Steps:**
1. With "Alpha Renamed" still selected
2. Find the slug input field
3. Clear and enter "alpha-renamed"
4. Save the document
5. Call get_interactive_elements

**Expected:**
- Slug field shows "alpha-renamed"

## TC-13-03: Toggle set as default

**Steps:**
1. Document Alpha is initially set as default
2. Select "Test Document Beta"
3. Find "Set as default" toggle/checkbox
4. Tap to enable it
5. Save
6. Call get_interactive_elements

**Expected:**
- Beta is now default
- Only one document can be default per type (Alpha should lose default status)

## TC-13-04: Duplicate slug handling

**Steps:**
1. Select "Test Document Gamma"
2. Change slug to "test-document-beta" (already taken by Beta)
3. Attempt to save
4. Call get_interactive_elements

**Expected:**
- Error or disambiguation shown (e.g., slug auto-adjusted or validation error displayed)
