# 05 - Field Types Advanced

## Prerequisites
- "Test All Fields" document type is selected
- "Test Document Alpha" is selected
- Editor panel is visible

## TC-05-01: Color field displays color value
**Steps:**
1. Scroll to "Color Field"
2. Call get_interactive_elements

**Expected:**
- "Color Field" label is visible
- A color swatch/preview is displayed
- Hex value "#FF5733" (seed value) or color input is visible

## TC-05-02: Color field opens picker
**Steps:**
1. Tap the color swatch or color input area
2. Call get_interactive_elements

**Expected:**
- Color picker UI appears (HSV wheel, sliders, or hex input)
- Current color value is reflected in the picker

## TC-05-03: Date field displays and opens picker
**Steps:**
1. Scroll to "Date Field"
2. Verify the date value is displayed (seed: "2026-03-01")
3. Tap the date field/button
4. Call get_interactive_elements

**Expected:**
- Date picker dialog or popover appears
- Current date is highlighted/selected

## TC-05-04: DateTime field displays value
**Steps:**
1. Scroll to "DateTime Field"
2. Call get_interactive_elements

**Expected:**
- "DateTime Field" label is visible
- DateTime value from seed data is displayed

## TC-05-05: Dropdown field displays and selects
**Steps:**
1. Scroll to "Dropdown Field"
2. Verify current value shows "Option A" (seed value)
3. Tap the dropdown to open it
4. Call get_interactive_elements
5. Tap "Option B"
6. Call get_interactive_elements
7. Verify the preview panel shows "preview:dropdown_field: option_b"

**Expected:**
- After step 4: Dropdown options visible ("Option A", "Option B", "Option C")
- After step 6: Dropdown shows "Option B" as selected value
- Preview panel text matches "preview:dropdown_field: option_b"

## TC-05-06: Image field displays URL and allows removal
**Steps:**
1. Scroll to "Image Field"
2. Verify the image URL "https://picsum.photos/200" is displayed (seed value) or an image preview is shown
3. If a URL input is visible, clear it and enter "https://picsum.photos/400"
4. If a "Remove" button is visible, tap it
5. Call get_interactive_elements

**Expected:**
- Image field label "Image Field" is visible
- After URL change or removal, the field state updates accordingly

**Note:** If the image field only shows a native file picker button with no URL input, mark as SKIPPED with note "No URL input available, native picker only"

## TC-05-07: File field displays state
**Steps:**
1. Scroll to "File Field"
2. Call get_interactive_elements

**Expected:**
- "File Field" label is visible
- Field shows empty/no-file state (seed value is null)

**Note:** File upload via native picker cannot be tested. Only verify the field renders correctly.
