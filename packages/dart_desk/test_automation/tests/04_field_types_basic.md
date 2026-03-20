# 04 - Field Types Basic

## Prerequisites
- "Test All Fields" document type is selected
- "Test Document Alpha" is selected (has known seed data)
- Editor panel is visible on the right

## TC-04-01: String field displays and edits
**Steps:**
1. Verify "String Field" label is visible in the editor
2. Verify the string input shows "Hello World" (seed value)
3. Clear the field and enter "Updated String"
4. Call get_interactive_elements
5. Verify the preview panel shows "preview:string_field: Updated String"

**Expected:**
- String field label "String Field" is visible
- Input contains "Updated String" after editing
- Preview panel text matches "preview:string_field: Updated String"

## TC-04-02: Text field displays and edits
**Steps:**
1. Scroll to "Text Field" if not visible
2. Verify multi-line text area shows seed value
3. Clear and enter "New multi-line\ntext content"
4. Call get_interactive_elements

**Expected:**
- Text field label "Text Field" is visible
- Text area is multi-line (rows > 1)

## TC-04-03: Number field displays and edits
**Steps:**
1. Scroll to "Number Field"
2. Verify it shows "42" (seed value)
3. Clear and enter "99"
4. Call get_interactive_elements
5. Verify the preview panel shows "preview:number_field: 99"

**Expected:**
- Number field shows "99" after editing
- Preview panel text matches "preview:number_field: 99"

## TC-04-04: Boolean field displays and toggles
**Steps:**
1. Scroll to "Boolean Field"
2. Verify toggle is ON (seed value is true)
3. Tap the toggle/switch
4. Call get_interactive_elements
5. Verify the preview panel shows "preview:boolean_field: false"

**Expected:**
- Toggle switches to OFF state
- The GestureDetector or ShadSwitch element reflects the new state
- Preview panel text matches "preview:boolean_field: false"

## TC-04-05: Checkbox field displays and toggles
**Steps:**
1. Scroll to "Checkbox Field"
2. Verify checkbox is unchecked (seed value is false)
3. Verify label "Enable this feature" is visible
4. Tap the checkbox
5. Call get_interactive_elements

**Expected:**
- Checkbox toggles to checked state

## TC-04-06: URL field displays and edits
**Steps:**
1. Scroll to "URL Field"
2. Verify it shows "https://example.com" (seed value)
3. Clear and enter "https://flutter.dev"
4. Call get_interactive_elements
5. Verify the preview panel shows "preview:url_field: https://flutter.dev"

**Expected:**
- URL field shows "https://flutter.dev" after editing
- Preview panel text matches "preview:url_field: https://flutter.dev"
